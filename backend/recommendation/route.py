from fastapi import APIRouter
from .model import AssessmentResult
from .service import make_recommendations

router = APIRouter()

@router.post("/recommendation")
def make_recommendation(data: AssessmentResult):
    return make_recommendations(data)
