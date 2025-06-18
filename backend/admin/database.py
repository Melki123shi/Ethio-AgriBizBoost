from pymongo import MongoClient, ASCENDING, DESCENDING
from bson import ObjectId
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional
from concurrent.futures import ThreadPoolExecutor
import json
import hashlib
from functools import lru_cache
import config
from admin.models import TimeFilter

# MongoDB client with connection pooling for better performance
client = MongoClient(
    config.MONGO_URI,
    maxPoolSize=50,
    minPoolSize=10,
    maxIdleTimeMS=30000
)
db = client[config.DB_NAME]

# Thread pool for parallel processing
executor = ThreadPoolExecutor(max_workers=10)

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


def ensure_indexes():
    """Create necessary indexes for optimal performance"""
    try:
        # Users indexes
        users_collection.create_index([("phone_number", ASCENDING)], unique=True)
        users_collection.create_index([("is_active", ASCENDING)])
        users_collection.create_index([("created_at", DESCENDING)])
        users_collection.create_index([("location", ASCENDING)])
        
        # Activity logs indexes
        activity_logs_collection.create_index([("user_id", ASCENDING), ("timestamp", DESCENDING)])
        activity_logs_collection.create_index([("action", ASCENDING)])
        
        # Expenses indexes
        expenses_collection.create_index([("user_id", ASCENDING), ("date", DESCENDING)])
        
        # Predictions indexes
        predictions_collection.create_index([("user_id", ASCENDING), ("timestamp", DESCENDING)])
        
        # Health assessments indexes
        health_assessments_collection.create_index([("user_id", ASCENDING), ("timestamp", DESCENDING)])
        
        # Loan advice indexes
        loan_advice_collection.create_index([("user_id", ASCENDING), ("timestamp", DESCENDING)])
        
        # Cost cutting indexes
        cost_cutting_collection.create_index([("user_id", ASCENDING), ("timestamp", DESCENDING)])
        
        print("Database indexes created successfully")
    except Exception as e:
        print(f"Index creation error: {e}")


