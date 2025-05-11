from fastapi import APIRouter
from forcasting.model import PredictionInput
from forcasting.services import make_predictions

router = APIRouter()

@router.post("/predict", response_model=dict)
async def predict(data: PredictionInput):
    try:
        serilized_data = data.model_dump()
        result = make_predictions(serilized_data)
        return {"success": True, "data": result}
    except Exception as e:
        return {"success": False, "error": str(e)}