from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime
from bson import ObjectId
import logging

from admin.models import (
    FarmerActivity, ExpenseMetrics, ForecastingMetrics, 
    HealthAssessmentMetrics, RecommendationMetrics,
    FarmerDashboardData, DashboardFilters, DashboardSummary,
    TimeFilter, ServiceFilter
)
from admin.database import (
    users_collection, get_user_auth_metrics, get_user_expense_metrics,
    get_user_forecasting_metrics, get_user_health_metrics,
    get_user_recommendation_metrics, calculate_engagement_score,
    assess_risk_level, check_needs_attention, get_time_filter_query,
    log_activity, get_bulk_farmer_metrics, ensure_indexes
)

logger = logging.getLogger(__name__)

# Ensure indexes are created on module load
try:
    ensure_indexes()
except Exception as e:
    logger.error(f"Failed to create indexes: {e}")


def get_farmer_dashboard_data(user_id: str, time_filter: TimeFilter = TimeFilter.all) -> Optional[FarmerDashboardData]:
    """Get comprehensive dashboard data for a single farmer - OPTIMIZED"""
    try:
        # Get user basic info
        user = users_collection.find_one({"_id": ObjectId(user_id)})
        if not user:
            return None
        
        # Use bulk operation for single user (still more efficient due to parallel processing)
        bulk_metrics = get_bulk_farmer_metrics(tuple([user_id]), time_filter)
        user_metrics = bulk_metrics.get(user_id, {})
        
        auth_metrics = user_metrics.get("auth_metrics", {})
        expense_metrics_data = user_metrics.get("expense_metrics", {})
        forecasting_metrics_data = user_metrics.get("forecasting_metrics", {})
        health_metrics_data = user_metrics.get("health_metrics", {})
        recommendation_metrics_data = user_metrics.get("recommendation_metrics", {})
        
        # Create FarmerActivity
        farmer_activity = FarmerActivity(
            user_id=str(user["_id"]),
            phone_number=user.get("phone_number", ""),
            name=user.get("name"),
            last_login=auth_metrics.get("last_login"),
            total_logins=auth_metrics.get("total_logins", 0),
            is_active=user.get("is_active", True),
            created_at=user.get("created_at", datetime.utcnow()),
            location=user.get("location")
        )
        
        # Create metric objects
        expense_metrics = ExpenseMetrics(
            user_id=user_id,
            **expense_metrics_data
        )
        
        forecasting_metrics_data = get_user_forecasting_metrics(user_id, time_filter)
        forecasting_metrics = ForecastingMetrics(
            user_id=user_id,
            **forecasting_metrics_data
        )
        
        health_metrics_data = get_user_health_metrics(user_id, time_filter)
        health_metrics = HealthAssessmentMetrics(
            user_id=user_id,
            **health_metrics_data
        )
        
        recommendation_metrics_data = get_user_recommendation_metrics(user_id, time_filter)
        recommendation_metrics = RecommendationMetrics(
            user_id=user_id,
            **recommendation_metrics_data
        )
        
        # Prepare data for calculations
        user_data = {
            "auth_metrics": auth_metrics,
            "expense_metrics": expense_metrics_data,
            "forecasting_metrics": forecasting_metrics_data,
            "health_metrics": health_metrics_data,
            "recommendation_metrics": recommendation_metrics_data
        }
        
        # Calculate engagement score and risk level
        engagement_score = calculate_engagement_score(user_data)
        risk_level = assess_risk_level(user_data)
        needs_attention = check_needs_attention({**user_data, "engagement_score": engagement_score, "risk_level": risk_level})
        
        return FarmerDashboardData(
            activity=farmer_activity,
            expenses=expense_metrics,
            forecasting=forecasting_metrics,
            health=health_metrics,
            recommendations=recommendation_metrics,
            engagement_score=engagement_score,
            risk_level=risk_level,
            needs_attention=needs_attention
        )
        
    except Exception as e:
        logger.error("Error getting farmer dashboard data: %s", str(e))
        return None


