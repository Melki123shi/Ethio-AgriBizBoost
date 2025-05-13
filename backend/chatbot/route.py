from fastapi import APIRouter, Depends
from pydantic import BaseModel
from .service import ChatService

router = APIRouter()

class ChatRequest(BaseModel):
    message: str
    language: str = "am"

@router.post("/chatbot")
async def chat_endpoint(
    req: ChatRequest,
    svc: ChatService = Depends(ChatService) 
):
    return await svc.generate(req.message, req.language)
