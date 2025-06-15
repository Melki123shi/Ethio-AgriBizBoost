from pymongo import MongoClient
from bson import ObjectId
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional
import config
from admin.models import TimeFilter

# MongoDB client
client = MongoClient(config.MONGO_URI)
db = client[config.DB_NAME]

# Collections from all services
users_collection = db.users
refresh_tokens_collection = db.refresh_tokens
expenses_collection = db.expenses
assessments_collection = db.assessments
predictions_collection = db.predictions
health_assessments_collection = db.health_assessments
loan_advice_collection = db.loan_advice
cost_cutting_collection = db.cost_cutting_strategies
activity_logs_collection = db.activity_logs


def get_time_filter_query(time_filter: TimeFilter) -> Dict[str, Any]:
    """Generate MongoDB query for time filtering"""
    if time_filter == TimeFilter.all:
        return {}
    
    now = datetime.utcnow()
    
    if time_filter == TimeFilter.daily:
        start_date = now - timedelta(days=1)
    elif time_filter == TimeFilter.weekly:
        start_date = now - timedelta(days=7)
    elif time_filter == TimeFilter.monthly:
        start_date = now - timedelta(days=30)
    elif time_filter == TimeFilter.yearly:
        start_date = now - timedelta(days=365)
    else:
        return {}
    
    return {"$gte": start_date}


def log_activity(user_id: str, action: str, service: str, details: Optional[Dict[str, Any]] = None, ip_address: Optional[str] = None, user_agent: Optional[str] = None):
    """Log user activity for audit trail"""
    activity_logs_collection.insert_one({
        "user_id": user_id,
        "action": action,
        "service": service,
        "timestamp": datetime.utcnow(),
        "details": details,
        "ip_address": ip_address,
        "user_agent": user_agent
    })


def get_user_auth_metrics(user_id: str, time_filter: TimeFilter) -> Dict[str, Any]:
    """Get authentication metrics for a user"""
    time_query = get_time_filter_query(time_filter)
    
    # Count login activities
    login_count = activity_logs_collection.count_documents({
        "user_id": user_id,
        "action": "login",
        "timestamp": time_query
    }) if time_query else 0
    
    # Get last login
    last_login_doc = activity_logs_collection.find_one(
        {"user_id": user_id, "action": "login"},
        sort=[("timestamp", -1)]
    )
    last_login = last_login_doc["timestamp"] if last_login_doc else None
    
    return {
        "total_logins": login_count,
        "last_login": last_login
    }


def get_user_expense_metrics(user_id: str, time_filter: TimeFilter) -> Dict[str, Any]:
    """Get expense tracking metrics for a user"""
    time_query = get_time_filter_query(time_filter)
    
    # Aggregate expense data
    expense_pipeline = [
        {"$match": {"user_id": user_id}}
    ]
    
    if time_query:
        expense_pipeline.append({"$match": {"date": time_query}})
    
    expense_pipeline.extend([
        {
            "$group": {
                "_id": None,
                "total_expenses": {"$sum": "$price_etb"},
                "expense_count": {"$sum": 1},
                "goods": {"$push": "$goods"},
                "last_activity": {"$max": "$date"}
            }
        }
    ])
    
    expense_result = list(expenses_collection.aggregate(expense_pipeline))
    expense_data = expense_result[0] if expense_result else {
        "total_expenses": 0.0,
        "expense_count": 0,
        "goods": [],
        "last_activity": None
    }
    
    # Get assessment metrics
    assessment_pipeline = [
        {"$match": {"user_id": user_id}}
    ]
    
    if time_query:
        assessment_pipeline.append({"$match": {"date": time_query}})
    
    assessment_pipeline.extend([
        {
            "$group": {
                "_id": None,
                "total_revenue": {"$sum": {"$multiply": ["$profit", 1]}},  # Assuming profit is revenue - expenses
                "total_profit": {"$sum": "$profit"},
                "assessment_count": {"$sum": 1},
                "financial_stability_avg": {"$avg": {"$toDouble": "$financial_stability"}},
                "cash_flow_avg": {"$avg": {"$toDouble": "$cash_flow"}}
            }
        }
    ])
    
    assessment_result = list(assessments_collection.aggregate(assessment_pipeline))
    assessment_data = assessment_result[0] if assessment_result else {
        "total_revenue": 0.0,
        "total_profit": 0.0,
        "assessment_count": 0,
        "financial_stability_avg": None,
        "cash_flow_avg": None
    }
    
    # Count most traded goods
    goods_count = {}
    for good in expense_data.get("goods", []):
        goods_count[good] = goods_count.get(good, 0) + 1
    
    most_traded_goods = [
        {"name": good, "count": count}
        for good, count in sorted(goods_count.items(), key=lambda x: x[1], reverse=True)[:5]
    ]
    
    return {
        "total_expenses": expense_data.get("total_expenses", 0.0),
        "total_revenue": expense_data.get("total_expenses", 0.0) + assessment_data.get("total_profit", 0.0),
        "total_profit": assessment_data.get("total_profit", 0.0),
        "expense_count": expense_data.get("expense_count", 0),
        "assessment_count": assessment_data.get("assessment_count", 0),
        "most_traded_goods": most_traded_goods,
        "financial_stability_avg": assessment_data.get("financial_stability_avg"),
        "cash_flow_avg": assessment_data.get("cash_flow_avg"),
        "last_activity": expense_data.get("last_activity")
    }


