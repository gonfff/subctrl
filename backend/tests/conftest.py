import sys
import types
from collections.abc import Awaitable, Callable
from datetime import UTC, datetime

import pytest


def _install_workers_stub() -> None:
    if "workers" in sys.modules:
        return

    class WorkersStub(types.ModuleType):
        fetch: Callable[..., Awaitable[None]]

    workers_stub = WorkersStub("workers")

    async def fetch(*_args: object, **_kwargs: object) -> None:
        raise RuntimeError("workers.fetch is not available in unit tests.")

    workers_stub.fetch = fetch
    sys.modules["workers"] = workers_stub


_install_workers_stub()


@pytest.fixture
def utc_now() -> datetime:
    return datetime(2026, 1, 23, 12, 0, tzinfo=UTC)


@pytest.fixture
def utc_past() -> datetime:
    return datetime(2026, 1, 23, 11, 59, tzinfo=UTC)


@pytest.fixture
def naive_datetime() -> datetime:
    return datetime(2026, 1, 23, 12, 0)
