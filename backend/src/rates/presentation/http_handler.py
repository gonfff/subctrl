import json
from dataclasses import dataclass
from urllib.parse import parse_qs, urlsplit

from rates.application.dto import FetchRatesRequestDTO
from rates.application.fetch_rates_use_case import FetchRatesUseCase
from rates.domain.errors import RatesError, UpstreamError, ValidationError
from rates.domain.interfaces import RateLimiter
from rates.infrastructure.config import ProxyConfig


@dataclass(frozen=True)
class HttpResponse:
    status: int
    headers: dict[str, str]
    body: str | None = None


async def handle_request(
    *,
    method: str,
    headers: dict[str, str],
    url: str,
    rate_limiter: RateLimiter,
    use_case: FetchRatesUseCase,
    config: ProxyConfig,
) -> HttpResponse:
    path, query_params, client_ip = _parse_request(url, headers)
    path = _normalize_path(path)

    if path != "/v1/rates":
        return _error_response(
            status=404,
            code="not_found",
            message="Route not found.",
        )
    if method.upper() != "GET":
        return _error_response(
            status=405,
            code="method_not_allowed",
            message="Only GET is supported.",
            extra_headers={"Allow": "GET"},
        )

    try:
        rate_limit_status = rate_limiter.check(client_ip)
        if not rate_limit_status.allowed:
            extra_headers = {}
            if rate_limit_status.retry_after_seconds is not None:
                extra_headers["Retry-After"] = str(rate_limit_status.retry_after_seconds)
            return _error_response(
                status=429,
                code="rate_limited",
                message="Rate limit exceeded.",
                extra_headers=extra_headers,
            )

        request = _build_request_dto(query_params)

        result = await use_case.execute(request)
        cache_control = _cache_control(config.cache_max_age_seconds)
        body = result.snapshot.to_json()
        return HttpResponse(
            status=200,
            headers={
                "Content-Type": "application/json; charset=utf-8",
                "Cache-Control": cache_control,
            },
            body=body,
        )
    except ValidationError as exc:
        return _error_response(
            status=400,
            code="validation_error",
            message=exc.message,
            details=exc.details,
        )
    except UpstreamError as exc:
        return _error_response(
            status=502,
            code="upstream_error",
            message=exc.message,
        )
    except RatesError:
        return _error_response(
            status=500,
            code="unexpected_error",
            message="Unexpected error.",
        )


def _parse_request(
    url: str,
    headers: dict[str, str],
) -> tuple[str, dict[str, list[str]], str]:
    parsed = urlsplit(url)
    query_params = parse_qs(parsed.query)
    client_ip = _client_ip(headers)
    return parsed.path, query_params, client_ip


def _normalize_path(path: str) -> str:
    if path != "/" and path.endswith("/"):
        return path.rstrip("/")
    return path


def _client_ip(headers: dict[str, str]) -> str:
    forwarded_for = _header_value(headers, "cf-connecting-ip") or _header_value(
        headers,
        "x-forwarded-for",
    )
    if forwarded_for:
        return forwarded_for.split(",")[0].strip()
    return "unknown"


def _header_value(headers: dict[str, str], key: str) -> str | None:
    lowered_key = key.lower()
    for header_key, value in headers.items():
        if header_key.lower() == lowered_key:
            return value
    return None


def _build_request_dto(
    query_params: dict[str, list[str]],
) -> FetchRatesRequestDTO:
    base_values = query_params.get("base")
    quotes_values = query_params.get("quotes")
    if not base_values or not quotes_values:
        raise ValidationError(
            "Missing base or quotes query parameters.",
            details={"base": "Required", "quotes": "Required"},
        )
    base = base_values[-1]
    quotes = _collect_quotes(quotes_values)
    if not quotes:
        raise ValidationError(
            "At least one quote currency is required.",
            details={"quotes": "Provide at least one quote currency."},
        )
    return FetchRatesRequestDTO(
        base=base,
        quotes=tuple(quotes),
    )


def _cache_control(max_age_seconds: int) -> str:
    if max_age_seconds <= 0:
        return "no-store"
    return f"public, max-age={max_age_seconds}"


def _collect_quotes(values: list[str]) -> list[str]:
    quotes: list[str] = []
    for value in values:
        if val := value.strip():
            quotes.append(val)
    return quotes


def _error_response(
    *,
    status: int,
    code: str,
    message: str,
    details: dict[str, str] | None = None,
    extra_headers: dict[str, str] | None = None,
) -> HttpResponse:
    payload = {
        "error": {
            "code": code,
            "message": message,
            "details": details or {},
        },
    }
    headers = {
        "Content-Type": "application/json; charset=utf-8",
        "Cache-Control": "no-store",
    }
    if extra_headers:
        headers.update(extra_headers)
    return HttpResponse(
        status=status,
        headers=headers,
        body=json.dumps(payload, separators=(",", ":"), ensure_ascii=True),
    )
