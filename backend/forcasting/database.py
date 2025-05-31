from datetime import datetime
from bson import ObjectId
from auth.database import db  

prediction_collection = db.crop_forecasting_predictions

def save_prediction_result(user_id, input_data: dict, prediction_result: dict):
    record = {
        "user_id": ObjectId(user_id),
        "input": input_data,
        "output": prediction_result,
        "created_at": datetime.utcnow()
    }
    return prediction_collection.insert_one(record)
