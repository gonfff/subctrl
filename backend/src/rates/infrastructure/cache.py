from datetime import UTC, datetime

from rates.domain.interfaces import CachedRates, RatesCache


class InMemoryRatesCache(RatesCache):
    def __init__(self, max_entries: int = 1024) -> None:
        self._store: dict[str, CachedRates] = {}
        self._max_entries = max_entries

    def get(self, key: str) -> CachedRates | None:
        now = datetime.now(UTC)
        self._prune_expired(now)
        cached = self._store.get(key)
        if cached is None:
            return None
        if cached.expires_at <= now:
            self._store.pop(key, None)
            return None
        return cached

    def set(self, key: str, value: CachedRates) -> None:
        self._prune_expired(datetime.now(UTC))
        self._store[key] = value
        self._evict_excess()

    def _prune_expired(self, now: datetime) -> None:
        expired_keys = [entry_key for entry_key, entry in self._store.items() if entry.expires_at <= now]
        for entry_key in expired_keys:
            self._store.pop(entry_key, None)

    def _evict_excess(self) -> None:
        if self._max_entries <= 0:
            self._store.clear()
            return
        if len(self._store) <= self._max_entries:
            return
        excess = len(self._store) - self._max_entries
        items = sorted(self._store.items(), key=lambda item: item[1].expires_at)
        for key, _ in items[:excess]:
            self._store.pop(key, None)
