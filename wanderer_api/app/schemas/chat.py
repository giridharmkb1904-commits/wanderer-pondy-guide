from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class ChatMessageRequest(BaseModel):
    message: str
    session_id: Optional[str] = None


class ChatMessageResponse(BaseModel):
    response: str
    session_id: str
    timestamp: datetime
    cards: list[dict] = []


class WebSocketMessage(BaseModel):
    type: str
    content: Optional[str] = None
    audio_base64: Optional[str] = None
    session_id: Optional[str] = None
