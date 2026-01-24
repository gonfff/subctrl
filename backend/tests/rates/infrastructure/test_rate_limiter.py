import time

from rates.infrastructure.rate_limiter import InMemoryRateLimiter


def test_rate_limiter_blocks_after_max_requests(
    rate_limiter_one: InMemoryRateLimiter,
    client_id: str,
) -> None:
    first = rate_limiter_one.check(client_id)
    second = rate_limiter_one.check(client_id)

    assert first.allowed is True
    assert second.allowed is False
    assert second.retry_after_seconds is not None


def test_rate_limiter_resets_after_window(
    client_id: str,
) -> None:
    limiter = InMemoryRateLimiter(max_requests=1, window_seconds=1)
    limiter.check(client_id)
    time.sleep(1.1)

    status = limiter.check(client_id)

    assert status.allowed is True


def test_rate_limiter_eviction_removes_old_entries() -> None:
    limiter = InMemoryRateLimiter(max_requests=1, window_seconds=60, max_entries=1)

    limiter.check("client-1")
    limiter.check("client-2")

    assert "client-1" not in limiter._entries
    assert "client-2" in limiter._entries
