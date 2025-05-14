"""
Configuration settings for the Ethio-AgriBizBoost application.

This file loads environment variables from a .env file if it exists.
For development, you can create a .env file in the root directory with the variables below.
For production, set these environment variables in your deployment environment.
"""

import os
from pathlib import Path
from dotenv import load_dotenv

# Load .env file if it exists
env_path = Path('.') / '.env'
load_dotenv(dotenv_path=env_path)

# MongoDB Configuration
MONGO_URI = os.getenv("MONGO_URI", "")
DB_NAME = os.getenv("DB_NAME", "ethio_agri_biz_boost")
# JWT Authentication
SECRET_KEY = os.getenv("SECRET_KEY", "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7")
ALGORITHM = "HS256"

# Token Expiration Settings
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", "30"))

# Application Settings
APP_ENV = os.getenv("APP_ENV", "development")
DEBUG = os.getenv("DEBUG", "True").lower() in ('true', '1', 't')
APP_HOST = os.getenv("APP_HOST", "0.0.0.0")
APP_PORT = int(os.getenv("APP_PORT", "8000"))

# CORS Settings
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "http://localhost:3000").split(",")
CORS_ALLOW_CREDENTIALS = os.getenv("CORS_ALLOW_CREDENTIALS", "True").lower() in ('true', '1', 't')
CORS_ALLOW_METHODS = os.getenv("CORS_ALLOW_METHODS", "GET,POST,PUT,DELETE,OPTIONS").split(",")
CORS_ALLOW_HEADERS = os.getenv("CORS_ALLOW_HEADERS", "*").split(",")

# Security settings - HTTPS enforcement disabled by default
# Set to True in production when ready to implement HTTPS
ENFORCE_HTTPS = False  # Hardcoded to False to explicitly disable it

# Rate limiting
RATE_LIMIT_STORAGE_URI = os.getenv("RATE_LIMIT_STORAGE_URI", MONGO_URI if APP_ENV == "production" else None)


# .env file template for reference
ENV_TEMPLATE = """
# MongoDB Configuration
MONGO_URI=mongodb+srv://your_username:your_password@your_cluster.mongodb.net/?retryWrites=true&w=majority
DB_NAME=ethio_agri_biz_boost

# JWT Authentication
# Generate a strong secret key. In production, use a secure random key generator.
# You can use: openssl rand -hex 32
SECRET_KEY=09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7

# Token Expiration Settings (in minutes for access token, days for refresh token)
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=30

# Application Settings
# Use "development", "production", or "testing"
APP_ENV=development
DEBUG=True
APP_HOST=0.0.0.0
APP_PORT=8000

# CORS Settings
# Comma-separated list of allowed origins for CORS
ALLOWED_ORIGINS=http://localhost:3000,https://your-frontend-domain.com
CORS_ALLOW_CREDENTIALS=True
CORS_ALLOW_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOW_HEADERS=*

# Security Settings
# Set to True when ready to implement HTTPS
ENFORCE_HTTPS=False
"""

def print_env_template():
    """Print the .env template to console"""
    print("===== .env Template =====")
    print(ENV_TEMPLATE)
    print("=========================")
    print("Copy the above template to a file named .env in the project root directory.")
    print("Replace the placeholder values with your actual configuration.")


if __name__ == "__main__":
    print_env_template() 