from fastapi import APIRouter, Depends
from forcasting.model import PredictionInput
from forcasting.services import make_predictions
from forcasting.database import save_prediction_result
from auth.dependencies import get_current_active_user
from security.rate_limiter import limiter

router = APIRouter(
#     prefix="/forcasting",
#     tags=["Forecasting"],
#     responses={
#         403: {"description": "Forbidden - Authentication required"},
#         404: {"description": "Not found"}
#     }
)

@router.post("/predict", response_model=dict)
# @limiter.limit("30/minute")
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