from pydantic import BaseModel
from typing import Optional


class CropData(BaseModel):
    cropType: Optional[str] = None
    governmentSubsidy: float = 0
    salePricePerQuintal: float = 0
    totalCost: float = 0
    quantitySold: float = 0


class AssessmentResult(CropData):
    financialStability: float
    cashFlow: float
