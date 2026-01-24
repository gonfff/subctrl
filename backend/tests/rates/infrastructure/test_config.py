from rates.infrastructure.config import ProxyConfig


def test_proxy_config_defaults(proxy_config_from_env_default: ProxyConfig) -> None:
    assert proxy_config_from_env_default.cache_max_age_seconds == 10800
    assert proxy_config_from_env_default.rate_limit_max == 50
    assert proxy_config_from_env_default.rate_limit_window_seconds == 60
    assert proxy_config_from_env_default.upstream_timeout_seconds == 6


def test_proxy_config_env_overrides(proxy_config_from_env_overrides: ProxyConfig) -> None:
    assert proxy_config_from_env_overrides.cache_max_age_seconds == 120
    assert proxy_config_from_env_overrides.rate_limit_max == 50
    assert proxy_config_from_env_overrides.rate_limit_window_seconds == 30
    assert proxy_config_from_env_overrides.upstream_timeout_seconds == 9


def test_proxy_config_invalid_env(proxy_config_from_env_invalid: ProxyConfig) -> None:
    assert proxy_config_from_env_invalid.cache_max_age_seconds == 10800
    assert proxy_config_from_env_invalid.rate_limit_max == 50
    assert proxy_config_from_env_invalid.rate_limit_window_seconds == 60
    assert proxy_config_from_env_invalid.upstream_timeout_seconds == 6
