import json
from collections.abc import Callable
from datetime import UTC, datetime, timedelta

import pytest

from rates.domain.entities import CurrencyRate
from rates.domain.interfaces import CachedRates
from rates.infrastructure.cache import InMemoryRatesCache
from rates.infrastructure.config import ProxyConfig
from rates.infrastructure.rate_limiter import InMemoryRateLimiter
from rates.infrastructure.yahoo_finance_client import YahooFinanceCurrencyClient
from rates.infrastructure.yahoo_finance_repository import YahooFinanceRatesRepository


class FakeRatesClient:
    def __init__(self, rates: list[CurrencyRate]) -> None:
        self._rates = list(rates)
        self.calls: list[tuple[str, list[str]]] = []

    async def fetch_rates(self, base: str, quotes: list[str]) -> list[CurrencyRate]:
        self.calls.append((base, list(quotes)))
        rates_by_quote = {rate.quote: rate for rate in self._rates}
        return [rates_by_quote[quote] for quote in quotes if quote in rates_by_quote]


@pytest.fixture
def rates_cache() -> InMemoryRatesCache:
    return InMemoryRatesCache()


@pytest.fixture
def base_currency() -> str:
    return "USD"


@pytest.fixture
def quote_currencies() -> list[str]:
    return ["EUR"]


@pytest.fixture
def cache_key(base_currency: str, quote_currencies: list[str]) -> str:
    return f"{base_currency}:{sorted(quote_currencies)[0]}"


@pytest.fixture
def client_id() -> str:
    return "client-1"


@pytest.fixture
def cached_rates_valid(sample_rates: list[CurrencyRate]) -> CachedRates:
    now = datetime.now(UTC)
    return CachedRates(
        rates=tuple(sample_rates),
        expires_at=now + timedelta(seconds=60),
    )


@pytest.fixture
def cached_rates_expired(sample_rates: list[CurrencyRate]) -> CachedRates:
    now = datetime.now(UTC)
    return CachedRates(
        rates=tuple(sample_rates),
        expires_at=now - timedelta(seconds=1),
    )


@pytest.fixture
def fake_rates_client(sample_rates: list[CurrencyRate]) -> FakeRatesClient:
    return FakeRatesClient(sample_rates)


@pytest.fixture
def fake_rates_client_factory() -> Callable[[list[CurrencyRate]], FakeRatesClient]:
    def _factory(rates: list[CurrencyRate]) -> FakeRatesClient:
        return FakeRatesClient(rates)

    return _factory


@pytest.fixture
def rate_limiter_one() -> InMemoryRateLimiter:
    return InMemoryRateLimiter(max_requests=1, window_seconds=60)


@pytest.fixture
def clear_proxy_env(monkeypatch: pytest.MonkeyPatch) -> None:
    keys = [
        "CACHE_MAX_AGE_SECONDS",
        "RATE_LIMIT_MAX",
        "RATE_LIMIT_WINDOW_SECONDS",
        "UPSTREAM_TIMEOUT_SECONDS",
    ]
    for key in keys:
        monkeypatch.delenv(key, raising=False)


@pytest.fixture
def proxy_env_overrides(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("CACHE_MAX_AGE_SECONDS", "120")
    monkeypatch.setenv("RATE_LIMIT_MAX", "50")
    monkeypatch.setenv("RATE_LIMIT_WINDOW_SECONDS", "30")
    monkeypatch.setenv("UPSTREAM_TIMEOUT_SECONDS", "9")


@pytest.fixture
def proxy_env_invalid(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("CACHE_MAX_AGE_SECONDS", "oops")
    monkeypatch.setenv("RATE_LIMIT_MAX", "nope")
    monkeypatch.setenv("RATE_LIMIT_WINDOW_SECONDS", "bad")
    monkeypatch.setenv("UPSTREAM_TIMEOUT_SECONDS", "x")


@pytest.fixture
def proxy_config_from_env_default(clear_proxy_env: None) -> ProxyConfig:
    return ProxyConfig.from_env()


@pytest.fixture
def proxy_config_from_env_overrides(proxy_env_overrides: None) -> ProxyConfig:
    return ProxyConfig.from_env()


@pytest.fixture
def proxy_config_from_env_invalid(proxy_env_invalid: None) -> ProxyConfig:
    return ProxyConfig.from_env()


@pytest.fixture
def market_timestamp(utc_now: datetime) -> int:
    return int(utc_now.timestamp())


@pytest.fixture
def yahoo_payload_valid(market_timestamp: int) -> str:
    payload = {
        "quoteResponse": {
            "result": [
                {
                    "symbol": "EURUSD=X",
                    "regularMarketPrice": 1.25,
                    "regularMarketTime": market_timestamp,
                },
            ],
        },
    }
    return json.dumps(payload)


@pytest.fixture
def yahoo_payload_invalid_json() -> str:
    return "{invalid}"


@pytest.fixture
def yahoo_payload_malformed() -> str:
    return '{"quoteResponse":{"result":"oops"}}'


@pytest.fixture
def expected_yahoo_rate(utc_now: datetime) -> CurrencyRate:
    return CurrencyRate(
        quote="EUR",
        rate=1.25,
        fetched_at=utc_now,
    )


@pytest.fixture
def yahoo_payload_with_noise() -> str:
    payload = {
        "quoteResponse": {
            "result": [
                "invalid",
                {"symbol": "EURUSD=X", "regularMarketPrice": "nope"},
                {"symbol": "GBPUSD=X", "regularMarketPrice": 1.3},
            ],
        },
    }
    return json.dumps(payload)


@pytest.fixture
def yahoo_client() -> YahooFinanceCurrencyClient:
    return YahooFinanceCurrencyClient(timeout_seconds=1)


@pytest.fixture
def yahoo_client_with_session(yahoo_client: YahooFinanceCurrencyClient) -> YahooFinanceCurrencyClient:
    yahoo_client._cookie = "cookie=one"
    yahoo_client._crumb = "crumb"
    return yahoo_client


@pytest.fixture
def yahoo_repository_with_cache(
    fake_rates_client: FakeRatesClient,
    rates_cache: InMemoryRatesCache,
    proxy_config_default: ProxyConfig,
) -> YahooFinanceRatesRepository:
    return YahooFinanceRatesRepository(
        fake_rates_client,
        cache=rates_cache,
        config=proxy_config_default,
    )


@pytest.fixture
def yahoo_repository_with_cached_rates(
    yahoo_repository_with_cache: YahooFinanceRatesRepository,
    cache_key: str,
    cached_rates_valid: CachedRates,
    rates_cache: InMemoryRatesCache,
) -> YahooFinanceRatesRepository:
    rates_cache.set(cache_key, cached_rates_valid)
    return yahoo_repository_with_cache


@pytest.fixture
def yahoo_repository_no_cache(
    fake_rates_client: FakeRatesClient,
    rates_cache: InMemoryRatesCache,
    proxy_config_no_cache: ProxyConfig,
) -> YahooFinanceRatesRepository:
    return YahooFinanceRatesRepository(
        fake_rates_client,
        cache=rates_cache,
        config=proxy_config_no_cache,
    )
