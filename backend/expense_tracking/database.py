from pymongo import MongoClient
import config

client = MongoClient(config.MONGO_URI)
db = client[config.DB_NAME]

# Collections
expenses_collection = db.expenses
assessments_collection = db.assessments
