from pydantic import BaseModel

class PredictionInput(BaseModel):
    region: list[str]
    zone: list[str]
    woreda: list[str]
    marketname: list[str]
    cropname: list[str]
    varietyname: list[str]
    season: list[str]

