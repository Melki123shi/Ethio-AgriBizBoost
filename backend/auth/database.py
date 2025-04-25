import os
from pymongo import MongoClient
from datetime import datetime, timedelta
from bson import ObjectId
import config

# MongoDB client
client = MongoClient(config.MONGO_URI)
db = client[config.DB_NAME]

# Collections
users_collection = db.users
refresh_tokens_collection = db.refresh_tokens

def create_user(user_data):
    user_data["created_at"] = datetime.utcnow()
    result = users_collection.insert_one(user_data)
    return str(result.inserted_id)

def get_user_by_phone(phone_number):
    return users_collection.find_one({"phone_number": phone_number})

def get_user_by_id(user_id):
    return users_collection.find_one({"_id": ObjectId(user_id)})

def update_user(user_id, update_data):
    update_data["updated_at"] = datetime.utcnow()
    return users_collection.update_one(
        {"_id": ObjectId(user_id)}, 
        {"$set": update_data}
    )

# Refresh token operations
def store_refresh_token(user_id, refresh_token, expires_in_days=None):
    """Store a new refresh token in the database"""
    if expires_in_days is None:
        expires_in_days = config.REFRESH_TOKEN_EXPIRE_DAYS
        
    token_data = {
        "user_id": user_id,
        "refresh_token": refresh_token,
        "created_at": datetime.utcnow(),
        "expires_at": datetime.utcnow() + timedelta(days=expires_in_days),
        "is_revoked": False
    }
    result = refresh_tokens_collection.insert_one(token_data)
    return str(result.inserted_id)

def get_refresh_token(refresh_token):
    """Get a refresh token from the database"""
    return refresh_tokens_collection.find_one({"refresh_token": refresh_token, "is_revoked": False})

def is_token_valid(refresh_token):
    """Check if a refresh token is valid"""
    token = get_refresh_token(refresh_token)
    if not token:
        return False
    
    # Check if token is expired
    if token["expires_at"] < datetime.utcnow():
        revoke_refresh_token(refresh_token)
        return False
    
    return True

def revoke_refresh_token(refresh_token):
    """Revoke a refresh token"""
    refresh_tokens_collection.update_one(
        {"refresh_token": refresh_token},
        {"$set": {"is_revoked": True}}
    )

def revoke_all_user_tokens(user_id):
    """Revoke all refresh tokens for a user"""
    refresh_tokens_collection.update_many(
        {"user_id": user_id},
        {"$set": {"is_revoked": True}}
    )

def cleanup_expired_tokens():
    """Remove expired tokens from the database"""
    return refresh_tokens_collection.delete_many({
        "expires_at": {"$lt": datetime.utcnow()}
    }) 