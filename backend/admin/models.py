from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class TimeFilter(str, Enum):
    daily = "daily"
    weekly = "weekly"
    monthly = "monthly"
    yearly = "yearly"
    all = "all"


class ServiceFilter(str, Enum):
    auth = "auth"
    expense_tracking = "expense_tracking"
    forecasting = "forecasting"
    health_assessment = "health_assessment"
    loan_advice = "loan_advice"
    cost_cutting = "cost_cutting"
    all = "all"


class FarmerActivity(BaseModel):
    user_id: str = Field(..., description="User ID")
    phone_number: str = Field(..., description="Phone number")
    name: Optional[str] = Field(None, description="Farmer name")
    last_login: Optional[datetime] = Field(None, description="Last login timestamp")
    total_logins: int = Field(0, description="Total number of logins")
    is_active: bool = Field(True, description="Whether user is active")
    created_at: datetime = Field(..., description="Account creation date")
    location: Optional[str] = Field(None, description="Farmer location")


class ExpenseMetrics(BaseModel):
    user_id: str = Field(..., description="User ID")
    total_expenses: float = Field(0.0, description="Total expenses")
    total_revenue: float = Field(0.0, description="Total revenue")
    total_profit: float = Field(0.0, description="Total profit")
    expense_count: int = Field(0, description="Number of expense entries")
    assessment_count: int = Field(0, description="Number of assessments")
    most_traded_goods: List[Dict[str, Any]] = Field(default_factory=list)
    financial_stability_avg: Optional[float] = Field(None)
    cash_flow_avg: Optional[float] = Field(None)
    last_activity: Optional[datetime] = Field(None)


class ForecastingMetrics(BaseModel):
    user_id: str = Field(..., description="User ID")
    total_predictions: int = Field(0, description="Total predictions made")
    regions_queried: List[str] = Field(default_factory=list)
    crops_queried: List[str] = Field(default_factory=list)
    last_prediction: Optional[datetime] = Field(None)
    most_frequent_queries: List[Dict[str, Any]] = Field(default_factory=list)


class HealthAssessmentMetrics(BaseModel):
    user_id: str = Field(..., description="User ID")
    total_assessments: int = Field(0, description="Total health assessments")
    crop_types_assessed: List[str] = Field(default_factory=list)
    average_profit_margin: Optional[float] = Field(None)
    total_subsidies: float = Field(0.0)
    last_assessment: Optional[datetime] = Field(None)


class RecommendationMetrics(BaseModel):
    user_id: str = Field(..., description="User ID")
    loan_advice_count: int = Field(0, description="Loan advice requests")
    cost_cutting_count: int = Field(0, description="Cost cutting strategy requests")
    last_recommendation: Optional[datetime] = Field(None)
    recommendation_topics: List[str] = Field(default_factory=list)


class FarmerDashboardData(BaseModel):
    """Complete farmer data for admin dashboard"""
    activity: FarmerActivity
    expenses: Optional[ExpenseMetrics] = None
    forecasting: Optional[ForecastingMetrics] = None
    health: Optional[HealthAssessmentMetrics] = None
    recommendations: Optional[RecommendationMetrics] = None
    engagement_score: float = Field(0.0, description="Overall engagement score (0-100)")
    risk_level: Optional[str] = Field(None, description="Risk assessment")
    needs_attention: bool = Field(False, description="Flag for farmers needing attention")


class DashboardFilters(BaseModel):
    """Filters for dashboard queries"""
    time_filter: TimeFilter = Field(TimeFilter.all)
    service_filter: ServiceFilter = Field(ServiceFilter.all)
    region: Optional[str] = Field(None)
    is_active: Optional[bool] = Field(None)
    min_engagement_score: Optional[float] = Field(None)
    max_engagement_score: Optional[float] = Field(None)
    needs_attention: Optional[bool] = Field(None)
    page: int = Field(1, ge=1)
    page_size: int = Field(20, ge=1, le=100)
    sort_by: str = Field("last_activity", description="Field to sort by")
    sort_order: str = Field("desc", description="asc or desc")


class DashboardSummary(BaseModel):
    """Overall system summary for admin dashboard"""
    total_farmers: int = Field(0)
    active_farmers: int = Field(0)
    inactive_farmers: int = Field(0)
    farmers_needing_attention: int = Field(0)
    
    # Service usage metrics
    auth_usage: Dict[str, Any] = Field(default_factory=dict)
    expense_tracking_usage: Dict[str, Any] = Field(default_factory=dict)
    forecasting_usage: Dict[str, Any] = Field(default_factory=dict)
    health_assessment_usage: Dict[str, Any] = Field(default_factory=dict)
    recommendation_usage: Dict[str, Any] = Field(default_factory=dict)
    
    # Financial overview
    total_system_revenue: float = Field(0.0)
    total_system_expenses: float = Field(0.0)
    total_system_profit: float = Field(0.0)
    
    # Trends
    daily_active_users: List[Dict[str, Any]] = Field(default_factory=list)
    service_trends: Dict[str, List[Dict[str, Any]]] = Field(default_factory=dict)
    regional_distribution: Dict[str, int] = Field(default_factory=dict)
    
    # Time period
    time_filter: TimeFilter = Field(TimeFilter.all)
    generated_at: datetime = Field(default_factory=datetime.utcnow)


class AdminUser(BaseModel):
    """Admin user model"""
    id: str = Field(..., alias="_id")
    phone_number: str = Field(...)
    name: str = Field(...)
    is_admin: bool = Field(True)
    is_super_admin: bool = Field(False)
    permissions: List[str] = Field(default_factory=list)
    created_at: datetime = Field(...)
    last_login: Optional[datetime] = Field(None)


class ActivityLog(BaseModel):
    """Activity logging for audit trail"""
    user_id: str = Field(...)
    action: str = Field(...)
    service: str = Field(...)
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    details: Optional[Dict[str, Any]] = Field(None)
    ip_address: Optional[str] = Field(None)
    user_agent: Optional[str] = Field(None) 