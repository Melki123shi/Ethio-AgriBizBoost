from fastapi import APIRouter, Query, HTTPException, Depends
from typing import Optional
from .model import Expense
from .service import (
    add_expense,
    get_expenses,
    update_expense,
    delete_expense,
)
from auth.dependencies import get_current_active_user  

router = APIRouter(
    prefix="/expense-tracking",
    tags=["Expense Tracking"],
)

@router.post("/expenses")
def create_expense(expense: Expense, current_user: str = Depends(get_current_active_user)):
    expense.user_id = current_user  
    expense_id = add_expense(expense)
    return {"message": "Expense added successfully", "id": expense_id}

@router.get("/expenses")
def list_expenses(
    current_user: str = Depends(get_current_active_user) 
):
    filter_by = {"user_id": current_user}
    expenses = get_expenses(filter_by)
    return expenses

@router.put("/expenses/{expense_id}")
def edit_expense(expense_id: str, expense_update: Expense, current_user: str = Depends(get_current_active_user)):
    expense_update.user_id = current_user 
    updated = update_expense(expense_id, expense_update.model_dump())
    if not updated:
        raise HTTPException(status_code=404, detail="Expense not found")
    return {"message": "Expense updated successfully"}

@router.delete("/expenses/{expense_id}")
def remove_expense(expense_id: str, current_user: str = Depends(get_current_active_user)):
    deleted = delete_expense(expense_id, current_user)
    if not deleted:
        raise HTTPException(status_code=404, detail="Expense not found")
    return {"message": "Expense deleted successfully"}
