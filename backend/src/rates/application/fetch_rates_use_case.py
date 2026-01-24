import re
from collections.abc import Iterable
from datetime import UTC, datetime

from rates.application.dto import FetchRatesRequestDTO, FetchRatesResponseDTO
from rates.domain.entities import RatesSnapshot
from rates.domain.errors import ValidationError
from rates.domain.interfaces import RatesRepository

_CODE_PATTERN = re.compile(r"^[A-Z]{3}$")


class FetchRatesUseCase:
    def __init__(
        self,
        repository: RatesRepository,
        max_quotes: int = 50,
        max_symbol_length: int = 3,
    ) -> None:
        self._repository = repository
        self._max_quotes = max_quotes
        self._max_symbol_length = max_symbol_length

    async def execute(
        self,
        request: FetchRatesRequestDTO,
    ) -> FetchRatesResponseDTO:
        normalized_base = self._normalize_code(request.base, "base")
        normalized_quotes = self._normalize_quotes(normalized_base, request.quotes)

        rates = await self._repository.fetch_rates(
            base=normalized_base,
            quotes=normalized_quotes,
        )
        snapshot = RatesSnapshot(
            base=normalized_base,
            rates=tuple(rates),
            as_of=datetime.now(UTC),
        )

        return FetchRatesResponseDTO(snapshot=snapshot)

    def _normalize_code(self, code: str, label: str) -> str:
        normalized = code.strip().upper()
        if len(normalized) > self._max_symbol_length:
            raise ValidationError(
                f"{label.capitalize()} currency code is too long.",
                details={label: f"Must be at most {self._max_symbol_length} characters."},
            )
        if not _CODE_PATTERN.match(normalized):
            raise ValidationError(
                f"Invalid {label} currency code.",
                details={label: "Must be a 3-letter ISO code."},
            )
        return normalized

    def _normalize_quotes(self, base: str, quotes: Iterable[str]) -> list[str]:
        normalized_quotes: list[str] = []
        for code in quotes:
            if not code.strip():
                continue
            normalized = self._normalize_code(code, "quotes")
            if normalized == base:
                continue
            normalized_quotes.append(normalized)
        if not normalized_quotes:
            raise ValidationError(
                "At least one quote currency is required.",
                details={"quotes": "Provide at least one quote currency."},
            )
        unique_quotes = sorted(set(normalized_quotes))
        if len(unique_quotes) > self._max_quotes:
            raise ValidationError(
                "Too many quote currencies requested.",
                details={"quotes": f"Maximum {self._max_quotes} quotes allowed."},
            )
        return unique_quotes