def get_user_forecasting_metrics(user_id: str, time_filter: TimeFilter) -> Dict[str, Any]:
    """Get forecasting metrics for a user"""
    time_query = get_time_filter_query(time_filter)
    
    # Query predictions
    query = {"user_id": user_id}
    if time_query:
        query["timestamp"] = time_query
    
    predictions = list(predictions_collection.find(query))
    
    regions = set()
    crops = set()
    last_prediction = None
    
    for pred in predictions:
        if "region" in pred:
            regions.update(pred.get("region", []))
        if "cropname" in pred:
            crops.update(pred.get("cropname", []))
        if "timestamp" in pred:
            if not last_prediction or pred["timestamp"] > last_prediction:
                last_prediction = pred["timestamp"]
    
    # Count query frequencies
    query_count = {}
    for pred in predictions:
        key = f"{pred.get('region', ['Unknown'])[0]}_{pred.get('cropname', ['Unknown'])[0]}"
        query_count[key] = query_count.get(key, 0) + 1
    
    most_frequent_queries = [
        {"query": key, "count": count}
        for key, count in sorted(query_count.items(), key=lambda x: x[1], reverse=True)[:5]
    ]
    
    return {
        "total_predictions": len(predictions),
        "regions_queried": list(regions),
        "crops_queried": list(crops),
        "last_prediction": last_prediction,
        "most_frequent_queries": most_frequent_queries
    }


def get_user_health_metrics(user_id: str, time_filter: TimeFilter) -> Dict[str, Any]:
    """Get health assessment metrics for a user"""
    time_query = get_time_filter_query(time_filter)
    
    query = {"user_id": user_id}
    if time_query:
        query["timestamp"] = time_query
    
    assessments = list(health_assessments_collection.find(query))
    
    if not assessments:
        return {
            "total_assessments": 0,
            "crop_types_assessed": [],
            "average_profit_margin": None,
            "total_subsidies": 0.0,
            "last_assessment": None
        }
    
    crop_types = set()
    total_profit = 0.0
    total_revenue = 0.0
    total_subsidies = 0.0
    last_assessment = None
    
    for assessment in assessments:
        if "cropType" in assessment:
            crop_types.add(assessment["cropType"])
        
        sale_price = assessment.get("salePricePerQuintal", 0) * assessment.get("quantitySold", 0)
        total_cost = assessment.get("totalCost", 0)
        profit = sale_price - total_cost
        
        total_profit += profit
        total_revenue += sale_price
        total_subsidies += assessment.get("governmentSubsidy", 0)
        
        if "timestamp" in assessment:
            if not last_assessment or assessment["timestamp"] > last_assessment:
                last_assessment = assessment["timestamp"]
    
    avg_profit_margin = (total_profit / total_revenue * 100) if total_revenue > 0 else None
    
    return {
        "total_assessments": len(assessments),
        "crop_types_assessed": list(crop_types),
        "average_profit_margin": avg_profit_margin,
        "total_subsidies": total_subsidies,
        "last_assessment": last_assessment
    }


def get_user_recommendation_metrics(user_id: str, time_filter: TimeFilter) -> Dict[str, Any]:
    """Get recommendation metrics for a user"""
    time_query = get_time_filter_query(time_filter)
    
    # Query loan advice
    loan_query = {"user_id": user_id}
    if time_query:
        loan_query["timestamp"] = time_query
    
    loan_count = loan_advice_collection.count_documents(loan_query)
    
    # Query cost cutting strategies
    cost_query = {"user_id": user_id}
    if time_query:
        cost_query["timestamp"] = time_query
    
    cost_count = cost_cutting_collection.count_documents(cost_query)
    
    # Get last recommendation
    last_loan = loan_advice_collection.find_one(
        {"user_id": user_id},
        sort=[("timestamp", -1)]
    )
    last_cost = cost_cutting_collection.find_one(
        {"user_id": user_id},
        sort=[("timestamp", -1)]
    )
    
    last_recommendation = None
    if last_loan and last_cost:
        last_recommendation = max(
            last_loan.get("timestamp", datetime.min),
            last_cost.get("timestamp", datetime.min)
        )
    elif last_loan:
        last_recommendation = last_loan.get("timestamp")
    elif last_cost:
        last_recommendation = last_cost.get("timestamp")
    
    topics = []
    if loan_count > 0:
        topics.append("loan_advice")
    if cost_count > 0:
        topics.append("cost_cutting_strategies")
    
    return {
        "loan_advice_count": loan_count,
        "cost_cutting_count": cost_count,
        "last_recommendation": last_recommendation,
        "recommendation_topics": topics
    }


