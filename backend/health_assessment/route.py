from fastapi import APIRouter, Depends
from bson import ObjectId
from auth.dependencies import get_current_active_user
from .model import CropData
from .service import calculateFinancials
from .database import save_crop_financial
from database import financials_collection

router = APIRouter()

@router.post("/health_assessment")
def calculateHealthAssessment(
    data: CropData,
    current_user: dict = Depends(get_current_active_user)
):
    user_id = current_user["_id"]
    result = calculateFinancials(data)
    save_crop_financial(user_id, data.dict(), result)
    return result


@router.get("/assessment-result-recents")
def get_recent_assessment_averages(current_user: dict = Depends(get_current_active_user)):
    user_id = current_user["_id"]

    recent_records = list(
        financials_collection.find(
            {"user_id": ObjectId(user_id)},
            {"output.financialStability": 1, "output.cashFlow": 1}
        ).sort("created_at", -1).limit(5)
    )

    if not recent_records:
        return {
            "message": "No financial assessments found for the user.",
            "averageFinancialStability": 0,
            "averageCashFlow": 0
        }

    total_stability = 0
    total_cash_flow = 0
    count = 0

    for record in recent_records:
        output = record.get("output", {})
        total_stability += output.get("financialStability", 0)
        total_cash_flow += output.get("cashFlow", 0)
        count += 1

    return {
        "averageFinancialStability": round(total_stability / count, 2) if count else 0,
        "averageCashFlow": round(total_cash_flow / count, 2) if count else 0,
        "recordsConsidered": count
    }