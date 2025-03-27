from pydantic import BaseModel

class CropData(BaseModel):
    crop_type: str
    government_subsidy: float
    sale_price_per_quintal: float
    total_cost: float
    quantity_sold: float
