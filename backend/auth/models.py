from pydantic import BaseModel, Field, EmailStr, validator
from typing import Optional
from datetime import datetime
from auth.validators import validate_ethiopian_phone

class UserBase(BaseModel):
    name: Optional[str] = Field(
        None,
        description="User's full name",
        example="Abebe Kebede"
    )
    phone_number: str = Field(
        ...,
        description="Ethiopian phone number (Ethio Telecom or Safaricom)",
        example="0912345678"
    )
    email: Optional[str] = Field(
        None,
        description="User's email address (optional)",
        example="user@example.com"
    )
    
    @validator('phone_number')
    def validate_phone(cls, v):
        return validate_ethiopian_phone(v)

class UserUpdate(BaseModel):
    name: Optional[str] = Field(
        None,
        description="User's full name",
        example="Abebe Kebede"
    )
    email: Optional[str] = Field(
        None,
        description="User's email address (optional)",
        example="user@example.com"
    )
    phone_number: Optional[str] = Field(
        None,
        description="Ethiopian phone number (Ethio Telecom or Safaricom)",
        example="0912345678"
    )
    password: Optional[str] = Field(
        None,
        description="New password (will be hashed)",
        example="newsecurepassword123",
        min_length=8
    ),
    location: Optional[str] = Field(
        None,
        description="User's location (optional)",
        example="Addis Ababa, Ethiopia"
    )
    
    @validator('phone_number')
    def validate_phone(cls, v):
        if v is None:
            return v
        return validate_ethiopian_phone(v)

class UserCreate(UserBase):
    password: str = Field(
        ...,
        description="User password (will be hashed)",
        example="securepassword123",
        min_length=8
    )

class UserLogin(BaseModel):
    phone_number: str = Field(
        ...,
        description="Ethiopian phone number for login",
        example="0912345678"
    )
    password: str = Field(
        ...,
        description="User password",
        example="securepassword123"
    )
    
    @validator('phone_number')
    def validate_phone(cls, v):
        return validate_ethiopian_phone(v)

class UserInDB(UserBase):
    id: str = Field(
        alias="_id",
        description="MongoDB document ID"
    )
    hashed_password: str = Field(
        ...,
        description="Bcrypt hashed password"
    )
    created_at: datetime = Field(
        ...,
        description="Account creation timestamp"
    )
    updated_at: Optional[datetime] = Field(
        None,
        description="Last update timestamp"
    )
    is_active: bool = Field(
        True,
        description="Whether the user account is active"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "_id": "60f1a5b5c6e1f1234567890a",
                "name": "Abebe Kebede",
                "phone_number": "+251912345678",
                "email": "abebe@example.com",
                "hashed_password": "$2b$12$EixZaYVK1fsbw1ZfbX3OXepioOtMtQGlmp/NKB80RyhEZ4FtQgERW",
                "created_at": "2023-07-15T10:00:00",
                "updated_at": "2023-07-16T15:30:00",
                "is_active": True
            }
        }

class Token(BaseModel):
    access_token: str = Field(
        ...,
        description="JWT access token for API authentication",
        example="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    )
    refresh_token: str = Field(
        ...,
        description="JWT refresh token to obtain new access tokens",
        example="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    )
    token_type: str = Field(
        "bearer",
        description="Token type (always 'bearer')",
        example="bearer"
    )

class TokenData(BaseModel):
    phone_number: str = Field(
        ...,
        description="Phone number extracted from JWT token",
        example="+251912345678"
    )
    
class RefreshToken(BaseModel):
    user_id: str = Field(
        ...,
        description="ID of the user who owns this refresh token",
        example="60f1a5b5c6e1f1234567890a"
    )
    refresh_token: str = Field(
        ...,
        description="Actual refresh token string",
        example="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    )
    expires_at: datetime = Field(
        ...,
        description="Expiration timestamp for this refresh token"
    )
    created_at: datetime = Field(
        ...,
        description="Creation timestamp for this refresh token"
    )
    is_revoked: bool = Field(
        False,
        description="Whether this refresh token has been revoked"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "60f1a5b5c6e1f1234567890a",
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "expires_at": "2023-08-15T10:00:00",
                "created_at": "2023-07-15T10:00:00",
                "is_revoked": False
            }
        }

class DeleteAccount(BaseModel):
    password: str = Field(
        ...,
        description="Current password to confirm account deletion",
        example="securepassword123"
    ) 