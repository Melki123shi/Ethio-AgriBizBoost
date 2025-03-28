from fastapi import FastAPI
from forcasting.routes import router as predict_router
from health_assessment.route import router as health_router
from recommendation.route import router as recommendation_router

app = FastAPI()

app.include_router(predict_router)
app.include_router(health_router)
app.include_router(recommendation_router)

@app.get("/")
def read_root():
    return {"message": "Welcome to the EthioBizBoost Prediction Service!"}