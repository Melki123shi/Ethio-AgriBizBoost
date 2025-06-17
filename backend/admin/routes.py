from fastapi import APIRouter, Depends, HTTPException, status, Query, Request
from typing import Dict, Any, List, Optional
from datetime import datetime

from admin.models import (
    DashboardFilters, DashboardSummary, FarmerDashboardData,
    TimeFilter, ServiceFilter
)
from admin.services import (
    get_farmer_dashboard_data, get_farmers_list, get_dashboard_summary,
    search_farmers, get_service_trends, export_farmer_data,
    log_admin_activity, get_admin_users, create_admin_user, 
    update_admin_user, delete_admin_user
)
from admin.dependencies import (
    get_current_admin_user, get_current_super_admin,
    require_permission, AdminPermissions
)
from security.rate_limiter import limiter

router = APIRouter(
    prefix="/admin",
    tags=["Admin Dashboard"],
    responses={
        403: {"description": "Forbidden - Admin access required"},
        404: {"description": "Not found"}
    }
)


@router.get(
    "/dashboard/summary",
    response_model=DashboardSummary,
    summary="Get Dashboard Summary",
    description="Get overall system summary including farmer counts, service usage, and financial overview"
)
@limiter.limit("30/minute")
async def get_admin_dashboard_summary(
    request: Request,
    time_filter: TimeFilter = Query(TimeFilter.all, description="Time period for data aggregation"),
    admin_user: Dict[str, Any] = Depends(get_current_admin_user)
):
    """
    Get comprehensive dashboard summary for admins.
    
    This endpoint provides:
    - Total farmer counts (active/inactive)
    - Service usage statistics
    - Financial overview (revenue, expenses, profit)
    - Regional distribution
    - Farmers needing attention
    
    Requires admin authentication.
    """
    admin_id = str(admin_user["_id"])
    
    # Log activity
    log_admin_activity(
        admin_id=admin_id,
        action="view_dashboard_summary",
        details={"time_filter": time_filter.value}
    )
    
    summary = get_dashboard_summary(time_filter)
    return summary


@router.get(
    "/farmers",
    summary="List All Farmers",
    description="Get paginated list of farmers with filtering and sorting options"
)
@limiter.limit("50/minute")
async def list_farmers(
    request: Request,
    time_filter: TimeFilter = Query(TimeFilter.all),
    service_filter: ServiceFilter = Query(ServiceFilter.all),
    region: Optional[str] = Query(None, description="Filter by region"),
    is_active: Optional[bool] = Query(None, description="Filter by active status"),
    min_engagement_score: Optional[float] = Query(None, ge=0, le=100),
    max_engagement_score: Optional[float] = Query(None, ge=0, le=100),
    needs_attention: Optional[bool] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    sort_by: str = Query("last_activity", description="Field to sort by"),
    sort_order: str = Query("desc", regex="^(asc|desc)$"),
    admin_user: Dict[str, Any] = Depends(require_permission(AdminPermissions.VIEW_ALL_FARMERS))
):
    """
    Get paginated list of farmers with comprehensive filtering.
    
    Filters available:
    - Time period
    - Service usage
    - Region
    - Active status
    - Engagement score range
    - Needs attention flag
    
    Returns farmer data including activity metrics across all services.
    """
    filters = DashboardFilters(
        time_filter=time_filter,
        service_filter=service_filter,
        region=region,
        is_active=is_active,
        min_engagement_score=min_engagement_score,
        max_engagement_score=max_engagement_score,
        needs_attention=needs_attention,
        page=page,
        page_size=page_size,
        sort_by=sort_by,
        sort_order=sort_order
    )
    
    farmers, total_count = get_farmers_list(filters)
    
    # Log activity
    log_admin_activity(
        admin_id=str(admin_user["_id"]),
        action="list_farmers",
        details={"filters": filters.dict(), "results_count": len(farmers)}
    )
    
    return {
        "farmers": farmers,
        "total_count": total_count,
        "page": page,
        "page_size": page_size,
        "total_pages": (total_count + page_size - 1) // page_size
    }


