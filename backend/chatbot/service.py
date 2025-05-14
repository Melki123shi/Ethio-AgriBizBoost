import os
import time
from dotenv import load_dotenv
from deep_translator import GoogleTranslator
import google.generativeai as genai

load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

class ChatService:
    def __init__(self, model_name: str = "gemini-2.0-flash"):
        self.model = genai.GenerativeModel(model_name=model_name)

    def translate(self, text: str, src: str, tgt: str) -> str:
        return GoogleTranslator(source=src, target=tgt).translate(text)

    async def generate(self, user_message: str, lang_code: str = "am") -> dict:
        start = time.time()
        # translate user → English
        en_in = self.translate(user_message, lang_code, "en")
        prompt = (
            "You are a helpful and concise agricultural chatbot. "
            "Respond briefly, like Deepseek. Be friendly and avoid long intros. "
            "For አማርኛ and ትግርኛ answer like Deepseek. "
            "Only give detailed farming advice if the question needs it.\n\n"
            f"User: {en_in}\nAssistant:"
        )
        resp = self.model.generate_content(prompt)
        en_out = getattr(resp, "text", "").strip()
        # translate back → original
        translated = self.translate(en_out, "en", lang_code)
        return {
            "response": translated,
            "original_response": en_out,
            "elapsed_ms": int((time.time() - start) * 1000),
        }
