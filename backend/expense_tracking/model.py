from typing import Optional
from pydantic import BaseModel, field_validator
from .validation import validate_date_format, validate_goods, validate_positive, validate_non_negative

class Expense(BaseModel):
    date: str
    goods: str
    amount: float
    price_etb: float

    @field_validator('date')
    def validate_date(cls, v):
        return validate_date_format(v)

    @field_validator('goods')
    def validate_goods_name(cls, v):
        return validate_goods(v)

    @field_validator('amount', 'price_etb')
    def validate_positive_value(cls, v, info):
        return validate_positive(v, info.field_name)


class Assessment(BaseModel):
    date: str
    goods: str
    expenses: float
    profit: float
    financial_stability: Optional[str] = None
    cash_flow: Optional[str] = None

    @field_validator('date')
    def validate_date(cls, v):
        return validate_date_format(v)

    @field_validator('goods')
    def validate_goods_name(cls, v):
        return validate_goods(v)

    @field_validator('expenses', 'profit')
    def validate_non_negative_value(cls, v, info):
        return validate_non_negative(v, info.field_name)
