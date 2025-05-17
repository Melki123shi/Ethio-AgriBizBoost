from fastapi import APIRouter
from .model import CropData
from .service import makeRecommendations

router = APIRouter()

@router.post("/loan_advice")
def makeRecommendation(data: CropData):
    return makeRecommendations(data)