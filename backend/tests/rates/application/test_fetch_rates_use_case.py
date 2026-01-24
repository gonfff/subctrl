from datetime import UTC, datetime
from typing import Any

import pytest

from rates.application.dto import FetchRatesRequestDTO
from rates.application.fetch_rates_use_case import FetchRatesUseCase
from rates.domain.entities import CurrencyRate
from rates.domain.errors import ValidationError


async def test_execute_normalizes_and_calls_repository(
    fetch_rates_use_case: FetchRatesUseCase,
    capturing_repository: Any,
    request_valid: FetchRatesRequestDTO,
    sample_rates: list[CurrencyRate],
) -> None:
    before = datetime.now(UTC)
    response = await fetch_rates_use_case.execute(request_valid)
    after = datetime.now(UTC)

    assert capturing_repository.calls == [("USD", ["EUR", "JPY"])]
    assert response.snapshot.base == "USD"
    assert response.snapshot.rates == tuple(sample_rates)
    assert before <= response.snapshot.as_of <= after


async def test_execute_rejects_invalid_base(
    fetch_rates_use_case: FetchRatesUseCase,
    request_invalid_base: FetchRatesRequestDTO,
) -> None:
    with pytest.raises(ValidationError):
        await fetch_rates_use_case.execute(request_invalid_base)


async def test_execute_rejects_empty_quotes(
    fetch_rates_use_case: FetchRatesUseCase,
    request_empty_quotes: FetchRatesRequestDTO,
) -> None:
    with pytest.raises(ValidationError):
        await fetch_rates_use_case.execute(request_empty_quotes)


async def test_execute_rejects_only_base_quotes(
    fetch_rates_use_case: FetchRatesUseCase,
    request_only_base_quotes: FetchRatesRequestDTO,
) -> None:
    with pytest.raises(ValidationError):
        await fetch_rates_use_case.execute(request_only_base_quotes)


async def test_execute_rejects_too_many_quotes(
    capturing_repository: Any,
) -> None:
    use_case = FetchRatesUseCase(repository=capturing_repository, max_quotes=1)
    request = FetchRatesRequestDTO(base="usd", quotes=("eur", "jpy"))

    with pytest.raises(ValidationError):
        await use_case.execute(request)


async def test_execute_rejects_too_long_code(
    capturing_repository: Any,
) -> None:
    use_case = FetchRatesUseCase(repository=capturing_repository, max_symbol_length=2)
    request = FetchRatesRequestDTO(base="usd", quotes=("eur",))

    with pytest.raises(ValidationError):
        await use_case.execute(request)