def get_farmers_list(filters: DashboardFilters) -> Tuple[List[FarmerDashboardData], int]:
    """Get paginated list of farmers with filters - OPTIMIZED VERSION"""
    try:
        # Build query
        query = {}
        
        # Don't filter by is_active if field doesn't exist in database
        # We'll handle this during result processing
        
        if filters.region:
            query["location"] = {"$regex": filters.region, "$options": "i"}
        
        # Get total count
        total_count = users_collection.count_documents(query)
        
        # Get paginated users
        skip = (filters.page - 1) * filters.page_size
        
        # Map sort fields to actual database fields
        sort_field_mapping = {
            "last_activity": "updated_at",
            "engagement_score": "created_at",  # Use created_at as fallback for engagement score
            "created_at": "created_at",
            "updated_at": "updated_at",
            "name": "name",
            "phone_number": "phone_number"
        }
        
        sort_field = sort_field_mapping.get(filters.sort_by, "created_at")
        sort_direction = -1 if filters.sort_order == "desc" else 1
        
        # Fetch users for current page
        users = list(users_collection.find(query)
                    .sort(sort_field, sort_direction)
                    .skip(skip)
                    .limit(filters.page_size))
        
        if not users:
            return [], total_count
        
        # Extract user IDs
        user_ids = [str(user["_id"]) for user in users]
        
        # Get bulk metrics for all users at once
        bulk_metrics = get_bulk_farmer_metrics(tuple(user_ids), filters.time_filter)
        
        farmers_data = []
        
        for user in users:
            user_id = str(user["_id"])
            user_metrics = bulk_metrics.get(user_id, {})
            
            auth_metrics = user_metrics.get("auth_metrics", {})
            expense_metrics_data = user_metrics.get("expense_metrics", {})
            forecasting_metrics_data = user_metrics.get("forecasting_metrics", {})
            health_metrics_data = user_metrics.get("health_metrics", {})
            recommendation_metrics_data = user_metrics.get("recommendation_metrics", {})
            
            # Determine is_active status (default to True if field doesn't exist)
            is_active = user.get("is_active", True)
            
            # Apply is_active filter here if specified
            if filters.is_active is not None and is_active != filters.is_active:
                continue
            
            # Create FarmerActivity
            farmer_activity = FarmerActivity(
                user_id=user_id,
                phone_number=user.get("phone_number", ""),
                name=user.get("name"),
                last_login=auth_metrics.get("last_login"),
                total_logins=auth_metrics.get("total_logins", 0),
                is_active=is_active,
                created_at=user.get("created_at", datetime.utcnow()),
                location=user.get("location")
            )
            
            # Create metric objects
            expense_metrics = ExpenseMetrics(
                user_id=user_id,
                **expense_metrics_data
            )
            
            forecasting_metrics = ForecastingMetrics(
                user_id=user_id,
                **forecasting_metrics_data
            )
            
            health_metrics = HealthAssessmentMetrics(
                user_id=user_id,
                **health_metrics_data
            )
            
            recommendation_metrics = RecommendationMetrics(
                user_id=user_id,
                **recommendation_metrics_data
            )
            
            # Prepare data for calculations
            user_data = {
                "auth_metrics": auth_metrics,
                "expense_metrics": expense_metrics_data,
                "forecasting_metrics": forecasting_metrics_data,
                "health_metrics": health_metrics_data,
                "recommendation_metrics": recommendation_metrics_data
            }
            
            # Calculate engagement score and risk level
            engagement_score = calculate_engagement_score(user_data)
            risk_level = assess_risk_level(user_data)
            needs_attention_flag = check_needs_attention({**user_data, "engagement_score": engagement_score, "risk_level": risk_level})
            
            # Apply additional filters
            if filters.min_engagement_score is not None and engagement_score < filters.min_engagement_score:
                continue
            if filters.max_engagement_score is not None and engagement_score > filters.max_engagement_score:
                continue
            if filters.needs_attention is not None and needs_attention_flag != filters.needs_attention:
                continue
                
            farmer_data = FarmerDashboardData(
                activity=farmer_activity,
                expenses=expense_metrics,
                forecasting=forecasting_metrics,
                health=health_metrics,
                recommendations=recommendation_metrics,
                engagement_score=engagement_score,
                risk_level=risk_level,
                needs_attention=needs_attention_flag
            )
            
            farmers_data.append(farmer_data)
        
        # If we need to sort by engagement_score, do it after calculation
        if filters.sort_by == "engagement_score":
            farmers_data.sort(key=lambda x: x.engagement_score, reverse=(filters.sort_order == "desc"))
        
        return farmers_data, total_count
        
    except Exception as e:
        logger.error("Error getting farmers list: %s", str(e))
        return [], 0


