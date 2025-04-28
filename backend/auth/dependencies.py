from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from auth.utils import get_current_user

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
    """
    token = credentials.credentials
    user = await get_current_user(token)
    if not user.get("is_active", True):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Inactive user"
        )
    return user 