from fastapi import APIRouter, Depends, HTTPException, status, Body, Request
from fastapi.security import OAuth2PasswordRequestForm
from datetime import timedelta
from typing import Dict

from auth.models import UserCreate, Token, UserInDB, UserUpdate, DeleteAccount, UpdatePassword
from auth.utils import (
    authenticate_user, 
    create_access_token, 
    ACCESS_TOKEN_EXPIRE_MINUTES, 
    get_password_hash,
    create_tokens_for_user,
    validate_refresh_token,
    verify_password
)
from auth.validators import normalize_phone_number, check_phone_exists
from auth.database import (
    get_user_by_phone, 
    create_user, 
    revoke_refresh_token, 
    revoke_all_user_tokens,
    get_user_by_id,
    update_user,
    delete_user
)
from auth.dependencies import get_current_active_user
from security.rate_limiter import limiter

router = APIRouter(
    prefix="/auth", 
    tags=["authentication"],
    responses={
        401: {
            "description": "Unauthorized - Invalid credentials",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {"detail": "Incorrect phone number or password"}
                    }
                }
            }
        },
        403: {
            "description": "Forbidden - Insufficient permissions",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {"detail": "Not authorized to access this resource"}
                    }
                }
            }
        },
        429: {
            "description": "Too Many Requests - Rate limit exceeded",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {"detail": "Too many requests. Please try again later."}
                    }
                }
            }
        }
    }
)

@router.post(
    "/register", 
    response_model=Dict[str, str],
    status_code=status.HTTP_201_CREATED,
    summary="Register a new user",
    description="""
    Register a new user with a phone number and password.
    
    **Required fields:**
    - `phone_number`: Must be a valid Ethiopian phone number (formats: +251912345678, 0912345678)
    - `password`: At least 8 characters
    
    **Optional fields:**
    - `name`: User's full name
    - `email`: User's email address
    """,
    responses={
        201: {
            "description": "User successfully registered",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {"message": "User registered successfully", "user_id": "60f1a5b5c6e1f1234567890a"}
                    }
                }
            }
        },
        400: {
            "description": "Bad Request - Invalid input or phone number already registered",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {"detail": "Phone number already registered"}
                    }
                }
            }
        }
    }
)
@limiter.limit("5/minute")
async def register_user(
    request: Request,
    user: UserCreate = Body(
        ...,
        examples={
            "default": {
                "name": "Abebe Kebede", 
                "phone_number": "0912345678",
                "password": "securepassword123"
            }
        },
        description="User registration information. Only phone_number and password are required."
    )
):
    """
    Register a new user with a valid Ethiopian phone number and password.
    
    The phone number will be normalized to international format (+251).
    Password will be securely hashed before storage.
    """
    # Check if user already exists using our utility function
    existing_user = check_phone_exists(get_user_by_phone, user.phone_number)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number already registered"
        )
    
    # Create new user with normalized phone
    normalized_phone = normalize_phone_number(user.phone_number)
    hashed_password = get_password_hash(user.password)
    user_data = user.dict(exclude={"password"})
    user_data["phone_number"] = normalized_phone
    user_data["hashed_password"] = hashed_password
    
    user_id = create_user(user_data)
    
    return {"message": "User registered successfully", "user_id": user_id}

@router.post(
    "/login", 
    response_model=Token,
    summary="Login and obtain access token",
    description="""
    Authenticate a user and return access and refresh tokens.
    
    **Important notes:**
    - Use the phone number as the username in the form field
    - Valid phone formats: +251912345678, 0912345678, etc.
    - Password should be entered in the password field
    - Access token expires in 30 minutes
    - Use the refresh token to get a new access token when it expires
    
    **Form fields:**
    - username: Your phone number (required)
    - password: Your password (required)
    """,
    responses={
        200: {
            "description": "Successfully authenticated",
            "content": {
                "application/json": {
                    "example": {
                        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                        "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                        "token_type": "bearer"
                    }
                }
            }
        },
        401: {
            "description": "Unauthorized - Invalid credentials",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Incorrect phone number or password"
                    }
                }
            }
        }
    }
)
@limiter.limit("5/minute")
async def login_for_access_token(
    request: Request,
    form_data: OAuth2PasswordRequestForm = Depends()
):
    """
    Login with phone number and password to obtain access and refresh tokens.
    
    The phone number should be entered in the username field.
    The access token is valid for a limited time, while the refresh token can be used
    to obtain new access tokens without requiring re-authentication.
    """
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect phone number or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Create both access and refresh tokens
    tokens = create_tokens_for_user(str(user["_id"]), user["phone_number"])
    
    return Token(**tokens)

