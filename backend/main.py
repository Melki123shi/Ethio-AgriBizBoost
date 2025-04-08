from fastapi import FastAPI
from health_assessment.route import router as health_router
from recommendation.route import router as recommendation_router
import uvicorn

app = FastAPI()

app.include_router(health_router)
app.include_router(recommendation_router)

@app.get("/")
def read_root():
    return {"message": "Welcome to the EthioBizBoost Prediction Service!"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
    