def get_dashboard_summary(time_filter: TimeFilter = TimeFilter.all) -> DashboardSummary:
    """Get overall system summary for admin dashboard - OPTIMIZED VERSION"""
    try:
        # Get user counts using aggregation
        pipeline = [
            {"$facet": {
                "total": [{"$count": "count"}],
                "active": [{"$match": {"is_active": True}}, {"$count": "count"}],
                "by_location": [{"$group": {"_id": "$location", "count": {"$sum": 1}}}],
                "user_ids": [{"$project": {"_id": {"$toString": "$_id"}}}]
            }}
        ]
        
        facet_result = list(users_collection.aggregate(pipeline))[0]
        
        total_farmers = facet_result["total"][0]["count"] if facet_result["total"] else 0
        active_farmers = facet_result["active"][0]["count"] if facet_result["active"] else 0
        inactive_farmers = total_farmers - active_farmers
        
        # Regional distribution
        regional_distribution = {
            doc["_id"]: doc["count"] 
            for doc in facet_result["by_location"] 
            if doc["_id"]
        }
        
        # Get all user IDs
        user_ids = [doc["_id"] for doc in facet_result["user_ids"]]
        
        if not user_ids:
            return DashboardSummary(
                total_farmers=0,
                time_filter=time_filter
            )
        
        # Process in batches for very large datasets
        batch_size = 100
        farmers_needing_attention = 0
        total_revenue = 0.0
        total_expenses = 0.0
        total_profit = 0.0
        
        # Service usage counters
        auth_logins = 0
        expense_entries = 0
        predictions_made = 0
        health_assessments = 0
        recommendations_given = 0
        
        for i in range(0, len(user_ids), batch_size):
            batch_ids = user_ids[i:i + batch_size]
            batch_metrics = get_bulk_farmer_metrics(tuple(batch_ids), time_filter)
            
            for user_id, metrics in batch_metrics.items():
                # Aggregate financial data
                expense_metrics = metrics.get("expense_metrics", {})
                total_revenue += expense_metrics.get("total_revenue", 0)
                total_expenses += expense_metrics.get("total_expenses", 0)
                total_profit += expense_metrics.get("total_profit", 0)
                
                # Count service usage
                auth_logins += metrics.get("auth_metrics", {}).get("total_logins", 0)
                expense_entries += expense_metrics.get("expense_count", 0)
                predictions_made += metrics.get("forecasting_metrics", {}).get("total_predictions", 0)
                health_assessments += metrics.get("health_metrics", {}).get("total_assessments", 0)
                rec_metrics = metrics.get("recommendation_metrics", {})
                recommendations_given += (rec_metrics.get("loan_advice_count", 0) + 
                                        rec_metrics.get("cost_cutting_count", 0))
                
                # Check if needs attention
                engagement_score = calculate_engagement_score(metrics)
                risk_level = assess_risk_level(metrics)
                
                if check_needs_attention({**metrics, "engagement_score": engagement_score, "risk_level": risk_level}):
                    farmers_needing_attention += 1
        
        # Prepare service usage summary
        auth_usage = {
            "total_logins": auth_logins,
            "avg_logins_per_user": auth_logins / total_farmers if total_farmers > 0 else 0
        }
        
        expense_tracking_usage = {
            "total_entries": expense_entries,
            "avg_entries_per_user": expense_entries / total_farmers if total_farmers > 0 else 0
        }
        
        forecasting_usage = {
            "total_predictions": predictions_made,
            "avg_predictions_per_user": predictions_made / total_farmers if total_farmers > 0 else 0
        }
        
        health_assessment_usage = {
            "total_assessments": health_assessments,
            "avg_assessments_per_user": health_assessments / total_farmers if total_farmers > 0 else 0
        }
        
        recommendation_usage = {
            "total_recommendations": recommendations_given,
            "avg_recommendations_per_user": recommendations_given / total_farmers if total_farmers > 0 else 0
        }
        
        return DashboardSummary(
            total_farmers=total_farmers,
            active_farmers=active_farmers,
            inactive_farmers=inactive_farmers,
            farmers_needing_attention=farmers_needing_attention,
            auth_usage=auth_usage,
            expense_tracking_usage=expense_tracking_usage,
            forecasting_usage=forecasting_usage,
            health_assessment_usage=health_assessment_usage,
            recommendation_usage=recommendation_usage,
            total_system_revenue=total_revenue,
            total_system_expenses=total_expenses,
            total_system_profit=total_profit,
            regional_distribution=regional_distribution,
            time_filter=time_filter
        )
        
    except Exception as e:
        logger.error("Error getting dashboard summary: %s", str(e))
        return DashboardSummary()


