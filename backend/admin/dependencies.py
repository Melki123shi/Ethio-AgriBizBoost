from fastapi import Depends, HTTPException, status
from typing import Dict, Any
from auth.dependencies import get_current_active_user
from admin.database import get_admin_user, check_admin_permission


async def get_current_admin_user(current_user: Dict[str, Any] = Depends(get_current_active_user)) -> Dict[str, Any]:
    """
    Dependency to ensure the current user is an admin.
    
    Returns the admin user data if valid, raises 403 if not an admin.
    """
    user_id = current_user.get("id") or current_user.get("_id")
    
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid user data"
        )
    
    admin_user = get_admin_user(str(user_id))
    
    if not admin_user:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Admin privileges required."
        )
    
    return admin_user


async def get_current_super_admin(admin_user: Dict[str, Any] = Depends(get_current_admin_user)) -> Dict[str, Any]:
    """
    Dependency to ensure the current user is a super admin.
    
    Returns the super admin user data if valid, raises 403 if not a super admin.
    """
    if not admin_user.get("is_super_admin", False):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Super admin privileges required."
        )
    
    return admin_user


def require_permission(permission: str):
    """
    Dependency factory to check for specific permissions.
    
    Usage:
        @router.get("/some-endpoint", dependencies=[Depends(require_permission("view_financial_data"))])
    """
    async def permission_checker(admin_user: Dict[str, Any] = Depends(get_current_admin_user)):
        user_id = str(admin_user["_id"])
        
        if not check_admin_permission(user_id, permission):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. Missing required permission: {permission}"
            )
        
        return admin_user
    
    return permission_checker


# Common permission constants
class AdminPermissions:
    VIEW_ALL_FARMERS = "view_all_farmers"
    VIEW_FARMER_DETAILS = "view_farmer_details"
    VIEW_FINANCIAL_DATA = "view_financial_data"
    VIEW_SYSTEM_METRICS = "view_system_metrics"
    EXPORT_DATA = "export_data"
    MANAGE_ADMINS = "manage_admins"
    VIEW_AUDIT_LOGS = "view_audit_logs"