from datetime import datetime
from typing import Optional
from pydantic import BaseModel, field_validator
from .validation import validate_cropTypes, validate_positive, validate_non_negative

class Expense(BaseModel):
    date: datetime
    cropType: str
    quantitySold: float
    totalCost: float
    user_id: str

    @field_validator('cropType')
    def validate_cropTypes_name(cls, v):
        return validate_cropTypes(v)

    @field_validator('amount', 'totalCost')
    def validate_positive_value(cls, v, info):
        return validate_positive(v, info.field_name)