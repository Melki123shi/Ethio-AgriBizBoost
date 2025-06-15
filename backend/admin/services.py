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
    log_activity
)

logger = logging.getLogger(__name__)


def get_farmer_dashboard_data(user_id: str, time_filter: TimeFilter = TimeFilter.all) -> Optional[FarmerDashboardData]:
    """Get comprehensive dashboard data for a single farmer"""
    try:
        # Get user basic info
        user = users_collection.find_one({"_id": ObjectId(user_id)})
        if not user:
            return None
        
        # Get auth metrics
        auth_metrics = get_user_auth_metrics(user_id, time_filter)
        
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
        
        # Get metrics from all services
        expense_metrics_data = get_user_expense_metrics(user_id, time_filter)
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
    """Get paginated list of farmers with filters"""
    try:
        # Build query
        query = {}
        
        if filters.is_active is not None:
            query["is_active"] = filters.is_active
        
        if filters.region:
            query["location"] = {"$regex": filters.region, "$options": "i"}
        
        # Get total count
        total_count = users_collection.count_documents(query)
        
        # Get paginated users
        skip = (filters.page - 1) * filters.page_size
        sort_field = filters.sort_by if filters.sort_by else "created_at"
        sort_direction = -1 if filters.sort_order == "desc" else 1
        
        users = list(users_collection.find(query)
                    .sort(sort_field, sort_direction)
                    .skip(skip)
                    .limit(filters.page_size))
        
        farmers_data = []
        
        for user in users:
            farmer_data = get_farmer_dashboard_data(str(user["_id"]), filters.time_filter)
            if farmer_data:
                # Apply additional filters
                if filters.min_engagement_score is not None and farmer_data.engagement_score < filters.min_engagement_score:
                    continue
                if filters.max_engagement_score is not None and farmer_data.engagement_score > filters.max_engagement_score:
                    continue
                if filters.needs_attention is not None and farmer_data.needs_attention != filters.needs_attention:
                    continue
                
                farmers_data.append(farmer_data)
        
        return farmers_data, total_count
        
    except Exception as e:
        logger.error("Error getting farmers list: %s", str(e))
        return [], 0


def get_dashboard_summary(time_filter: TimeFilter = TimeFilter.all) -> DashboardSummary:
    """Get overall system summary for admin dashboard"""
    try:
        # Get user counts
        total_farmers = users_collection.count_documents({})
        active_farmers = users_collection.count_documents({"is_active": True})
        inactive_farmers = total_farmers - active_farmers
        
        # Get all users for detailed analysis
        users = list(users_collection.find({}))
        
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
        
        regional_distribution = {}
        
        for user in users:
            user_id = str(user["_id"])
            
            # Get user metrics
            auth_metrics = get_user_auth_metrics(user_id, time_filter)
            expense_metrics = get_user_expense_metrics(user_id, time_filter)
            forecast_metrics = get_user_forecasting_metrics(user_id, time_filter)
            health_metrics = get_user_health_metrics(user_id, time_filter)
            rec_metrics = get_user_recommendation_metrics(user_id, time_filter)
            
            # Aggregate financial data
            total_revenue += expense_metrics.get("total_revenue", 0)
            total_expenses += expense_metrics.get("total_expenses", 0)
            total_profit += expense_metrics.get("total_profit", 0)
            
            # Count service usage
            auth_logins += auth_metrics.get("total_logins", 0)
            expense_entries += expense_metrics.get("expense_count", 0)
            predictions_made += forecast_metrics.get("total_predictions", 0)
            health_assessments += health_metrics.get("total_assessments", 0)
            recommendations_given += (rec_metrics.get("loan_advice_count", 0) + 
                                    rec_metrics.get("cost_cutting_count", 0))
            
            # Check if needs attention
            user_data = {
                "auth_metrics": auth_metrics,
                "expense_metrics": expense_metrics,
                "forecasting_metrics": forecast_metrics,
                "health_metrics": health_metrics,
                "recommendation_metrics": rec_metrics
            }
            
            engagement_score = calculate_engagement_score(user_data)
            risk_level = assess_risk_level(user_data)
            
            if check_needs_attention({**user_data, "engagement_score": engagement_score, "risk_level": risk_level}):
                farmers_needing_attention += 1
            
            # Regional distribution
            location = user.get("location", "Unknown")
            regional_distribution[location] = regional_distribution.get(location, 0) + 1
        
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