@router.get(
    "/farmers/{farmer_id}",
    response_model=FarmerDashboardData,
    summary="Get Farmer Details",
    description="Get detailed dashboard data for a specific farmer"
)
@limiter.limit("100/minute")
async def get_farmer_details(
    request: Request,
    farmer_id: str,
    time_filter: TimeFilter = Query(TimeFilter.all),
    admin_user: Dict[str, Any] = Depends(require_permission(AdminPermissions.VIEW_FARMER_DETAILS))
):
    """
    Get comprehensive data for a specific farmer.
    
    Returns:
    - Basic farmer information
    - Activity metrics
    - Expense tracking data
    - Forecasting usage
    - Health assessments
    - Recommendations history
    - Engagement score and risk assessment
    """
    farmer_data = get_farmer_dashboard_data(farmer_id, time_filter)
    
    if not farmer_data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Farmer with ID {farmer_id} not found"
        )
    
    # Log activity
    log_admin_activity(
        admin_id=str(admin_user["_id"]),
        action="view_farmer_details",
        target_user_id=farmer_id,
        details={"time_filter": time_filter.value}
    )
    
    return farmer_data


@router.get(
    "/farmers/search",
    summary="Search Farmers",
    description="Search farmers by name or phone number"
)
@limiter.limit("100/minute")
async def search_farmers_endpoint(
    request: Request,
    q: str = Query(..., min_length=2, description="Search query (name or phone)"),
    limit: int = Query(10, ge=1, le=50),
    admin_user: Dict[str, Any] = Depends(get_current_admin_user)
):
    """
    Search for farmers by name or phone number.
    
    Returns basic farmer information for quick lookup.
    """
    results = search_farmers(q, limit)
    
    # Log activity
    log_admin_activity(
        admin_id=str(admin_user["_id"]),
        action="search_farmers",
        details={"query": q, "results_count": len(results)}
    )
    
    return {"results": results, "count": len(results)}


@router.get(
    "/farmers/{farmer_id}/export",
    summary="Export Farmer Data",
    description="Export all data for a specific farmer"
)
@limiter.limit("20/minute")
async def export_farmer_data_endpoint(
    request: Request,
    farmer_id: str,
    admin_user: Dict[str, Any] = Depends(require_permission(AdminPermissions.EXPORT_DATA))
):
    """
    Export comprehensive data for a specific farmer.
    
    Returns all available data in a format suitable for export/download.
    """
    data = export_farmer_data(farmer_id)
    
    if not data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Farmer with ID {farmer_id} not found"
        )
    
    # Log activity
    log_admin_activity(
        admin_id=str(admin_user["_id"]),
        action="export_farmer_data",
        target_user_id=farmer_id
    )
    
    return data


@router.get(
    "/trends/{service}",
    summary="Get Service Trends",
    description="Get usage trends for a specific service"
)
@limiter.limit("30/minute")
async def get_service_trends_endpoint(
    request: Request,
    service: ServiceFilter,
    time_filter: TimeFilter = Query(TimeFilter.monthly),
    admin_user: Dict[str, Any] = Depends(require_permission(AdminPermissions.VIEW_SYSTEM_METRICS))
):
    """
    Get time-series data showing usage trends for a specific service.
    
    Useful for:
    - Identifying usage patterns
    - Planning capacity
    - Monitoring service adoption
    """
    if service == ServiceFilter.all:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Please specify a specific service, not 'all'"
        )
    
    trends = get_service_trends(service, time_filter)
    
    # Log activity
    log_admin_activity(
        admin_id=str(admin_user["_id"]),
        action="view_service_trends",
        details={"service": service.value, "time_filter": time_filter.value}
    )
    
    return {
        "service": service.value,
        "time_filter": time_filter.value,
        "trends": trends
    }


@router.get(
    "/farmers/needing-attention",
    summary="Get Farmers Needing Attention",
    description="Get list of farmers who need admin attention"
)
@limiter.limit("50/minute")
async def get_farmers_needing_attention(
    request: Request,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    admin_user: Dict[str, Any] = Depends(get_current_admin_user)
):
    """
    Get farmers who need attention based on:
    - Inactivity (>30 days)
    - High financial risk
    - Low engagement score (<20)
    
    This helps admins prioritize farmer support.
    """
    filters = DashboardFilters(
        needs_attention=True,
        page=page,
        page_size=page_size,
        sort_by="engagement_score",
        sort_order="asc"
    )
    
    farmers, total_count = get_farmers_list(filters)
    
    # Log activity
    log_admin_activity(
        admin_id=str(admin_user["_id"]),
        action="view_farmers_needing_attention",
        details={"results_count": len(farmers)}
    )
    
    return {
        "farmers": farmers,
        "total_count": total_count,
        "page": page,
        "page_size": page_size,
        "total_pages": (total_count + page_size - 1) // page_size
    }


