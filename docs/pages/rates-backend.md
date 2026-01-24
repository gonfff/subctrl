# Currency Rates Backend

Subctrl runs its own backend service for currency rates. The Flutter app talks
to it through `ProxyCurrencyRatesClient`.

## API Contract

`GET /v1/rates`

Query parameters:

- `base`: 3-letter ISO code (example: `USD`).
- `quotes`: comma-separated 3-letter codes (example: `EUR,GBP`).

Response (`200`):

```json
{
  "base": "USD",
  "rates": [
    {
      "quote": "EUR",
      "rate": 1.08,
      "fetched_at": "2026-01-23T12:00:00Z"
    }
  ],
  "provider": "yahoo_finance",
  "as_of": "2026-01-23T12:00:05Z"
}
```

Errors:

- `400` validation or unsupported currencies.
- `429` rate limit exceeded.
- `502` upstream fetch failure.

Error body:

```json
{
  "error": {
    "code": "validation_error",
    "message": "...",
    "details": {}
  }
}
```

Caching:

- Responses include `Cache-Control` and `ETag` headers.
- Send `If-None-Match` to receive `304 Not Modified`.

Refresh cadence defaults to 5 minutes (`CACHE_MAX_AGE_SECONDS=300`).

Supported currencies:

- By default the backend accepts any 3-letter ISO code.
- Set `SUPPORTED_CURRENCY_CODES` (comma-separated) to restrict supported codes.

## Configuration

Environment variables:

- `CACHE_MAX_AGE_SECONDS` (default `300`)
- `RATE_LIMIT_MAX` (default `60`)
- `RATE_LIMIT_WINDOW_SECONDS` (default `60`)
- `UPSTREAM_TIMEOUT_SECONDS` (default `6`)

Flutter client override:

- `SUBCTRL_RATES_URL` (compile-time Dart define) to point the app at the backend base URL.

## Cloudflare Workers Deployment

From `backend/`:

```bash
wrangler deploy
```

Required secrets/vars:

- `CF_API_TOKEN` and `CF_ACCOUNT_ID` configured in CI.
- Configure the environment variables above via `wrangler.toml` or the Cloudflare dashboard.

CI deploys the worker on pushes to `master` when `backend/` changes.
