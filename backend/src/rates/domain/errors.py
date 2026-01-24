class RatesError(Exception):
    pass


class ValidationError(RatesError):
    def __init__(self, message: str, details: dict[str, str] | None = None) -> None:
        super().__init__(message)
        self.message = message
        self.details = details or {}


class RateLimitError(RatesError):
    def __init__(self, message: str, retry_after_seconds: int | None = None) -> None:
        super().__init__(message)
        self.message = message
        self.retry_after_seconds = retry_after_seconds


class UpstreamError(RatesError):
    def __init__(self, message: str) -> None:
        super().__init__(message)
        self.message = message