def search_farmers(query: str, limit: int = 10) -> List[Dict[str, Any]]:
    """Search farmers by name or phone number"""
    try:
        search_query = {
            "$or": [
                {"name": {"$regex": query, "$options": "i"}},
                {"phone_number": {"$regex": query, "$options": "i"}}
            ]
        }
        
        users = list(users_collection.find(search_query).limit(limit))
        
        results = []
        for user in users:
            results.append({
                "id": str(user["_id"]),
                "name": user.get("name", "Unknown"),
                "phone_number": user.get("phone_number"),
                "location": user.get("location"),
                "is_active": user.get("is_active", True)
            })
        
        return results
        
    except Exception as e:
        logger.error("Error searching farmers: %s", str(e))
        return []


def get_service_trends(service: ServiceFilter, time_filter: TimeFilter = TimeFilter.monthly) -> List[Dict[str, Any]]:
    """Get usage trends for a specific service"""
    try:
        # This would require more sophisticated time-series aggregation
        # For now, returning placeholder data
        # In production, you'd aggregate data by time periods
        
        return [
            {"date": "2024-01", "usage_count": 150},
            {"date": "2024-02", "usage_count": 180},
            {"date": "2024-03", "usage_count": 200}
        ]
        
    except Exception as e:
        logger.error("Error getting service trends: %s", str(e))
        return []


def export_farmer_data(user_id: str) -> Dict[str, Any]:
    """Export all data for a specific farmer"""
    try:
        farmer_data = get_farmer_dashboard_data(user_id, TimeFilter.all)
        if not farmer_data:
            return {}
        
        # Convert to dict for export
        return farmer_data.dict()
        
    except Exception as e:
        logger.error("Error exporting farmer data: %s", str(e))
        return {}


def log_admin_activity(admin_id: str, action: str, target_user_id: Optional[str] = None, details: Optional[Dict[str, Any]] = None):
    """Log admin activity for audit trail"""
    try:
        log_details = details or {}
        if target_user_id:
            log_details["target_user_id"] = target_user_id
        
        log_activity(
            user_id=admin_id,
            action=action,
            service="admin_dashboard",
            details=log_details
        )
        
    except Exception as e:
        logger.error("Error logging admin activity: %s", str(e))


# Admin User Management Functions
def get_admin_users() -> List[Dict[str, Any]]:
    """Get list of all admin users"""
    try:
        admins = list(users_collection.find({"is_admin": True}))
        
        # Format for frontend
        formatted_admins = []
        for admin in admins:
            formatted_admins.append({
                "_id": {"$oid": str(admin["_id"])},
                "name": admin.get("name", "Unknown"),
                "phone_number": admin.get("phone_number"),
                "is_active": admin.get("is_active", True),
                "is_admin": admin.get("is_admin", False),
                "is_super_admin": admin.get("is_super_admin", False),
                "permissions": admin.get("permissions", []),
                "created_at": {"$date": {"$numberLong": str(int(admin.get("created_at", datetime.utcnow()).timestamp() * 1000))}}
            })
        
        return formatted_admins
        
    except Exception as e:
        logger.error("Error getting admin users: %s", str(e))
        return []


