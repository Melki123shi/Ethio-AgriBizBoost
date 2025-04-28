"""
Rate limiting implementation for the API.
Uses slowapi to limit request frequency from the same IP address.
"""

from slowapi import Limiter
from slowapi.util import get_remote_address
import config

# Create a limiter instance that will track requests by IP address
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri=config.MONGO_URI if config.APP_ENV == "production" else None
)

# Rate limiting documentation
RATE_LIMIT_DOCS = {
    "general": "Default rate limits: 200 requests per day, 50 requests per hour",
    "authentication": "Auth endpoints are limited to 5 requests per minute to prevent brute force attacks",
    "api": "General API endpoints are limited to 30 requests per minute"
} 