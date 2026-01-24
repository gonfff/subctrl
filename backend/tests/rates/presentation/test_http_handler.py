import json
from datetime import datetime
from typing import Any

from rates.application.fetch_rates_use_case import FetchRatesUseCase
from rates.infrastructure.config import ProxyConfig
from rates.presentation.http_handler import handle_request


async def test_handle_request_success_returns_json(
    request_url: str,
    headers_forwarded_ip: dict[str, str],
    method_get: str,
    rate_limiter_allow: Any,
    use_case: FetchRatesUseCase,
    proxy_config_default: ProxyConfig,
    sample_rates: Any,
) -> None:
    response = await handle_request(
        method=method_get,
        headers=headers_forwarded_ip,
        url=request_url,
        rate_limiter=rate_limiter_allow,
        use_case=use_case,
        config=proxy_config_default,
    )

    assert response.status == 200
    assert response.headers["Content-Type"] == "application/json; charset=utf-8"
    assert response.headers["Cache-Control"] == "public, max-age=300"
    payload = json.loads(response.body or "{}")
    assert payload["base"] == "USD"
    assert payload["rates"] == [rate.to_dict() for rate in sample_rates]
    assert isinstance(payload["as_of"], str)
    assert payload["as_of"]
    datetime.fromisoformat(payload["as_of"].replace("Z", "+00:00"))
    assert rate_limiter_allow.last_client_id == "203.0.113.5"


async def test_handle_request_trailing_slash(
    request_url_trailing_slash: str,
    headers_empty: dict[str, str],
    method_get: str,
    rate_limiter_spy: Any,
    use_case: FetchRatesUseCase,
    proxy_config_default: ProxyConfig,
) -> None:
    response = await handle_request(
        method=method_get,
        headers=headers_empty,
        url=request_url_trailing_slash,
        rate_limiter=rate_limiter_spy,
        use_case=use_case,
        config=proxy_config_default,
    )

    assert response.status == 200
    assert rate_limiter_spy.last_client_id == "unknown"


async def test_handle_request_not_found(
    request_url_not_found: str,
    headers_empty: dict[str, str],
    method_get: str,
    rate_limiter_allow: Any,
    use_case: FetchRatesUseCase,
    proxy_config_default: ProxyConfig,
) -> None:
    response = await handle_request(
        method=method_get,
        headers=headers_empty,
        url=request_url_not_found,
        rate_limiter=rate_limiter_allow,
        use_case=use_case,
        config=proxy_config_default,
    )

    assert response.status == 404
    payload = json.loads(response.body or "{}")
    assert payload["error"]["code"] == "not_found"


async def test_handle_request_method_not_allowed(
    request_url: str,
    headers_empty: dict[str, str],
    method_post: str,
    rate_limiter_allow: Any,
    use_case: FetchRatesUseCase,
    proxy_config_default: ProxyConfig,
) -> None:
    response = await handle_request(
        method=method_post,
        headers=headers_empty,
        url=request_url,
        rate_limiter=rate_limiter_allow,
        use_case=use_case,
        config=proxy_config_default,
    )

    assert response.status == 405
    assert response.headers["Allow"] == "GET"


async def test_handle_request_rate_limited(
    request_url: str,
    headers_empty: dict[str, str],
    method_get: str,
    rate_limiter_blocking: Any,
    use_case: FetchRatesUseCase,
    proxy_config_default: ProxyConfig,
) -> None:
    response = await handle_request(
        method=method_get,
        headers=headers_empty,
        url=request_url,
        rate_limiter=rate_limiter_blocking,
        use_case=use_case,
        config=proxy_config_default,
    )

    assert response.status == 429
    assert response.headers["Retry-After"] == "30"


async def test_handle_request_validation_error(
    request_url_missing_params: str,
    headers_empty: dict[str, str],
    method_get: str,
    rate_limiter_allow: Any,
    use_case: FetchRatesUseCase,
    proxy_config_default: ProxyConfig,
) -> None:
    response = await handle_request(
        method=method_get,
        headers=headers_empty,
        url=request_url_missing_params,
        rate_limiter=rate_limiter_allow,
        use_case=use_case,
        config=proxy_config_default,
    )

    assert response.status == 400
    payload = json.loads(response.body or "{}")
    assert payload["error"]["code"] == "validation_error"
    assert payload["error"]["details"] == {"base": "Required", "quotes": "Required"}


async def test_handle_request_use_case_validation_error(
    request_url: str,
    headers_empty: dict[str, str],
    method_get: str,
    rate_limiter_allow: Any,
    use_case_validation_error: Any,
    proxy_config_default: ProxyConfig,
) -> None:
    response = await handle_request(
        method=method_get,
        headers=headers_empty,
        url=request_url,
        rate_limiter=rate_limiter_allow,
        use_case=use_case_validation_error,
        config=proxy_config_default,
    )

    assert response.status == 400
    payload = json.loads(response.body or "{}")
    assert payload["error"]["code"] == "validation_error"
    assert payload["error"]["details"] == {"base": "Required"}


async def test_handle_request_upstream_error(
    request_url: str,
    headers_empty: dict[str, str],
    method_get: str,
    rate_limiter_allow: Any,
    use_case_upstream_error: Any,
    proxy_config_default: ProxyConfig,
) -> None:
    response = await handle_request(
        method=method_get,
        headers=headers_empty,
        url=request_url,
        rate_limiter=rate_limiter_allow,
        use_case=use_case_upstream_error,
        config=proxy_config_default,
    )

    assert response.status == 502
    payload = json.loads(response.body or "{}")
    assert payload["error"]["code"] == "upstream_error"


async def test_handle_request_unexpected_error(
    request_url: str,
    headers_empty: dict[str, str],
    method_get: str,
    rate_limiter_allow: Any,
    use_case_unexpected_error: Any,
    proxy_config_default: ProxyConfig,
) -> None:
    response = await handle_request(
        method=method_get,
        headers=headers_empty,
        url=request_url,
        rate_limiter=rate_limiter_allow,
        use_case=use_case_unexpected_error,
        config=proxy_config_default,
    )

    assert response.status == 500
    payload = json.loads(response.body or "{}")
    assert payload["error"]["code"] == "unexpected_error"
