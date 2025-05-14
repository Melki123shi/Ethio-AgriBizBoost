from fastapi import FastAPI, Request, Response
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from forcasting.routes import router as predict_router
from health_assessment.route import router as health_router
from forcasting.routes import router as forcasting_router
from expense_tracking.route import router as expense_tracking_router
from recommendation.loan_advice.route import router as loan_adivce_router
from recommendation.cost_cutting_strategies.route import router as cost_cutting_strategies_router
from chatbot.route import router as chatbot_router
import uvicorn
from auth.routes import router as auth_router
from security.rate_limiter import limiter
from security.https_middleware import HTTPSRedirectMiddleware, SecurityHeadersMiddleware
from slowapi.middleware import SlowAPIMiddleware
from slowapi.errors import RateLimitExceeded
from fastapi.responses import JSONResponse
import os
import sys
import config

app = FastAPI(
    title="🌾 Ethio-AgriBizBoost API",
    description="""\
**API for Ethiopian Agricultural Business Boost Platform**

## 🚀 Features

- 📈 Crop forecasting and yield prediction  
- 🌿 Plant health assessment and disease identification  
- 🧠 Personalized farming recommendations  
- 🔐 User authentication and profile management  

## 🔐 Authentication

This API uses **OAuth2 with JWT tokens**.

- `POST /auth/register`: Register with phone number and password  
- `POST /auth/login`: Login using phone number (as username) and password  
- `POST /auth/refresh`: Refresh your token  
- All protected endpoints require a valid **Bearer token** in the `Authorization` header.
""",
    version="1.0.0",
    docs_url="/docs" if config.DEBUG else None,
    redoc_url="/redoc" if config.DEBUG else None,
    openapi_url="/api/openapi.json" if config.DEBUG else None,
    swagger_ui_parameters={
        "docExpansion": "list",  # Expand all by default
        "defaultModelsExpandDepth": -1,  # Hide schemas for cleaner look
    }
)

app.openapi_schema = None  


original_openapi = app.openapi

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError) -> Response:
    errors = exc.errors()
    error_messages = [
        {"field": error["loc"][-1], "message": error["msg"]}
        for error in errors
    ]
    return JSONResponse(
        status_code=422,
        content={"success": False, "errors": error_messages},
    )

def custom_openapi():
    """Create a custom OpenAPI schema for better Swagger UI documentation"""
    if app.openapi_schema:
        return app.openapi_schema
    
    
    openapi_schema = original_openapi()
    
    
    openapi_schema["components"]["securitySchemes"] = {
        "bearerAuth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
            "description": "Enter the JWT token you received from login in the format: Bearer your_token"
        }
    }
    
    
    if "security" in openapi_schema:
        del openapi_schema["security"]
    
    
    for path in openapi_schema["paths"]:
        
        if path.startswith("/auth/login") or path.startswith("/auth/register") or path == "/auth/refresh":
            continue
            
        
        if path.startswith("/auth/"):
            for method in openapi_schema["paths"][path]:
                openapi_schema["paths"][path][method]["security"] = [{"bearerAuth": []}]
                
        
        if path.startswith("/recommendations/"):
            for method in openapi_schema["paths"][path]:
                openapi_schema["paths"][path][method]["security"] = [{"bearerAuth": []}]
                
        
        if path.startswith("/forecast/") and not path.endswith("/public"):
            for method in openapi_schema["paths"][path]:
                openapi_schema["paths"][path][method]["security"] = [{"bearerAuth": []}]
                
        
        if path.startswith("/health/") and not path.endswith("/public"):
            for method in openapi_schema["paths"][path]:
                openapi_schema["paths"][path][method]["security"] = [{"bearerAuth": []}]
    
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = custom_openapi

# Add rate limiter middleware
app.state.limiter = limiter
app.add_middleware(SlowAPIMiddleware)

# Handle rate limit exceeded
@app.exception_handler(RateLimitExceeded)
async def rate_limit_handler(request: Request, exc: RateLimitExceeded):
    """
    Handle rate limit exceeded exceptions with a user-friendly error message.
    This provides clear information about the rate limit violation and when they can retry.
    """
    return JSONResponse(
        status_code=429,
        content={
            "error": "Rate limit exceeded",
            "detail": "Too many requests. Please try again later.",
            "type": "rate_limit_error",
            "retry_after": exc.retry_after if hasattr(exc, "retry_after") else None
        },
        headers={"Retry-After": str(exc.retry_after) if hasattr(exc, "retry_after") else "60"}
    )

