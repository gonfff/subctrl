from collections.abc import Sequence
from dataclasses import dataclass
from datetime import datetime
from typing import Protocol

from rates.domain.entities import CurrencyRate


@dataclass(frozen=True)
class CachedRates:
    rates: Sequence[CurrencyRate]
    expires_at: datetime


class RatesRepository(Protocol):
    async def fetch_rates(self, base: str, quotes: list[str]) -> list[CurrencyRate]: ...


@dataclass(frozen=True)
class RateLimitStatus:
    allowed: bool
    retry_after_seconds: int | None = None


class RateLimiter(Protocol):
    def check(self, client_id: str) -> RateLimitStatus: ...


class RatesCache(Protocol):
    def get(self, key: str) -> CachedRates | None: ...

    def set(self, key: str, value: CachedRates) -> None: ...
