from fastapi import APIRouter, Query, HTTPException
from typing import Optional
from .model import Expense
from .service import (
    add_expense,
    get_expenses,
    update_expense,
    delete_expense,
    get_assessments
)

router = APIRouter(prefix="/expense-tracking", tags=["Expense Tracking"])

#! --- Expenses Routes ---
@router.post("/expenses")
def create_expense(expense: Expense):
    expense_id = add_expense(expense)
    return {"message": "Expense added successfully", "id": expense_id}

@router.get("/expenses")
def list_expenses(
    year: Optional[str] = Query(None),
    month: Optional[str] = Query(None)
):
    filter_by = {}
    if year and month:
        filter_by["date"] = {"$regex": f"^{year}-{month}"}
    elif year:
        filter_by["date"] = {"$regex": f"^{year}"}
    elif month: 
        filter_by["date"] = {"$regex": f"-{month}-"}
    expenses = get_expenses(filter_by)
    return expenses

@router.put("/expenses/{expense_id}")
def edit_expense(expense_id: str, expense_update: Expense):
    updated = update_expense(expense_id, expense_update.model_dump())
    if not updated:
        raise HTTPException(status_code=404, detail="Expense not found")
    return {"message": "Expense updated successfully"}

@router.delete("/expenses/{expense_id}")
def remove_expense(expense_id: str):
    deleted = delete_expense(expense_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Expense not found")
    return {"message": "Expense deleted successfully"}

#! --- Assessments Routes ---
@router.get("/assessments")
def list_assessments(
    year: Optional[str] = Query(None),
    month: Optional[str] = Query(None)
):
    filter_by = {}
    if year and month:
        filter_by["date"] = {"$regex": f"^{year}-{month.zfill(2)}"}
    elif year:
        filter_by["date"] = {"$regex": f"^{year}"}
    
    assessments = get_assessments(filter_by)
    return assessments