@router.post(
    "/login-with-json", 
    response_model=Token,
    summary="Login with JSON body",
    description="""
    Alternative login endpoint that accepts JSON format input.
    
    **Important notes:**
    - Use this endpoint if you prefer to send JSON data instead of form data
    - Valid phone formats: +251912345678, 0912345678, etc.
    - Access token expires in 30 minutes
    - Use the refresh token to get a new access token when it expires
    """,
    responses={
        200: {
            "description": "Successfully authenticated",
            "content": {
                "application/json": {
                    "example": {
                        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                        "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                        "token_type": "bearer"
                    }
                }
            }
        },
        401: {
            "description": "Unauthorized - Invalid credentials",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Incorrect phone number or password"
                    }
                }
            }
        }
    }
)
@limiter.limit("5/minute")
async def login_with_json(
    request: Request,
    login_data: Dict[str, str] = Body(
        ...,
        examples=[{
            "phone_number": "0912345678",
            "password": "securepassword123"
        }]
    )
):
    """
    Login with phone number and password using JSON format.
    Returns access and refresh tokens upon successful authentication.
    """
    phone_number = login_data.get("phone_number")
    password = login_data.get("password")
    
    if not phone_number or not password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number and password are required"
        )
    
    user = authenticate_user(phone_number, password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect phone number or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Create both access and refresh tokens
    tokens = create_tokens_for_user(str(user["_id"]), user["phone_number"])
    
    return Token(**tokens)

@router.post(
    "/refresh", 
    response_model=Token,
    summary="Refresh access token",
    description="""
    Get a new access token using a refresh token.
    
    **Security note:**
    - The old refresh token will be revoked for security reasons
    - You'll receive a new refresh token with each request
    - Store and use the new refresh token for subsequent refresh operations
    """,
    responses={
        200: {
            "description": "New tokens generated successfully",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {
                            "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                            "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                            "token_type": "bearer"
                        }
                    }
                }
            }
        },
        401: {
            "description": "Unauthorized - Invalid or expired refresh token",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {"detail": "Invalid refresh token"}
                    }
                }
            }
        }
    }
)
@limiter.limit("10/minute")
async def refresh_access_token(
    request: Request,
    refresh_token: str = Body(
        ..., 
        embed=True,
        examples=["eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."]
    )
):
    """
    Refresh an access token using a valid refresh token.
    Returns a new access token and a new refresh token.
    """
    # Validate the refresh token
    is_valid, user_id = validate_refresh_token(refresh_token)
    if not is_valid or not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )
    
    # Get user information
    user = get_user_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )
    
    # Create new tokens
    tokens = create_tokens_for_user(str(user["_id"]), user["phone_number"])
    
    # Revoke the old refresh token
    revoke_refresh_token(refresh_token)
    
    return Token(**tokens)

@router.post(
    "/logout", 
    response_model=Dict[str, str],
    summary="Logout - revoke refresh token",
    description="""
    Logout by revoking the provided refresh token.
    
    After this operation, the refresh token can no longer be used to obtain new access tokens.
    """,
    responses={
        200: {
            "description": "Successfully logged out",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {"message": "Successfully logged out"}
                    }
                }
            }
        },
        401: {
            "description": "Unauthorized - Invalid token format",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {"detail": "Invalid token format"}
                    }
                }
            }
        }
    }
)
@limiter.limit("10/minute")
async def logout(
    request: Request,
    refresh_token: str = Body(
        ..., 
        embed=True,
        examples=["eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."]
    )
):
    """
    Logout by revoking the provided refresh token.
    After this operation, the refresh token can no longer be used.
    """
    revoke_refresh_token(refresh_token)
    return {"message": "Successfully logged out"}