def create_admin_user(admin_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Create a new admin user"""
    try:
        import bcrypt
        
        # Validate required fields
        required_fields = ["name", "phone_number", "password"]
        for field in required_fields:
            if field not in admin_data:
                raise ValueError(f"Missing required field: {field}")
        
        # Check if user already exists
        existing_user = users_collection.find_one({"phone_number": admin_data["phone_number"]})
        if existing_user:
            if existing_user.get("is_admin"):
                raise ValueError("User is already an admin")
            else:
                # Update existing user to admin
                return update_user_to_admin(str(existing_user["_id"]), admin_data)
        
        # Hash password
        hashed_password = bcrypt.hashpw(
            admin_data["password"].encode('utf-8'), 
            bcrypt.gensalt()
        )
        
        # Create new admin user
        new_admin = {
            "name": admin_data["name"],
            "phone_number": admin_data["phone_number"],
            "hashed_password": hashed_password.decode('utf-8'),
            "is_active": True,
            "is_admin": True,
            "is_super_admin": admin_data.get("is_super_admin", False),
            "permissions": admin_data.get("permissions", []),
            "created_at": datetime.utcnow(),
            "email": admin_data.get("email")
        }
        
        result = users_collection.insert_one(new_admin)
        
        if result.inserted_id:
            new_admin["_id"] = result.inserted_id
            return {
                "_id": {"$oid": str(new_admin["_id"])},
                "name": new_admin["name"],
                "phone_number": new_admin["phone_number"],
                "is_active": new_admin["is_active"],
                "is_admin": new_admin["is_admin"],
                "is_super_admin": new_admin["is_super_admin"],
                "permissions": new_admin["permissions"],
                "created_at": {"$date": {"$numberLong": str(int(new_admin["created_at"].timestamp() * 1000))}}
            }
        
        return None
        
    except Exception as e:
        logger.error("Error creating admin user: %s", str(e))
        raise


def update_user_to_admin(user_id: str, admin_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Update existing user to admin"""
    try:
        update_data = {
            "is_admin": True,
            "is_super_admin": admin_data.get("is_super_admin", False),
            "permissions": admin_data.get("permissions", []),
            "updated_at": datetime.utcnow()
        }
        
        result = users_collection.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": update_data}
        )
        
        if result.modified_count > 0:
            updated_user = users_collection.find_one({"_id": ObjectId(user_id)})
            return {
                "_id": {"$oid": str(updated_user["_id"])},
                "name": updated_user.get("name", "Unknown"),
                "phone_number": updated_user.get("phone_number"),
                "is_active": updated_user.get("is_active", True),
                "is_admin": updated_user.get("is_admin"),
                "is_super_admin": updated_user.get("is_super_admin"),
                "permissions": updated_user.get("permissions", []),
                "created_at": {"$date": {"$numberLong": str(int(updated_user.get("created_at", datetime.utcnow()).timestamp() * 1000))}}
            }
        
        return None
        
    except Exception as e:
        logger.error("Error updating user to admin: %s", str(e))
        raise


def update_admin_user(user_id: str, update_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Update admin user details"""
    try:
        # Don't allow password updates through this function
        update_data.pop("password", None)
        update_data.pop("hashed_password", None)
        
        # Add updated timestamp
        update_data["updated_at"] = datetime.utcnow()
        
        result = users_collection.update_one(
            {"_id": ObjectId(user_id), "is_admin": True},
            {"$set": update_data}
        )
        
        if result.modified_count > 0:
            updated_user = users_collection.find_one({"_id": ObjectId(user_id)})
            return {
                "_id": {"$oid": str(updated_user["_id"])},
                "name": updated_user.get("name", "Unknown"),
                "phone_number": updated_user.get("phone_number"),
                "is_active": updated_user.get("is_active", True),
                "is_admin": updated_user.get("is_admin"),
                "is_super_admin": updated_user.get("is_super_admin"),
                "permissions": updated_user.get("permissions", []),
                "created_at": {"$date": {"$numberLong": str(int(updated_user.get("created_at", datetime.utcnow()).timestamp() * 1000))}}
            }
        
        return None
        
    except Exception as e:
        logger.error("Error updating admin user: %s", str(e))
        raise


def delete_admin_user(user_id: str) -> bool:
    """Remove admin privileges from a user (doesn't delete the user)"""
    try:
        result = users_collection.update_one(
            {"_id": ObjectId(user_id), "is_admin": True},
            {"$set": {
                "is_admin": False,
                "is_super_admin": False,
                "permissions": [],
                "updated_at": datetime.utcnow()
            }}
        )
        
        return result.modified_count > 0
        
    except Exception as e:
        logger.error("Error deleting admin user: %s", str(e))
        return False 