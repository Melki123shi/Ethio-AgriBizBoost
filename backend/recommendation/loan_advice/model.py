from pydantic import BaseModel
from typing import Optional

class AssessmentResult(BaseModel):
    financialStability: float
    cashFlow: float
    quantitySold: Optional[float] = None 
    salePricePerQuintal: Optional[float] = None
    cropType: Optional[str] = None
    governmentSubsidy: Optional[float] = None
    totalCost: Optional[float] = None
   