# Add HTTPS redirect middleware if in production and ENFORCE_HTTPS is enabled
# Currently disabled for development simplicity
# if config.ENFORCE_HTTPS:
#     app.add_middleware(HTTPSRedirectMiddleware)


app.add_middleware(SecurityHeadersMiddleware)

# Configure CORS with enhanced security
app.add_middleware(
    CORSMiddleware,
    allow_origins=config.ALLOWED_ORIGINS,
    allow_credentials=config.CORS_ALLOW_CREDENTIALS,
    allow_methods=config.CORS_ALLOW_METHODS,
    allow_headers=config.CORS_ALLOW_HEADERS,
    max_age=1800,  # 30 minutes - how long browsers should cache CORS responses
)

# Include routers
app.include_router(health_router)
app.include_router(auth_router)
app.include_router(forcasting_router)
app.include_router(expense_tracking_router)
app.include_router(loan_adivce_router)
app.include_router(cost_cutting_strategies_router)
app.include_router(chatbot_router)

@app.get(
    "/",
    summary="API Root",
    description="Welcome endpoint for the Ethio-AgriBizBoost API",
    tags=["general"],
    responses={
        200: {
            "description": "Successful response",
            "content": {
                "application/json": {
                    "example": {"message": "Welcome to the EthioBizBoost Prediction Service!"}
                }
            }
        }
    }
)
def read_root():
    """
    Root endpoint that provides a welcome message for the API.
    This endpoint can be used to verify that the API is running.
    """
    return {"message": "Welcome to the EthioBizBoost Prediction Service!"}

@app.get(
    "/health",
    summary="Health Check",
    description="Health check endpoint for monitoring and status verification",
    tags=["general"],
    responses={
        200: {
            "description": "API is functioning normally",
            "content": {
                "application/json": {
                    "example": {"status": "ok", "version": "1.0.0"}
                }
            }
        }
    }
)
def health_check():
    """
    Health check endpoint for monitoring systems.
    Returns a simple success response to confirm the API is running.
    This endpoint is used by load balancers and monitoring tools to check service availability.
    """
    return {"status": "ok", "version": "1.0.0"}

# Add a middleware to log requests in development mode
if config.DEBUG:
    @app.middleware("http")
    async def log_requests(request: Request, call_next):
        print(f"Request: {request.method} {request.url}")
        response = await call_next(request)
        print(f"Response: {response.status_code}")
        return response

def start_server():
    """
    Start the server with the appropriate configuration for the current platform.
    
    This function determines the best server to use based on the platform and environment:
    - In development mode (DEBUG=True): Uses Uvicorn with auto-reload
    - On Windows in production: Uses Waitress if available, falls back to Uvicorn
    - On other platforms in production: Uses Uvicorn with production settings
    
    The server binds to the host and port specified in the config module.
    Logs are stored in the 'logs' directory.
    """
    
    
    # Create logs directory if it doesn't exist
    os.makedirs("logs", exist_ok=True)
    
    # Log startup information
    print(f"Starting Ethio-AgriBizBoost API v1.0.0")
    print(f"Environment: {'Development' if config.DEBUG else 'Production'}")
    print(f"API will be available at: http://{config.APP_HOST}:{config.APP_PORT}")
    if config.DEBUG:
        print(f"API documentation will be available at: http://{config.APP_HOST}:{config.APP_PORT}/docs")
    
    # Detect if we're on Windows
    is_windows = sys.platform.startswith('win')
    
    if is_windows and not config.DEBUG:
        # On Windows in production, suggest using waitress
        try:
            import waitress
            print("Starting with Waitress server (Windows production)")
            waitress.serve(app, host=config.APP_HOST, port=config.APP_PORT)
        except ImportError:
            print("Waitress not found. Installing...")
            print("Run: pip install waitress")
            print("Falling back to Uvicorn...")
            uvicorn.run(
                app, 
                host=config.APP_HOST, 
                port=config.APP_PORT,
                log_level="info",
            )
    else:
        # On Linux or in development mode, use Uvicorn
        if config.DEBUG:
            # In development mode with reload, use import string
            uvicorn.run(
                "main:app", 
                host=config.APP_HOST, 
                port=config.APP_PORT,
                reload=True,
                log_level="debug",
            )
        else:
            # In production without reload, can use app object directly
            uvicorn.run(
                app, 
                host=config.APP_HOST, 
                port=config.APP_PORT,
                log_level="info",
            )

if __name__ == "__main__":
    start_server()