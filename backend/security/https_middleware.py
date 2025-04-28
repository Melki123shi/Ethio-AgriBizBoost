"""
HTTPS enforcement middleware.
Redirects HTTP requests to HTTPS in production environments.
Currently disabled by default.
"""

from starlette.middleware.base import BaseHTTPMiddleware
from fastapi import Request, Response
from starlette.datastructures import URL
from starlette.responses import RedirectResponse
import config

class HTTPSRedirectMiddleware(BaseHTTPMiddleware):
    """
    Middleware to redirect HTTP requests to HTTPS.
    Only applied in production environment.
    
    NOTE: This middleware is currently disabled by default.
    To enable, set ENFORCE_HTTPS=True in your .env file and
    uncomment the middleware registration in main.py
    """
    
    async def dispatch(self, request: Request, call_next):
        # Skip HTTPS redirect in development mode
        if config.APP_ENV != "production":
            return await call_next(request)
        
        # Check if the request is using HTTPS
        if request.url.scheme != "https":
            # Get the same URL but with https scheme
            url = URL(str(request.url)).replace(scheme="https")
            return RedirectResponse(url, status_code=301)
        
        return await call_next(request)


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """
    Middleware to add security headers to responses.
    Includes headers for content security policy, XSS protection, etc.
    """
    
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        
        # Security headers
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        
        # Strict Transport Security (only in production and if HTTPS is enforced)
        if config.APP_ENV == "production" and config.ENFORCE_HTTPS:
            # Max age set to 1 year in seconds
            response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
            
        # Content Security Policy
        try:
            path = request.url.path if hasattr(request, "url") and hasattr(request.url, "path") else ""
            
            if path.startswith("/docs") or path.startswith("/redoc") or path.startswith("/openapi.json"):
                # More permissive CSP for API documentation
                response.headers["Content-Security-Policy"] = (
                    "default-src 'self'; "
                    "img-src 'self' data: https://fastapi.tiangolo.com; "
                    "style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; "
                    "script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; "
                    "connect-src 'self';"
                )
            else:
                # Stricter CSP for other routes
                response.headers["Content-Security-Policy"] = (
                    "default-src 'self'; "
                    "img-src 'self' data:; "
                    "style-src 'self' 'unsafe-inline'; "
                    "script-src 'self' 'unsafe-inline'; "
                    "connect-src 'self';"
                )
        except Exception:
            # Fallback to a basic CSP if there's any error
            response.headers["Content-Security-Policy"] = (
                "default-src 'self'; "
                "img-src 'self' data: https://fastapi.tiangolo.com; "
                "style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; "
                "script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; "
                "connect-src 'self';"
            )
        
        return response 