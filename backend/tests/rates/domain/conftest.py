from datetime import datetime

import pytest

from rates.domain.entities import CurrencyRate


@pytest.fixture
def rate_with_naive_time(naive_datetime: datetime) -> CurrencyRate:
    return CurrencyRate(
        quote="GBP",
        rate=0.88,
        fetched_at=naive_datetime,
    )
