from fastapi import APIRouter, Depends
from .model import CropData
from .service import calculateFinancials
from .database import save_crop_financial
from auth.dependencies import get_current_active_user

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

