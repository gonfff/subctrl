from dataclasses import dataclass
from datetime import UTC, datetime, timedelta

from rates.domain.interfaces import RateLimiter, RateLimitStatus


@dataclass
class _RateLimitEntry:
    window_start: datetime
    count: int


class InMemoryRateLimiter(RateLimiter):
    def __init__(
        self,
        max_requests: int,
        window_seconds: int,
        max_entries: int = 1024,
    ) -> None:
        self._max_requests = max_requests
        self._window = timedelta(seconds=window_seconds)
        self._entries: dict[str, _RateLimitEntry] = {}
        self._max_entries = max_entries

    def check(self, client_id: str) -> RateLimitStatus:
        now = datetime.now(UTC)
        self._prune_entries(now)
        entry = self._entries.get(client_id)

        if entry is None or now - entry.window_start >= self._window:
            entry = _RateLimitEntry(window_start=now, count=0)

        if entry.count >= self._max_requests:
            retry_after = int(
                max(
                    0,
                    (entry.window_start + self._window - now).total_seconds(),
                ),
            )
            self._entries[client_id] = entry
            return RateLimitStatus(allowed=False, retry_after_seconds=retry_after)

        entry.count += 1
        self._entries[client_id] = entry
        self._evict_excess()
        return RateLimitStatus(allowed=True)

    def _prune_entries(self, now: datetime) -> None:
        expired_keys = [
            entry_key for entry_key, entry in self._entries.items() if now - entry.window_start >= self._window
        ]
        for entry_key in expired_keys:
            self._entries.pop(entry_key, None)

    def _evict_excess(self) -> None:
        if self._max_entries <= 0:
            self._entries.clear()
            return
        if len(self._entries) <= self._max_entries:
            return
        excess = len(self._entries) - self._max_entries
        items = sorted(
            self._entries.items(),
            key=lambda item: (item[1].window_start, item[0]),
        )
        for key, _ in items[:excess]:
            self._entries.pop(key, None)
