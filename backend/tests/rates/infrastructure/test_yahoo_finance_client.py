import pytest

from rates.domain.entities import CurrencyRate
from rates.domain.errors import UpstreamError
from rates.infrastructure.yahoo_finance_client import YahooFinanceCurrencyClient


class FakeResponse:
    def __init__(self, status: int, headers: dict[str, str], body: str) -> None:
        self.status = status
        self.headers = headers
        self._body = body

    async def text(self) -> str:
        return self._body


def test_parse_rates_valid_payload(
    yahoo_client: YahooFinanceCurrencyClient,
    yahoo_payload_valid: str,
    yahoo_symbol_map: dict[str, str],
    expected_yahoo_rate: CurrencyRate,
) -> None:
    rates = yahoo_client._parse_rates(yahoo_payload_valid, yahoo_symbol_map)

    assert rates == [expected_yahoo_rate]


def test_parse_rates_invalid_json(
    yahoo_client: YahooFinanceCurrencyClient,
    yahoo_payload_invalid_json: str,
    yahoo_symbol_map: dict[str, str],
) -> None:
    with pytest.raises(UpstreamError):
        yahoo_client._parse_rates(yahoo_payload_invalid_json, yahoo_symbol_map)


def test_parse_rates_malformed_payload(
    yahoo_client: YahooFinanceCurrencyClient,
    yahoo_payload_malformed: str,
    yahoo_symbol_map: dict[str, str],
) -> None:
    with pytest.raises(UpstreamError):
        yahoo_client._parse_rates(yahoo_payload_malformed, yahoo_symbol_map)


def test_parse_rates_ignores_unknown_entries(
    yahoo_client: YahooFinanceCurrencyClient,
    yahoo_payload_with_noise: str,
    yahoo_symbol_map: dict[str, str],
) -> None:
    rates = yahoo_client._parse_rates(yahoo_payload_with_noise, yahoo_symbol_map)

    assert rates == []


def test_quote_headers_include_session(
    yahoo_client_with_session: YahooFinanceCurrencyClient,
) -> None:
    headers = yahoo_client_with_session._quote_headers()

    assert headers["Accept"] == "application/json, text/plain, */*"
    assert headers["Cookie"] == "cookie=one"
    assert headers["x-yahoo-request-id"] == "crumb"


async def test_fetch_rates_retries_after_auth_failure(
    yahoo_client: YahooFinanceCurrencyClient,
    yahoo_payload_valid: str,
    expected_yahoo_rate: CurrencyRate,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    responses = [
        FakeResponse(status=200, headers={"set-cookie": "cookie=one"}, body=""),
        FakeResponse(status=200, headers={}, body="crumb-one"),
        FakeResponse(status=401, headers={}, body=""),
        FakeResponse(status=200, headers={"set-cookie": "cookie=two"}, body=""),
        FakeResponse(status=200, headers={}, body="crumb-two"),
        FakeResponse(status=200, headers={}, body=yahoo_payload_valid),
    ]

    async def fake_fetch(url: str, headers: dict[str, str]) -> FakeResponse:
        return responses.pop(0)

    monkeypatch.setattr(yahoo_client, "_fetch", fake_fetch)

    rates = await yahoo_client.fetch_rates(base="USD", quotes=["EUR"])

    assert rates == [expected_yahoo_rate]
