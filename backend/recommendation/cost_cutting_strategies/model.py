from pydantic import BaseModel
from typing import Optional

class FarmInput(BaseModel):
    """Input data model for farm parameters"""
    farm_size_hectares: float
    crop_type: str
    season: str
    fertilizer_expense_ETB: float
    labor_expense_ETB: float
    pesticide_expense_ETB: float
    equipment_expense_ETB: float
    transportation_expense_ETB: float
    seed_expense_ETB: float
    utility_expense_ETB: float

    class Config:
        schema_extra = {
            "example": {
    "farm_size_hectares": 2.5,
    "crop_type": "Teff",
    "season": "Belg",
    "fertilizer_expense_ETB": 2500,
    "labor_expense_ETB": 6000,
    "pesticide_expense_ETB": 1000,
    "equipment_expense_ETB": 5000,
    "transportation_expense_ETB": 1500,
    "seed_expense_ETB": 3000,
    "utility_expense_ETB": 500
}
        }

class RecommendationInput(BaseModel):
    farm_input: FarmInput
    language: Optional[str] = "en"
    class Config:
        schema_extra = {
            "example": {
                "farm_input": {
                    "farm_size_hectares": 2.5,
                    "crop_type": "Teff",
                    "season": "Belg",
                    "fertilizer_expense_ETB": 2500,
                    "labor_expense_ETB": 6000,
                    "pesticide_expense_ETB": 1000,
                    "equipment_expense_ETB": 5000,
                    "transportation_expense_ETB": 1500,
                    "seed_expense_ETB": 3000,
                    "utility_expense_ETB": 500
                },
                "language": "en"
            }
        }

class RecommendationData(BaseModel):
    recommendation: str

class RecommendationOutput(BaseModel):
    success: bool
    data: RecommendationData