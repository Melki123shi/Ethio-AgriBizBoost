from datetime import datetime
from bson import ObjectId
from auth.database import db  # shared Mongo client

loan_advice_collection = db.loan_advice_recommendations

def save_loan_recommendation(user_id, crop_input: dict, recommendation_result: dict):
    record = {
        "user_id": ObjectId(user_id),
        "input": crop_input,
        "output": recommendation_result,
        "created_at": datetime.utcnow()
    }
    return loan_advice_collection.insert_one(record)
