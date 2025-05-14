from passlib.context import CryptContext
from jose import JWTError, jwt, ExpiredSignatureError
from datetime import datetime, timedelta
import os
import secrets
from typing import Optional, Dict, Tuple
import config
from fastapi import HTTPException, status

from auth.models import TokenData, UserInDB
from auth.database import get_user_by_phone, store_refresh_token, is_token_valid, get_refresh_token, get_user_by_id
from auth.validators import normalize_phone_number, check_phone_exists

# Security configuration
SECRET_KEY = config.SECRET_KEY
ALGORITHM = config.ALGORITHM
ACCESS_TOKEN_EXPIRE_MINUTES = config.ACCESS_TOKEN_EXPIRE_MINUTES
REFRESH_TOKEN_EXPIRE_DAYS = config.REFRESH_TOKEN_EXPIRE_DAYS

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def generate_refresh_token() -> str:
    """Generate a secure random refresh token"""
    return secrets.token_urlsafe(64)

def create_tokens_for_user(user_id: str, phone_number: str) -> Dict[str, str]:
    """Create both access and refresh tokens for a user"""
    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": phone_number}, 
        expires_delta=access_token_expires
    )
    
    # Create and store refresh token
    refresh_token = generate_refresh_token()
    store_refresh_token(user_id, refresh_token, expires_in_days=REFRESH_TOKEN_EXPIRE_DAYS)
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

def authenticate_user(phone_number: str, password: str):
    # Use our check_phone_exists utility to find the user
    user = check_phone_exists(get_user_by_phone, phone_number)
    if not user:
        return False
            
    if not verify_password(password, user["hashed_password"]):
        return False
    return user

def validate_refresh_token(refresh_token: str) -> Tuple[bool, Optional[str]]:
    """
    Validate a refresh token and return the user_id if valid
    
    Returns:
        Tuple[is_valid: bool, user_id: Optional[str]]
    """
    # Check if token exists and is not revoked
    if not is_token_valid(refresh_token):
        return False, None
    
    # Get token from database
    token_data = get_refresh_token(refresh_token)
    if not token_data:
        return False, None
    
    # Return user_id
    return True, token_data["user_id"]

async def get_current_user(token: str):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        phone_number: str = payload.get("sub")
        if phone_number is None:
            raise credentials_exception
        token_data = TokenData(phone_number=phone_number)
    except ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except JWTError:
        raise credentials_exception
    
    # Use our check_phone_exists utility
    user = check_phone_exists(get_user_by_phone, token_data.phone_number)
    if user is None:
        raise credentials_exception
            
    return user 