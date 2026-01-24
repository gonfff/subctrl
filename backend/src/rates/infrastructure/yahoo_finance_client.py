import asyncio
import json
from datetime import UTC, datetime
from typing import Any, Protocol

from workers import fetch

from rates.domain.entities import CurrencyRate
from rates.domain.errors import UpstreamError


class _SessionError(UpstreamError):
    pass


class CurrencyRatesClient(Protocol):
    async def fetch_rates(self, base: str, quotes: list[str]) -> list[CurrencyRate]: ...


class YahooFinanceCurrencyClient:
    _init_host = "fc.yahoo.com"
    _host = "query1.finance.yahoo.com"
    _crumb_endpoint = "/v1/test/getcrumb"
    _quote_endpoint = "/v7/finance/quote"

    def __init__(self, timeout_seconds: int) -> None:
        self._timeout_seconds = timeout_seconds
        self._crumb: str | None = None
        self._cookie: str | None = None
        self._session_lock = asyncio.Lock()

    async def fetch_rates(self, base: str, quotes: list[str]) -> list[CurrencyRate]:
        return await self._fetch_rates_with_retry(base, quotes, allow_retry=True)

    async def _fetch_rates_with_retry(
        self,
        base: str,
        quotes: list[str],
        allow_retry: bool,
    ) -> list[CurrencyRate]:
        try:
            return await self._fetch_rates_once(base, quotes)
        except _SessionError:
            if not allow_retry:
                raise
            self._reset_session()
            return await self._fetch_rates_with_retry(base, quotes, allow_retry=False)

    async def _fetch_rates_once(self, base: str, quotes: list[str]) -> list[CurrencyRate]:
        await self._ensure_session_initialized()
        normalized_base = base.upper()
        normalized_quotes = [quote.upper() for quote in quotes]
        symbol_map = {f"{quote}{normalized_base}=X": quote for quote in normalized_quotes}

        url = f"https://{self._host}{self._quote_endpoint}?symbols={','.join(symbol_map.keys())}&region=US&lang=en-US&crumb={self._crumb}"

        response = await self._fetch(url, headers=self._quote_headers())
        if response.status in {401, 429}:
            raise _SessionError(
                f"Yahoo Finance request failed with status {response.status}.",
            )
        if response.status != 200:
            raise UpstreamError(
                f"Yahoo Finance request failed with status {response.status}.",
            )
        payload = await response.text()
        return self._parse_rates(payload, symbol_map)

    async def _ensure_session_initialized(self) -> None:
        if self._crumb and self._cookie:
            return
        async with self._session_lock:
            if self._crumb and self._cookie:
                return
            await self._create_session()

    async def _create_session(self) -> None:
        init_response = await self._fetch(
            f"https://{self._init_host}",
            headers=self._default_headers(),
        )

        cookie_header = init_response.headers.get("set-cookie")
        if not cookie_header:
            raise _SessionError("Yahoo Finance did not return a session cookie.")
        self._cookie = cookie_header.split(";")[0]

        assert self._cookie is not None  # for type checker

        crumb_response = await self._fetch(
            f"https://{self._host}{self._crumb_endpoint}",
            headers={
                **self._default_headers(),
                "Cookie": self._cookie,
            },
        )
        if crumb_response.status != 200:
            raise _SessionError(
                f"Yahoo Finance crumb request failed with status {crumb_response.status}.",
            )
        self._crumb = (await crumb_response.text()).strip()
        if not self._crumb:
            raise _SessionError("Yahoo Finance crumb response was empty.")

    def _reset_session(self) -> None:
        self._crumb = None
        self._cookie = None

    async def _fetch(self, url: str, headers: dict[str, str]) -> Any:
        try:
            return await asyncio.wait_for(
                fetch(url, headers=headers),
                timeout=self._timeout_seconds,
            )
        except TimeoutError as exc:
            raise UpstreamError("Yahoo Finance request timed out.") from exc
        except Exception as exc:  # pragma: no cover - defensive
            raise UpstreamError("Yahoo Finance request failed.") from exc

    def _parse_rates(
        self,
        body: str,
        symbol_map: dict[str, str],
    ) -> list[CurrencyRate]:
        try:
            decoded = json.loads(body)
        except json.JSONDecodeError as exc:
            raise UpstreamError("Yahoo Finance response was malformed.") from exc

        if not isinstance(decoded, dict):
            raise UpstreamError("Yahoo Finance response was malformed.")

        quote_response = decoded.get("quoteResponse", {}).get("result", [])

        if not isinstance(quote_response, list):
            raise UpstreamError("Yahoo Finance response was malformed.")

        rates: list[CurrencyRate] = []
        for entry in quote_response:
            if not isinstance(entry, dict):
                continue
            symbol = entry.get("symbol", "")
            quote_code = symbol_map.get(symbol)
            if not quote_code:
                continue
            price = entry.get("regularMarketPrice")
            if not isinstance(price, (int, float)):
                continue
            time_value = entry.get("regularMarketTime")
            if isinstance(time_value, (int, float)):
                fetched_at = datetime.fromtimestamp(time_value, tz=UTC)
            else:
                fetched_at = datetime.now(UTC)
            rates.append(
                CurrencyRate(
                    quote=quote_code,
                    rate=float(price),
                    fetched_at=fetched_at,
                ),
            )
        return rates

    def _default_headers(self) -> dict[str, str]:
        return {
            "User-Agent": (
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
                "(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
            ),
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
            "Connection": "keep-alive",
        }

    def _quote_headers(self) -> dict[str, str]:
        headers = {
            **self._default_headers(),
            "Accept": "application/json, text/plain, */*",
        }
        if self._cookie:
            headers["Cookie"] = self._cookie
        if self._crumb:
            headers["x-yahoo-request-id"] = self._crumb
        return headers
