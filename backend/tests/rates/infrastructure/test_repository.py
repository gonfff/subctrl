from datetime import UTC, datetime, timedelta
from typing import Any

from rates.domain.entities import CurrencyRate
from rates.domain.interfaces import CachedRates
from rates.infrastructure.cache import InMemoryRatesCache
from rates.infrastructure.config import ProxyConfig
from rates.infrastructure.yahoo_finance_repository import YahooFinanceRatesRepository


async def test_repository_caches_rates(
    yahoo_repository_with_cache: YahooFinanceRatesRepository,
    cache_key: str,
    fake_rates_client: Any,
    rates_cache: InMemoryRatesCache,
    base_currency: str,
    quote_currencies: list[str],
    sample_rates: list[CurrencyRate],
) -> None:
    rates = await yahoo_repository_with_cache.fetch_rates(
        base=base_currency,
        quotes=quote_currencies,
    )

    assert rates == sample_rates
    assert fake_rates_client.calls == [("USD", ["EUR"])]
    assert rates_cache.get(cache_key) is not None


async def test_repository_uses_cached_rates(
    yahoo_repository_with_cached_rates: YahooFinanceRatesRepository,
    fake_rates_client: Any,
    base_currency: str,
    quote_currencies: list[str],
    sample_rates: list[CurrencyRate],
) -> None:
    rates = await yahoo_repository_with_cached_rates.fetch_rates(
        base=base_currency,
        quotes=quote_currencies,
    )

    assert rates == sample_rates
    assert fake_rates_client.calls == []


async def test_repository_skips_cache_when_disabled(
    yahoo_repository_no_cache: YahooFinanceRatesRepository,
    rates_cache: InMemoryRatesCache,
    cache_key: str,
    fake_rates_client: Any,
    base_currency: str,
    quote_currencies: list[str],
    sample_rates: list[CurrencyRate],
) -> None:
    rates = await yahoo_repository_no_cache.fetch_rates(
        base=base_currency,
        quotes=quote_currencies,
    )

    assert rates == sample_rates
    assert fake_rates_client.calls == [("USD", ["EUR"])]
    assert rates_cache.get(cache_key) is None


async def test_repository_merges_cached_and_fetched_rates(
    fake_rates_client_factory: Any,
    rates_cache: InMemoryRatesCache,
    proxy_config_default: ProxyConfig,
) -> None:
    now = datetime.now(UTC)
    cached_rate = CurrencyRate(quote="EUR", rate=1.12, fetched_at=now)
    fetched_rate = CurrencyRate(quote="GBP", rate=1.31, fetched_at=now)
    fake_client = fake_rates_client_factory([cached_rate, fetched_rate])
    repository = YahooFinanceRatesRepository(
        fake_client,
        cache=rates_cache,
        config=proxy_config_default,
    )

    rates_cache.set(
        "USD:EUR",
        CachedRates(
            rates=(cached_rate,),
            expires_at=now + timedelta(seconds=60),
        ),
    )

    rates = await repository.fetch_rates(base="USD", quotes=["EUR", "GBP"])

    assert rates == [cached_rate, fetched_rate]
    assert fake_client.calls == [("USD", ["GBP"])]
    assert rates_cache.get("USD:GBP") is not None
