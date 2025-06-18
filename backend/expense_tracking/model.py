from datetime import datetime
from pydantic import BaseModel, Field, field_validator
from .validation import validate_cropTypes, validate_positive

class Expense(BaseModel):
    date: datetime
    cropType: str
    quantitySold: float
    totalCost: float
    user_id: str

    @field_validator('cropType')
    def validate_crop_type(cls, v):
        return validate_cropTypes(v)

    @field_validator('quantitySold', 'totalCost')
    def validate_positive_fields(cls, v, info):
        return validate_positive(v, info.field_name)
