import json
from dataclasses import dataclass
from datetime import UTC, datetime


@dataclass(frozen=True)
class CurrencyRate:
    quote: str
    rate: float
    fetched_at: datetime

    def __post_init__(self) -> None:
        object.__setattr__(self, "fetched_at", _ensure_utc(self.fetched_at))

    def to_dict(self) -> dict[str, object]:
        return {
            "quote": self.quote,
            "rate": self.rate,
            "fetched_at": self.fetched_at.isoformat().replace("+00:00", "Z"),
        }


@dataclass(frozen=True)
class RatesSnapshot:
    base: str
    rates: tuple[CurrencyRate, ...]
    as_of: datetime

    def __post_init__(self) -> None:
        object.__setattr__(self, "as_of", _ensure_utc(self.as_of))

    def to_dict(self) -> dict[str, object]:
        return {
            "base": self.base,
            "rates": [rate.to_dict() for rate in self.rates],
            "as_of": self.as_of.isoformat().replace("+00:00", "Z"),
        }

    def to_json(self) -> str:
        payload = self.to_dict()
        return json.dumps(payload, separators=(",", ":"), sort_keys=True, ensure_ascii=True)


def _ensure_utc(value: datetime) -> datetime:
    if value.tzinfo is None:
        return value.replace(tzinfo=UTC)
    return value.astimezone(UTC)