@router.post(
    "/logout-all", 
    response_model=Dict[str, str],
    summary="Logout from all devices",
    description="""
    Revoke all refresh tokens for the current user, effectively logging out from all devices.
    
    **Security use cases:**
    - Use this when you suspect unauthorized access to your account
    - Use when changing password
    - Use when you want to ensure no other sessions remain active
    
    Requires authentication with a valid access token.
    """,
    responses={
        200: {
            "description": "Successfully logged out from all devices",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {"message": "Successfully logged out from all devices"}
                    }
                }
            }
        }
    }
)
@limiter.limit("5/minute")
async def logout_all_devices(request: Request, current_user = Depends(get_current_active_user)):
    """
    Logout from all devices by revoking all refresh tokens for the user.
    This is useful when you suspect unauthorized access to your account.
    """
    user_id = str(current_user["_id"])
    revoke_all_user_tokens(user_id)
    return {"message": "Successfully logged out from all devices"}

@router.get(
    "/me", 
    response_model=dict,
    summary="Get current user information",
    description="""
    Returns information about the currently authenticated user.
    
    This endpoint returns the basic profile information for the authenticated user.
    No sensitive data like passwords are returned.
    
    Requires authentication with a valid access token.
    """,
    responses={
        200: {
            "description": "User information retrieved successfully",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {
                            "name": "Abebe Kebede",
                            "phone_number": "+251912345678",
                            "email": "abebe@example.com"
                        }
                    }
                }
            }
        }
    }
)
@limiter.limit("30/minute")
async def read_users_me(request: Request, current_user = Depends(get_current_active_user)):
    """
    Get information about the currently authenticated user.
    Requires a valid access token.
    """
    return {
        "name": current_user.get("name"),
        "phone_number": current_user.get("phone_number"),
        "email": current_user.get("email")
    }

@router.get(
    "/profile", 
    response_model=dict,
    summary="Get user profile",
    description="""
    Returns the complete profile information for the currently authenticated user.
    
    This endpoint returns all non-sensitive profile information, including
    custom fields and account details like creation date.
    
    Requires authentication with a valid access token.
    """,
    responses={
        200: {
            "description": "User profile retrieved successfully",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {
                            "name": "Abebe Kebede",
                            "phone_number": "+251912345678",
                            "email": "abebe@example.com",
                            "created_at": "2023-07-15T10:00:00",
                            "updated_at": "2023-07-16T15:30:00"
                        }
                    }
                }
            }
        }
    }
)
@limiter.limit("30/minute")
async def get_user_profile(request: Request, current_user = Depends(get_current_active_user)):
    """
    Get the complete profile information for the currently authenticated user.
    Requires a valid access token.
    """
    # Remove sensitive information
    profile = {k: v for k, v in current_user.items() if k != "hashed_password"}
    
    # Convert ObjectId to string for serialization
    if "_id" in profile:
        profile["_id"] = str(profile["_id"])
    
    return profile

@router.patch(
    "/profile", 
    response_model=dict,
    summary="Update user profile",
    description="""
    Update the profile information for the currently authenticated user.
    
    This endpoint allows updating specific fields in the user profile
    without changing others. Only the provided fields will be updated.
    
    You can update:
    - name: User's full name
    - email: User's email address
    - phone_number: User's Ethiopian phone number (must be valid and not already registered)
    - location: User's location (optional)

    Requires authentication with a valid access token.
    """,
    responses={
        200: {
            "description": "User profile updated successfully",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {
                            "message": "Profile updated successfully",
                            "user": {
                                "name": "Abebe Kebede",
                                "email": "abebe@example.com",
                                "phone_number": "+251912345678",
                                "location": "Addis Ababa"
                            }
                        }
                    }
                }
            }
        },
        400: {
            "description": "Bad Request - Invalid input or phone number already registered",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {"detail": "Phone number already registered by another user"}
                    }
                }
            }
        }
    }
)
@limiter.limit("10/minute")
async def update_user_profile(
    request: Request, 
    user_update: UserUpdate = Body(...),
    current_user = Depends(get_current_active_user)
):
    """
    Update profile information for the currently authenticated user.
    Only the fields provided in the request will be updated.
    Requires a valid access token.
    """
    user_id = str(current_user["_id"])
    
    # Get only non-None values
    update_data = {k: v for k, v in user_update.dict().items() if v is not None}
    
    if not update_data:
        return {
            "message": "No fields to update",
            "user": {
                "name": current_user.get("name"),
                "email": current_user.get("email"),
                "phone_number": current_user.get("phone_number"),
                "location": current_user.get("location")
            }
        }
    
    # Handle phone number update
    if "phone_number" in update_data:
        # Normalize the phone number
        normalized_phone = normalize_phone_number(update_data["phone_number"])
        update_data["phone_number"] = normalized_phone
        
        # Check if phone number is already taken by another user
        existing_user = check_phone_exists(get_user_by_phone, normalized_phone)
        if existing_user and str(existing_user["_id"]) != user_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Phone number already registered by another user"
            )
    
    # Update user in database
    update_user(user_id, update_data)
    
    # Return updated user info
    return {
        "message": "Profile updated successfully",
        "user": {
            "name": update_data.get("name", current_user.get("name")),
            "email": update_data.get("email", current_user.get("email")),
            "phone_number": update_data.get("phone_number", current_user.get("phone_number")),
            "location": update_data.get("location", current_user.get("location"))
        }
    }

