# service.py

from .model import Expense
from typing import List
from .database import expenses_collection, assessments_collection
from bson import ObjectId

# --- Expenses ---
def add_expense(expense_data: Expense) -> str:
    expense_dict = expense_data.model_dump()
    result = expenses_collection.insert_one(expense_dict)
    return str(result.inserted_id)

def get_expenses(filter_by: dict = None) -> List[dict]:
    filter_query = filter_by or {}
    expenses = []
    for expense in expenses_collection.find(filter_query):
        expense["_id"] = str(expense["_id"])  # Make _id JSON serializable
        expenses.append(expense)
    return expenses

def update_expense(expense_id: str, updated_data: dict) -> bool:
    result = expenses_collection.update_one(
        {"_id": ObjectId(expense_id)},
        {"$set": updated_data}
    )
    return result.modified_count > 0

def delete_expense(expense_id: str) -> bool:
    result = expenses_collection.delete_one({"_id": ObjectId(expense_id)})
    return result.deleted_count > 0

# --- Assessments ---
def get_assessments(filter_by: dict = None) -> List[dict]:
    filter_query = filter_by or {}
    assessments = []
    for assessment in assessments_collection.find(filter_query):
        assessment["_id"] = str(assessment["_id"])
        assessments.append(assessment)
    return assessments
