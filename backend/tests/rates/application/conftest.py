import pytest

from rates.application.dto import FetchRatesRequestDTO
from rates.application.fetch_rates_use_case import FetchRatesUseCase
from rates.domain.entities import CurrencyRate


class CapturingRepository:
    def __init__(self, rates: list[CurrencyRate]) -> None:
        self._rates = list(rates)
        self.calls: list[tuple[str, list[str]]] = []

    async def fetch_rates(self, base: str, quotes: list[str]) -> list[CurrencyRate]:
        self.calls.append((base, list(quotes)))
        return list(self._rates)


@pytest.fixture
def capturing_repository(sample_rates: list[CurrencyRate]) -> CapturingRepository:
    return CapturingRepository(sample_rates)


@pytest.fixture
def fetch_rates_use_case(
    capturing_repository: CapturingRepository,
) -> FetchRatesUseCase:
    return FetchRatesUseCase(repository=capturing_repository)


@pytest.fixture
def request_valid() -> FetchRatesRequestDTO:
    return FetchRatesRequestDTO(
        base=" usd ",
        quotes=("eur", "USD", "jpy", " eur "),
    )


@pytest.fixture
def request_invalid_base() -> FetchRatesRequestDTO:
    return FetchRatesRequestDTO(
        base="us1",
        quotes=("eur",),
    )


@pytest.fixture
def request_empty_quotes() -> FetchRatesRequestDTO:
    return FetchRatesRequestDTO(
        base="usd",
        quotes=("   ",),
    )


@pytest.fixture
def request_only_base_quotes() -> FetchRatesRequestDTO:
    return FetchRatesRequestDTO(
        base="usd",
        quotes=("usd",),
    )
