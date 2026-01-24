from datetime import UTC

from rates.domain.entities import CurrencyRate, RatesSnapshot


def test_currency_rate_normalizes_naive_datetime(rate_with_naive_time: CurrencyRate) -> None:
    assert rate_with_naive_time.fetched_at.tzinfo is UTC


def test_currency_rate_to_dict(sample_rate: CurrencyRate) -> None:
    payload = sample_rate.to_dict()

    assert payload["quote"] == "EUR"
    assert payload["rate"] == 1.12
    assert payload["fetched_at"] == "2026-01-23T11:59:00Z"


def test_snapshot_to_dict(
    sample_snapshot: RatesSnapshot,
    snapshot_expected_dict: dict[str, object],
) -> None:
    assert sample_snapshot.to_dict() == snapshot_expected_dict


def test_snapshot_to_json(
    sample_snapshot: RatesSnapshot,
    snapshot_expected_json: str,
) -> None:
    assert sample_snapshot.to_json() == snapshot_expected_json
