from pydantic import BaseModel
from typing import Optional

class AssessmentResult(BaseModel):
    financial_stability: float
    cash_flow: float
    quantity_sold: Optional[float] = None 
    sale_price_per_quintal: Optional[float] = None
    crop_type: Optional[str] = None
    government_subsidy: Optional[float] = None
    total_cost: Optional[float] = None
   
