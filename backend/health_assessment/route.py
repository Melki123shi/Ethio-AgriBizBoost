from fastapi import APIRouter
from .model import CropData
from .service import calculateFinancials

router = APIRouter()

@router.post("/health_assessment")
def calculateHealthAssessment(data: CropData):
    return calculateFinancials(data)