@router.post(
    "/password", 
    response_model=Dict[str, str],
    summary="Update user password",
    description="""
    Update the password for the currently authenticated user.
    
    This endpoint requires:
    - current_password: Your existing password for verification
    - new_password: Your new password (minimum 8 characters)
    
    For security reasons, after a password change, all your active sessions
    will be invalidated and you'll need to log in again.
    
    Requires authentication with a valid access token.
    """,
    responses={
        200: {
            "description": "Password successfully updated",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {"message": "Password successfully updated. Please log in again."}
                    }
                }
            }
        },
        401: {
            "description": "Unauthorized - Current password is incorrect",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {"detail": "Current password is incorrect"}
                    }
                }
            }
        }
    }
)
@limiter.limit("5/minute")
async def update_password(
    request: Request,
    password_update: UpdatePassword = Body(...),
    current_user = Depends(get_current_active_user)
):
    """
    Update the password for the currently authenticated user.
    Requires verification with current password.
    After password change, all active sessions will be invalidated.
    """
    user_id = str(current_user["_id"])
    
    # Verify current password
    if not verify_password(password_update.current_password, current_user["hashed_password"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Current password is incorrect"
        )
    
    # Hash the new password
    hashed_password = get_password_hash(password_update.new_password)
    
    # Update password in database
    update_user(user_id, {"hashed_password": hashed_password})
    
    # Revoke all tokens for security
    revoke_all_user_tokens(user_id)
    
    return {"message": "Password successfully updated. Please log in again."}

@router.delete(
    "/profile", 
    response_model=Dict[str, str],
    summary="Delete user account",
    description="""
    Delete or deactivate the current user's account.
    
    This is a destructive operation and requires password verification for security.
    All active sessions will be terminated and the user will need to register again to use the system.
    
    By default, this performs a soft delete (account marked as inactive but data preserved).
    """,
    responses={
        200: {
            "description": "Account successfully deleted",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {"message": "Account successfully deleted"}
                    }
                }
            }
        },
        401: {
            "description": "Unauthorized - Invalid password",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {"detail": "Incorrect password"}
                    }
                }
            }
        }
    }
)
@limiter.limit("3/minute")
async def delete_user_account(
    request: Request,
    delete_data: DeleteAccount = Body(...),
    current_user = Depends(get_current_active_user)
):
    """
    Delete the current user's account.
    
    Requires password verification to prevent unauthorized deletions.
    This implementation uses a soft delete that preserves user data but prevents login.
    """
    user_id = str(current_user["_id"])
    
    # Verify password
    if not verify_password(delete_data.password, current_user["hashed_password"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect password"
        )
    
    # Revoke all refresh tokens
    revoke_all_user_tokens(user_id)
    
    # Delete or deactivate the user account
    delete_user(user_id)
    
    return {"message": "Account successfully deleted"}

@router.get(
    "/protected", 
    response_model=dict,
    summary="Example protected route",
    description="""
    Example of a protected route that requires authentication.
    
    This is a demonstration endpoint showing how to protect routes with the authentication system.
    Developers can use this as a reference for implementing their own protected endpoints.
    
    Requires authentication with a valid access token.
    """,
    responses={
        200: {
            "description": "Successfully accessed protected route",
            "content": {
                "application/json": {
                    "examples": {
                        "default": {
                            "message": "This is a protected route",
                            "user": "Abebe Kebede"
                        }
                    }
                }
            }
        }
    }
)
@limiter.limit("30/minute")
async def protected_route(request: Request, current_user = Depends(get_current_active_user)):
    """
    Example of a protected route that requires authentication.
    This route can only be accessed by authenticated users.
    """
    return {
        "message": "This is a protected route",
        "user": current_user.get("name")
    } 