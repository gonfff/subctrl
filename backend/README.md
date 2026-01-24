# Subctrl Rates Proxy

In the future, I might separate this into a separate service.

Local development uses uv and FastAPI.

```bash
uv sync
uv tool run --from workers-py pywrangler dev
```

The API is versioned under `/v1` and expects `base` + `quotes` query params.

## Configuration

Backend details and deployment instructions live in `docs/pages/proxy-backend.md`.

Default proxy configuration (from `backend/wrangler.jsonc`):

- `CACHE_MAX_AGE_SECONDS=10800` (3 hours, cache TTL for `/v1/rates` responses).
- `RATE_LIMIT_MAX=50` (max requests per IP in the window).
- `RATE_LIMIT_WINDOW_SECONDS=60` (rate limit window in seconds).
- `UPSTREAM_TIMEOUT_SECONDS=6` (timeout for Yahoo upstream requests).


# [tool.uv.scripts]
# format = "ruff check --select I --fix . && ruff format ."
# lint = "ruff check . && mypy src"
