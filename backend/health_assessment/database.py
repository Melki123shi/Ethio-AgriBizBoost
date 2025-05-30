from datetime import datetime
from bson import ObjectId
from auth.database import db

financials_collection = db.financial_assessments

def save_crop_financial(user_id, crop_input: dict, result: dict):
    record = {
        "user_id": ObjectId(user_id),
        "input": crop_input,
        "output": result,
        "created_at": datetime.utcnow()
    }
    return financials_collection.insert_one(record)
