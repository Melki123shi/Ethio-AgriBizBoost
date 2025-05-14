from fastapi import APIRouter
from .model import AssessmentResult
from .service import makeRecommendations

router = APIRouter()

@router.post("/loan_advice")
def makeRecommendation(data: AssessmentResult):
    return makeRecommendations(data)