@lru_cache(maxsize=128)
def get_bulk_farmer_metrics(user_ids_tuple: tuple, time_filter: TimeFilter) -> Dict[str, Dict[str, Any]]:
    """Get metrics for multiple farmers in bulk using parallel processing
    
    This function dramatically improves performance by:
    1. Fetching data for multiple users in single queries
    2. Using parallel processing for independent operations
    3. Caching results
    """
    try:
        user_ids = list(user_ids_tuple)  # Convert tuple back to list
        time_query = get_time_filter_query(time_filter)
        results = {}
        
        # Create a new executor for this operation to avoid shutdown issues
        with ThreadPoolExecutor(max_workers=5) as local_executor:
            # Parallel aggregation pipelines
            def get_auth_metrics():
                pipeline = [
                    {"$match": {"user_id": {"$in": user_ids}, "action": "login"}},
                ]
                if time_query:
                    pipeline.append({"$match": {"timestamp": time_query}})
                
                pipeline.extend([
                    {"$group": {
                        "_id": "$user_id",
                        "total_logins": {"$sum": 1},
                        "last_login": {"$max": "$timestamp"}
                    }}
                ])
                
                return {doc["_id"]: doc for doc in activity_logs_collection.aggregate(pipeline)}
            
            def get_expense_metrics():
                pipeline = [
                    {"$match": {"user_id": {"$in": user_ids}}},
                ]
                if time_query:
                    pipeline.append({"$match": {"date": time_query}})
                
                pipeline.extend([
                    {"$group": {
                        "_id": "$user_id",
                        "total_expenses": {"$sum": "$price_etb"},
                        "expense_count": {"$sum": 1},
                        "goods": {"$push": "$goods"},
                        "last_activity": {"$max": "$date"}
                    }}
                ])
                
                expenses_data = {doc["_id"]: doc for doc in expenses_collection.aggregate(pipeline, allowDiskUse=True)}
                
                # Get assessment data
                assessment_pipeline = [
                    {"$match": {"user_id": {"$in": user_ids}}},
                ]
                if time_query:
                    assessment_pipeline.append({"$match": {"date": time_query}})
                
                assessment_pipeline.extend([
                    {"$group": {
                        "_id": "$user_id",
                        "total_profit": {"$sum": "$profit"},
                        "assessment_count": {"$sum": 1},
                        "financial_stability_avg": {"$avg": {"$toDouble": "$financial_stability"}},
                        "cash_flow_avg": {"$avg": {"$toDouble": "$cash_flow"}}
                    }}
                ])
                
                assessments_data = {doc["_id"]: doc for doc in assessments_collection.aggregate(assessment_pipeline, allowDiskUse=True)}
                
                # Merge data
                merged = {}
                for uid in user_ids:
                    expense = expenses_data.get(uid, {})
                    assessment = assessments_data.get(uid, {})
                    
                    # Process goods
                    goods_count = {}
                    for good in expense.get("goods", []):
                        goods_count[good] = goods_count.get(good, 0) + 1
                    
                    most_traded_goods = [
                        {"name": good, "count": count}
                        for good, count in sorted(goods_count.items(), key=lambda x: x[1], reverse=True)[:5]
                    ]
                    
                    merged[uid] = {
                        "total_expenses": expense.get("total_expenses", 0.0),
                        "total_revenue": expense.get("total_expenses", 0.0) + assessment.get("total_profit", 0.0),
                        "total_profit": assessment.get("total_profit", 0.0),
                        "expense_count": expense.get("expense_count", 0),
                        "assessment_count": assessment.get("assessment_count", 0),
                        "most_traded_goods": most_traded_goods,
                        "financial_stability_avg": assessment.get("financial_stability_avg"),
                        "cash_flow_avg": assessment.get("cash_flow_avg"),
                        "last_activity": expense.get("last_activity")
                    }
                
                return merged
            
            def get_forecasting_metrics():
                pipeline = [
                    {"$match": {"user_id": {"$in": user_ids}}},
                ]
                if time_query:
                    pipeline.append({"$match": {"timestamp": time_query}})
                
                pipeline.extend([
                    {"$group": {
                        "_id": "$user_id",
                        "total_predictions": {"$sum": 1},
                        "regions": {"$addToSet": "$region"},
                        "crops": {"$addToSet": "$cropname"},
                        "last_prediction": {"$max": "$timestamp"},
                        "queries": {"$push": {"region": "$region", "crop": "$cropname"}}
                    }}
                ])
                
                forecast_data = {}
                for doc in predictions_collection.aggregate(pipeline, allowDiskUse=True):
                    # Process query frequencies
                    query_count = {}
                    for query in doc.get("queries", []):
                        region_list = query.get('region', ['Unknown'])
                        crop_list = query.get('crop', ['Unknown'])
                        region = region_list[0] if isinstance(region_list, list) and region_list else 'Unknown'
                        crop = crop_list[0] if isinstance(crop_list, list) and crop_list else 'Unknown'
                        key = f"{region}_{crop}"
                        query_count[key] = query_count.get(key, 0) + 1
                    
                    most_frequent = [
                        {"query": k, "count": v}
                        for k, v in sorted(query_count.items(), key=lambda x: x[1], reverse=True)[:5]
                    ]
                    
                    # Flatten nested lists
                    regions = doc.get("regions", [])
                    crops = doc.get("crops", [])
                    flat_regions = []
                    flat_crops = []
                    
                    for r in regions:
                        if isinstance(r, list):
                            flat_regions.extend(r)
                        else:
                            flat_regions.append(r)
                    
                    for c in crops:
                        if isinstance(c, list):
                            flat_crops.extend(c)
                        else:
                            flat_crops.append(c)
                    
                    forecast_data[doc["_id"]] = {
                        "total_predictions": doc.get("total_predictions", 0),
                        "regions_queried": list(set(flat_regions)),
                        "crops_queried": list(set(flat_crops)),
                        "last_prediction": doc.get("last_prediction"),
                        "most_frequent_queries": most_frequent
                    }
                
                return forecast_data
            
            def get_health_metrics():
                pipeline = [
                    {"$match": {"user_id": {"$in": user_ids}}},
                ]
                if time_query:
                    pipeline.append({"$match": {"timestamp": time_query}})
                
                pipeline.extend([
                    {"$group": {
                        "_id": "$user_id",
                        "total_assessments": {"$sum": 1},
                        "crop_types": {"$addToSet": "$cropType"},
                        "total_subsidies": {"$sum": "$governmentSubsidy"},
                        "last_assessment": {"$max": "$timestamp"},
                        "assessments": {"$push": {
                            "sale_price": {"$multiply": ["$salePricePerQuintal", "$quantitySold"]},
                            "total_cost": "$totalCost"
                        }}
                    }}
                ])
                
                health_data = {}
                for doc in health_assessments_collection.aggregate(pipeline, allowDiskUse=True):
                    # Calculate profit margin
                    total_revenue = sum(a.get("sale_price", 0) for a in doc.get("assessments", []))
                    total_cost = sum(a.get("total_cost", 0) for a in doc.get("assessments", []))
                    total_profit = total_revenue - total_cost
                    avg_profit_margin = (total_profit / total_revenue * 100) if total_revenue > 0 else None
                    
                    health_data[doc["_id"]] = {
                        "total_assessments": doc.get("total_assessments", 0),
                        "crop_types_assessed": list(doc.get("crop_types", [])),
                        "average_profit_margin": avg_profit_margin,
                        "total_subsidies": doc.get("total_subsidies", 0.0),
                        "last_assessment": doc.get("last_assessment")
                    }
                
                return health_data
            
            def get_recommendation_metrics():
                # Loan advice
                loan_pipeline = [
                    {"$match": {"user_id": {"$in": user_ids}}},
                ]
                if time_query:
                    loan_pipeline.append({"$match": {"timestamp": time_query}})
                
                loan_pipeline.extend([
                    {"$group": {
                        "_id": "$user_id",
                        "count": {"$sum": 1},
                        "last_timestamp": {"$max": "$timestamp"}
                    }}
                ])
                
                loan_data = {doc["_id"]: doc for doc in loan_advice_collection.aggregate(loan_pipeline)}
                
                # Cost cutting
                cost_pipeline = [
                    {"$match": {"user_id": {"$in": user_ids}}},
                ]
                if time_query:
                    cost_pipeline.append({"$match": {"timestamp": time_query}})
                
                cost_pipeline.extend([
                    {"$group": {
                        "_id": "$user_id",
                        "count": {"$sum": 1},
                        "last_timestamp": {"$max": "$timestamp"}
                    }}
                ])
                
                cost_data = {doc["_id"]: doc for doc in cost_cutting_collection.aggregate(cost_pipeline)}
                
                # Merge recommendation data
                rec_data = {}
                for uid in user_ids:
                    loan = loan_data.get(uid, {})
                    cost = cost_data.get(uid, {})
                    
                    last_recommendation = None
                    if loan.get("last_timestamp") and cost.get("last_timestamp"):
                        last_recommendation = max(loan["last_timestamp"], cost["last_timestamp"])
                    elif loan.get("last_timestamp"):
                        last_recommendation = loan["last_timestamp"]
                    elif cost.get("last_timestamp"):
                        last_recommendation = cost["last_timestamp"]
                    
                    topics = []
                    if loan.get("count", 0) > 0:
                        topics.append("loan_advice")
                    if cost.get("count", 0) > 0:
                        topics.append("cost_cutting_strategies")
                    
                    rec_data[uid] = {
                        "loan_advice_count": loan.get("count", 0),
                        "cost_cutting_count": cost.get("count", 0),
                        "last_recommendation": last_recommendation,
                        "recommendation_topics": topics
                    }
                
                return rec_data
            
            # Execute all queries in parallel
            auth_future = local_executor.submit(get_auth_metrics)
            expense_future = local_executor.submit(get_expense_metrics)
            forecast_future = local_executor.submit(get_forecasting_metrics)
            health_future = local_executor.submit(get_health_metrics)
            rec_future = local_executor.submit(get_recommendation_metrics)
            
            auth_data = auth_future.result()
            expense_data = expense_future.result()
            forecast_data = forecast_future.result()
            health_data = health_future.result()
            rec_data = rec_future.result()
            
            # Combine all metrics
            for uid in user_ids:
                results[uid] = {
                    "auth_metrics": auth_data.get(uid, {"total_logins": 0, "last_login": None}),
                    "expense_metrics": expense_data.get(uid, {}),
                    "forecasting_metrics": forecast_data.get(uid, {}),
                    "health_metrics": health_data.get(uid, {}),
                    "recommendation_metrics": rec_data.get(uid, {})
                }
        
        return results
    except Exception as e:
        print(f"Error in get_bulk_farmer_metrics: {e}")
        return {} 