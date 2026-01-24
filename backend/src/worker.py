from workers import Request, Response, WorkerEntrypoint

from rates.dependencies import build_proxy_config, build_rate_limiter, build_rates_use_case
from rates.presentation.http_handler import handle_request

_CONFIG = build_proxy_config()
_USE_CASE = build_rates_use_case(_CONFIG)
_RATE_LIMITER = build_rate_limiter(_CONFIG)


class Default(WorkerEntrypoint):
    async def fetch(self, request: Request) -> Response:
        headers = dict(request.headers)
        result = await handle_request(
            method=request.method,
            headers=headers,
            url=request.url,
            rate_limiter=_RATE_LIMITER,
            use_case=_USE_CASE,
            config=_CONFIG,
        )
        if result.body is None:
            return Response(status=result.status, headers=result.headers)
        return Response(result.body, status=result.status, headers=result.headers)
