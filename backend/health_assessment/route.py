from fastapi import APIRouter
from .model import CropData
from .service import calculate_financials

router = APIRouter()

@router.post("/health_assessment")
def calculate_health_assessment(data: CropData):
    return calculate_financials(data)
