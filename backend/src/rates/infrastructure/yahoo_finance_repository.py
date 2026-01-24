from datetime import UTC, datetime, timedelta

from rates.domain.entities import CurrencyRate
from rates.domain.interfaces import CachedRates, RatesCache, RatesRepository
from rates.infrastructure.config import ProxyConfig
from rates.infrastructure.yahoo_finance_client import CurrencyRatesClient


class YahooFinanceRatesRepository(RatesRepository):
    def __init__(
        self,
        client: CurrencyRatesClient,
        cache: RatesCache,
        config: ProxyConfig,
    ) -> None:
        self._client = client
        self._cache = cache
        self._config = config

    async def fetch_rates(self, base: str, quotes: list[str]) -> list[CurrencyRate]:
        if self._config.cache_max_age_seconds <= 0:
            return await self._client.fetch_rates(base=base, quotes=quotes)

        cached_rates: dict[str, CurrencyRate] = {}
        missing_quotes: list[str] = []
        for quote in quotes:
            cache_key = self._build_cache_key(base, quote)
            cached = self._cache.get(cache_key)
            if cached is None:
                missing_quotes.append(quote)
                continue
            cached_rate = next(
                (rate for rate in cached.rates if rate.quote == quote),
                None,
            )
            if cached_rate is None:
                missing_quotes.append(quote)
                continue
            cached_rates[quote] = cached_rate

        fetched_rates: list[CurrencyRate] = []
        if missing_quotes:
            fetched_rates = await self._client.fetch_rates(
                base=base,
                quotes=missing_quotes,
            )
            expires_at = datetime.now(UTC) + timedelta(
                seconds=self._config.cache_max_age_seconds,
            )
            for rate in fetched_rates:
                cache_key = self._build_cache_key(base, rate.quote)
                self._cache.set(
                    cache_key,
                    CachedRates(rates=(rate,), expires_at=expires_at),
                )

        for rate in fetched_rates:
            cached_rates[rate.quote] = rate

        return [cached_rates[quote] for quote in quotes if quote in cached_rates]

    def _build_cache_key(self, base: str, quote: str) -> str:
        return f"{base}:{quote}"
