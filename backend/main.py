from fastapi import FastAPI
from forcasting.routes import router as predict_router
from health_assessment.route import router as health_router

app = FastAPI()

app.include_router(predict_router)
app.include_router(health_router)

@app.get("/")
def read_root():
    return {"message": "Welcome to the EthioBizBoost Prediction Service!"}