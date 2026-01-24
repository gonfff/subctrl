import os
from dataclasses import dataclass


@dataclass(frozen=True)
class ProxyConfig:
    cache_max_age_seconds: int
    rate_limit_max: int
    rate_limit_window_seconds: int
    upstream_timeout_seconds: int

    @classmethod
    def from_env(cls) -> "ProxyConfig":
        return cls(
            cache_max_age_seconds=_read_int("CACHE_MAX_AGE_SECONDS", 3 * 60 * 60),
            rate_limit_max=_read_int("RATE_LIMIT_MAX", 50),
            rate_limit_window_seconds=_read_int("RATE_LIMIT_WINDOW_SECONDS", 60),
            upstream_timeout_seconds=_read_int("UPSTREAM_TIMEOUT_SECONDS", 6),
        )


def _read_int(key: str, default: int) -> int:
    raw = os.getenv(key)
    if raw is None:
        return default
    try:
        return int(raw)
    except ValueError:
        return default
