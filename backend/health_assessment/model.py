from pydantic import BaseModel

class CropData(BaseModel):
    cropType: str
    governmentSubsidy: float
    salePricePerQuintal: float
    totalCost: float
    quantitySold: float
