from fastapi import APIRouter, Depends
from .model import CropData
from .service import makeRecommendations
from .database import save_loan_recommendation
from auth.dependencies import get_current_active_user

router = APIRouter()

@router.post("/loan_advice")
def makeRecommendation(
    data: CropData,
    current_user: dict = Depends(get_current_active_user)
):
    user_id = current_user["_id"]
    result = makeRecommendations(data)
    save_loan_recommendation(user_id, data.dict(), result)
    return result