@router.get(
    "/activity-logs",
    summary="Get Activity Logs",
    description="Get admin activity logs for audit trail"
)
@limiter.limit("30/minute")
async def get_activity_logs(
    request: Request,
    user_id: Optional[str] = Query(None, description="Filter by specific user"),
    action: Optional[str] = Query(None, description="Filter by action type"),
    service: Optional[str] = Query(None, description="Filter by service"),
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    admin_user: Dict[str, Any] = Depends(require_permission(AdminPermissions.VIEW_AUDIT_LOGS))
):
    """
    Get activity logs for audit trail.
    
    Super admins can view all logs.
    Regular admins can only view their own logs.
    """
    # This would be implemented with proper log querying
    # For now, returning a placeholder response
    
    is_super_admin = admin_user.get("is_super_admin", False)
    
    if not is_super_admin and user_id and user_id != str(admin_user["_id"]):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only view your own activity logs"
        )
    
    return {
        "logs": [],
        "total_count": 0,
        "page": page,
        "page_size": page_size
    }


# Admin User Management Endpoints (alias to farmers)
@router.get(
    "/users",
    summary="List Admin Users",
    description="Get list of admin users in the system"
)
@limiter.limit("50/minute")
async def list_admin_users(
    request: Request,
    admin_user: Dict[str, Any] = Depends(require_permission(AdminPermissions.MANAGE_ADMINS))
):
    """
    Get list of admin users.
    """
    # Log activity
    log_admin_activity(
        admin_id=str(admin_user["_id"]),
        action="list_admin_users"
    )
    
    # Get actual admin users
    admin_users = get_admin_users()
    
    return admin_users


@router.post(
    "/users",
    summary="Create Admin User",
    description="Create a new admin user"
)
@limiter.limit("10/minute")
async def create_admin_user_endpoint(
    request: Request,
    admin_data: Dict[str, Any],
    admin_user: Dict[str, Any] = Depends(get_current_super_admin)
):
    """
    Create a new admin user.
    Only super admins can create other admin users.
    """
    try:
        # Log activity
        log_admin_activity(
            admin_id=str(admin_user["_id"]),
            action="create_admin_user",
            details={"new_admin_phone": admin_data.get("phone_number")}
        )
        
        # Create admin user
        new_admin = create_admin_user(admin_data)
        
        if new_admin:
            return new_admin
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to create admin user"
            )
    
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error creating admin user: {str(e)}"
        )


@router.put(
    "/users/{user_id}",
    summary="Update Admin User",
    description="Update an existing admin user"
)
@limiter.limit("20/minute")
async def update_admin_user_endpoint(
    request: Request,
    user_id: str,
    update_data: Dict[str, Any],
    admin_user: Dict[str, Any] = Depends(get_current_super_admin)
):
    """
    Update an admin user.
    Only super admins can update other admin users.
    """
    try:
        # Log activity
        log_admin_activity(
            admin_id=str(admin_user["_id"]),
            action="update_admin_user",
            target_user_id=user_id,
            details={"updates": list(update_data.keys())}
        )
        
        # Update admin user
        updated_admin = update_admin_user(user_id, update_data)
        
        if updated_admin:
            return updated_admin
        else:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Admin user not found or update failed"
            )
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error updating admin user: {str(e)}"
        )


@router.delete(
    "/users/{user_id}",
    summary="Delete Admin User",
    description="Remove admin privileges from a user"
)
@limiter.limit("10/minute")
async def delete_admin_user_endpoint(
    request: Request,
    user_id: str,
    admin_user: Dict[str, Any] = Depends(get_current_super_admin)
):
    """
    Remove admin privileges from a user.
    Only super admins can remove admin privileges.
    The user account itself is not deleted.
    """
    if user_id == str(admin_user["_id"]):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete your own admin account"
        )
    
    # Log activity
    log_admin_activity(
        admin_id=str(admin_user["_id"]),
        action="delete_admin_user",
        target_user_id=user_id
    )
    
    # Remove admin privileges
    success = delete_admin_user(user_id)
    
    if success:
        return {"message": "Admin privileges removed successfully"}
    else:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Admin user not found or deletion failed"
        )


# Health check endpoint for admin service
@router.get(
    "/health",
    summary="Admin Service Health",
    description="Check if admin service is running"
)
async def admin_health_check():
    """Simple health check for admin service."""
    return {"status": "healthy", "service": "admin_dashboard"} 