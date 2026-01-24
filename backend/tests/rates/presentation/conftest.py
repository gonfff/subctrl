import pytest

from rates.application.fetch_rates_use_case import FetchRatesUseCase
from rates.domain.entities import CurrencyRate
from rates.domain.errors import RatesError, UpstreamError, ValidationError
from rates.domain.interfaces import RateLimitStatus


class FakeRepository:
    def __init__(self, rates: list[CurrencyRate]) -> None:
        self._rates = list(rates)

    async def fetch_rates(self, base: str, quotes: list[str]) -> list[CurrencyRate]:
        return list(self._rates)


class FakeRateLimiter:
    def __init__(self, status: RateLimitStatus) -> None:
        self._status = status
        self.last_client_id: str | None = None

    def check(self, client_id: str) -> RateLimitStatus:
        self.last_client_id = client_id
        return self._status


class FakeUseCase:
    def __init__(self, exc: Exception) -> None:
        self._exc = exc

    async def execute(self, request: object) -> None:
        raise self._exc


@pytest.fixture
def method_get() -> str:
    return "GET"


@pytest.fixture
def method_post() -> str:
    return "POST"


@pytest.fixture
def repository(sample_rates: list[CurrencyRate]) -> FakeRepository:
    return FakeRepository(sample_rates)


@pytest.fixture
def use_case(repository: FakeRepository) -> FetchRatesUseCase:
    return FetchRatesUseCase(repository=repository)


@pytest.fixture
def rate_limiter_allow() -> FakeRateLimiter:
    return FakeRateLimiter(RateLimitStatus(allowed=True))


@pytest.fixture
def rate_limiter_blocking() -> FakeRateLimiter:
    return FakeRateLimiter(RateLimitStatus(allowed=False, retry_after_seconds=30))


@pytest.fixture
def rate_limiter_spy() -> FakeRateLimiter:
    return FakeRateLimiter(RateLimitStatus(allowed=True))


@pytest.fixture
def use_case_validation_error() -> FakeUseCase:
    return FakeUseCase(ValidationError("Invalid request", details={"base": "Required"}))


@pytest.fixture
def use_case_upstream_error() -> FakeUseCase:
    return FakeUseCase(UpstreamError("Upstream down"))


@pytest.fixture
def use_case_unexpected_error() -> FakeUseCase:
    return FakeUseCase(RatesError("boom"))