def calculate_engagement_score(user_data: Dict[str, Any]) -> float:
    """Calculate farmer engagement score based on activity across services"""
    score = 0.0
    max_score = 100.0
    
    # Auth activity (20 points)
    if user_data.get("auth_metrics", {}).get("total_logins", 0) > 0:
        score += min(20, user_data["auth_metrics"]["total_logins"] * 2)
    
    # Expense tracking (20 points)
    expense_metrics = user_data.get("expense_metrics", {})
    if expense_metrics.get("expense_count", 0) > 0:
        score += min(10, expense_metrics["expense_count"] * 0.5)
    if expense_metrics.get("assessment_count", 0) > 0:
        score += min(10, expense_metrics["assessment_count"] * 2)
    
    # Forecasting (20 points)
    forecast_metrics = user_data.get("forecasting_metrics", {})
    if forecast_metrics.get("total_predictions", 0) > 0:
        score += min(20, forecast_metrics["total_predictions"] * 2)
    
    # Health assessment (20 points)
    health_metrics = user_data.get("health_metrics", {})
    if health_metrics.get("total_assessments", 0) > 0:
        score += min(20, health_metrics["total_assessments"] * 4)
    
    # Recommendations (20 points)
    rec_metrics = user_data.get("recommendation_metrics", {})
    if rec_metrics.get("loan_advice_count", 0) > 0:
        score += min(10, rec_metrics["loan_advice_count"] * 5)
    if rec_metrics.get("cost_cutting_count", 0) > 0:
        score += min(10, rec_metrics["cost_cutting_count"] * 5)
    
    return min(score, max_score)


def assess_risk_level(user_data: Dict[str, Any]) -> str:
    """Assess farmer risk level based on financial metrics"""
    expense_metrics = user_data.get("expense_metrics", {})
    
    if expense_metrics.get("total_profit", 0) < 0:
        return "high"
    
    stability = expense_metrics.get("financial_stability_avg", 0)
    cash_flow = expense_metrics.get("cash_flow_avg", 0)
    
    if stability and cash_flow:
        avg_financial_health = (stability + cash_flow) / 2
        if avg_financial_health < 30:
            return "high"
        elif avg_financial_health < 60:
            return "medium"
        else:
            return "low"
    
    return "unknown"


def check_needs_attention(user_data: Dict[str, Any]) -> bool:
    """Check if farmer needs attention from admin"""
    # Check for inactivity
    last_activities = []
    
    for key in ["auth_metrics", "expense_metrics", "forecasting_metrics", "health_metrics", "recommendation_metrics"]:
        metrics = user_data.get(key, {})
        if "last_login" in metrics and metrics["last_login"]:
            last_activities.append(metrics["last_login"])
        elif "last_activity" in metrics and metrics["last_activity"]:
            last_activities.append(metrics["last_activity"])
        elif "last_prediction" in metrics and metrics["last_prediction"]:
            last_activities.append(metrics["last_prediction"])
        elif "last_assessment" in metrics and metrics["last_assessment"]:
            last_activities.append(metrics["last_assessment"])
        elif "last_recommendation" in metrics and metrics["last_recommendation"]:
            last_activities.append(metrics["last_recommendation"])
    
    if last_activities:
        most_recent = max(last_activities)
        days_inactive = (datetime.utcnow() - most_recent).days
        if days_inactive > 30:
            return True
    
    # Check for financial issues
    if user_data.get("risk_level") == "high":
        return True
    
    # Check for low engagement
    if user_data.get("engagement_score", 0) < 20:
        return True
    
    return False


def get_admin_user(user_id: str) -> Optional[Dict[str, Any]]:
    """Get admin user by ID"""
    user = users_collection.find_one({
        "_id": ObjectId(user_id),
        "is_admin": True
    })
    return user


def check_admin_permission(user_id: str, permission: str) -> bool:
    """Check if admin user has specific permission"""
    user = get_admin_user(user_id)
    if not user:
        return False
    
    if user.get("is_super_admin", False):
        return True
    
    return permission in user.get("permissions", []) 