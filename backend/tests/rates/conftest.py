from datetime import datetime

import pytest

from rates.domain.entities import CurrencyRate, RatesSnapshot
from rates.infrastructure.config import ProxyConfig


@pytest.fixture
def sample_rate(utc_past: datetime) -> CurrencyRate:
    return CurrencyRate(
        quote="EUR",
        rate=1.12,
        fetched_at=utc_past,
    )


@pytest.fixture
def sample_rates(sample_rate: CurrencyRate) -> list[CurrencyRate]:
    return [sample_rate]


@pytest.fixture
def sample_snapshot(utc_now: datetime, sample_rates: list[CurrencyRate]) -> RatesSnapshot:
    return RatesSnapshot(
        base="USD",
        rates=tuple(sample_rates),
        as_of=utc_now,
    )


@pytest.fixture
def snapshot_expected_dict(sample_snapshot: RatesSnapshot) -> dict[str, object]:
    return {
        "base": "USD",
        "rates": [
            {
                "quote": "EUR",
                "rate": 1.12,
                "fetched_at": "2026-01-23T11:59:00Z",
            },
        ],
        "as_of": "2026-01-23T12:00:00Z",
    }


@pytest.fixture
def snapshot_expected_json(snapshot_expected_dict: dict[str, object]) -> str:
    return (
        '{"as_of":"2026-01-23T12:00:00Z","base":"USD","rates":'
        '[{"fetched_at":"2026-01-23T11:59:00Z","quote":"EUR","rate":1.12}]}'
    )


@pytest.fixture
def proxy_config_default() -> ProxyConfig:
    return ProxyConfig(
        cache_max_age_seconds=300,
        rate_limit_max=50,
        rate_limit_window_seconds=60,
        upstream_timeout_seconds=5,
    )


@pytest.fixture
def proxy_config_no_cache() -> ProxyConfig:
    return ProxyConfig(
        cache_max_age_seconds=0,
        rate_limit_max=50,
        rate_limit_window_seconds=60,
        upstream_timeout_seconds=5,
    )


@pytest.fixture
def request_url() -> str:
    return "https://example.com/v1/rates?base=usd&quotes=eur"


@pytest.fixture
def request_url_trailing_slash() -> str:
    return "https://example.com/v1/rates/?base=usd&quotes=eur"


@pytest.fixture
def request_url_missing_params() -> str:
    return "https://example.com/v1/rates"


@pytest.fixture
def request_url_not_found() -> str:
    return "https://example.com/v1/other"


@pytest.fixture
def headers_empty() -> dict[str, str]:
    return {}


@pytest.fixture
def headers_forwarded_ip() -> dict[str, str]:
    return {"CF-Connecting-IP": "203.0.113.5"}


@pytest.fixture
def yahoo_symbol_map() -> dict[str, str]:
    return {"EURUSD=X": "EUR"}
