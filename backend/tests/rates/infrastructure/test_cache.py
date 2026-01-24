from datetime import UTC, datetime, timedelta
from typing import Any

from rates.domain.interfaces import CachedRates
from rates.infrastructure.cache import InMemoryRatesCache


def test_cache_returns_valid_entry(
    rates_cache: InMemoryRatesCache,
    cache_key: str,
    sample_rates: Any,
) -> None:
    now = datetime.now(UTC)
    cached_rates_valid = CachedRates(
        rates=tuple(sample_rates),
        expires_at=now + timedelta(seconds=60),
    )
    rates_cache.set(cache_key, cached_rates_valid)

    assert rates_cache.get(cache_key) == cached_rates_valid


def test_cache_removes_expired_entry(
    rates_cache: InMemoryRatesCache,
    cache_key: str,
    sample_rates: Any,
) -> None:
    now = datetime.now(UTC)
    cached_rates_expired = CachedRates(
        rates=tuple(sample_rates),
        expires_at=now - timedelta(seconds=1),
    )
    rates_cache.set(cache_key, cached_rates_expired)

    assert rates_cache.get(cache_key) is None
    assert cache_key not in rates_cache._store


def test_cache_eviction_removes_oldest_expiry(
    sample_rates: Any,
) -> None:
    now = datetime.now(UTC)
    rates_cache = InMemoryRatesCache(max_entries=1)
    first = CachedRates(
        rates=tuple(sample_rates),
        expires_at=now + timedelta(seconds=30),
    )
    second = CachedRates(
        rates=tuple(sample_rates),
        expires_at=now + timedelta(seconds=60),
    )

    rates_cache.set("USD:EUR", first)
    rates_cache.set("USD:JPY", second)

    assert rates_cache.get("USD:EUR") is None
    assert rates_cache.get("USD:JPY") == second
