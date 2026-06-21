import os

from redis import Redis


def _redis_url() -> str:
    explicit_url = os.getenv("REDIS_URL")
    if explicit_url:
        return explicit_url

    host = os.getenv("REDIS_HOST", "localhost")
    port = os.getenv("REDIS_PORT", "6379")
    database = os.getenv("REDIS_DB", "0")

    return f"redis://{host}:{port}/{database}"


redis_client = Redis.from_url(
    _redis_url(),
    decode_responses=True,
    health_check_interval=30,
    socket_connect_timeout=int(os.getenv("REDIS_CONNECT_TIMEOUT_SECONDS", "5")),
    socket_timeout=int(os.getenv("REDIS_SOCKET_TIMEOUT_SECONDS", "5")),
)


def check_redis() -> bool:
    return bool(redis_client.ping())
