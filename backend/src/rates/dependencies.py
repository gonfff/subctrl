from rates.application.fetch_rates_use_case import FetchRatesUseCase
from rates.infrastructure.cache import InMemoryRatesCache
from rates.infrastructure.config import ProxyConfig
from rates.infrastructure.rate_limiter import InMemoryRateLimiter
from rates.infrastructure.yahoo_finance_client import YahooFinanceCurrencyClient
from rates.infrastructure.yahoo_finance_repository import YahooFinanceRatesRepository


def build_proxy_config() -> ProxyConfig:
    return ProxyConfig.from_env()


def build_rate_limiter(config: ProxyConfig) -> InMemoryRateLimiter:
    return InMemoryRateLimiter(
        max_requests=config.rate_limit_max,
        window_seconds=config.rate_limit_window_seconds,
    )


def build_rates_use_case(config: ProxyConfig) -> FetchRatesUseCase:
    cache = InMemoryRatesCache()
    yahoo_client = YahooFinanceCurrencyClient(
        timeout_seconds=config.upstream_timeout_seconds,
    )
    repository = YahooFinanceRatesRepository(
        yahoo_client,
        cache=cache,
        config=config,
    )
    return FetchRatesUseCase(
        repository=repository,
    )
