from fastapi import APIRouter, Depends
from forcasting.model import PredictionInput
from forcasting.services import make_predictions
from forcasting.database import save_prediction_result
from auth.dependencies import get_current_active_user

router = APIRouter()

@router.post("/predict", response_model=dict)
async def predict(
    data: PredictionInput,
    current_user: dict = Depends(get_current_active_user)
):
    try:
        serialized_data = data.model_dump()
        result = make_predictions(serialized_data)
        
        user_id = current_user["_id"]
        save_prediction_result(user_id, serialized_data, result)

        return {"success": True, "data": result}
    except Exception as e:
        return {"success": False, "error": str(e)}