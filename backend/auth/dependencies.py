from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from auth.utils import get_current_user
from jose import JWTError, ExpiredSignatureError

security = HTTPBearer(
    scheme_name="Bearer Authentication",
    description="Enter your JWT token",
    auto_error=True
)

async def get_current_active_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    Dependency to get the current active user from a JWT token.
    
    This uses a simpler Bearer Authentication scheme instead of OAuth2PasswordBearer
    for better integration with Swagger UI.
    
    Returns 401 for invalid or expired tokens with appropriate error messages.
    """
    try:
        token = credentials.credentials
        user = await get_current_user(token)
        
        if not user.get("is_active", True):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Inactive user",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return user
    except ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except Exception as e:
        # Catch any other unexpected errors but don't expose details in production
        # Log the actual error for debugging
        print(f"Authentication error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication failed",
            headers={"WWW-Authenticate": "Bearer"},
        ) 