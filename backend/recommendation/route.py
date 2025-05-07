import os
from fastapi import APIRouter, HTTPException

from .model import RecommendationInput, RecommendationOutput
from .service import make_prediction
router = APIRouter(
    tags=["recommendations"]
)

@router.post("/recommend", response_model=RecommendationOutput)
async def predict_recommendation(input_data: RecommendationInput):
    """Get crop recommendation based on farm parameters"""
    data = input_data.farm_input
    language = input_data.language if input_data.language else "en"
    if language not in ["en", "am", "om", "ti"]:
        raise HTTPException(
            status_code=400,
            detail="Language not supported. Supported languages are: en, am, om, ti"
        )
    
    try:
        serilized_data = data.model_dump()
        result = make_prediction(serilized_data, language)
        return {"success": True, "data": result}
    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )