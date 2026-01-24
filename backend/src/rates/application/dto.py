from collections.abc import Sequence
from dataclasses import dataclass

from rates.domain.entities import RatesSnapshot


@dataclass(frozen=True)
class FetchRatesRequestDTO:
    base: str
    quotes: Sequence[str]


@dataclass(frozen=True)
class FetchRatesResponseDTO:
    snapshot: RatesSnapshot
