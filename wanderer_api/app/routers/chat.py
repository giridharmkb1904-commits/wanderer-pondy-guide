import json
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect
from redis.asyncio import Redis
from app.schemas.chat import ChatMessageRequest, ChatMessageResponse
from app.services.chat_service import (
    get_or_create_session, save_message, get_echo_response,
)
from app.redis_client import get_redis
from app.middleware.auth_middleware import get_current_user_id

router = APIRouter(prefix="/api/v1/chat", tags=["chat"])


@router.post("/message", response_model=ChatMessageResponse)
async def send_message(
    request: ChatMessageRequest,
    user_id: str = Depends(get_current_user_id),
    redis: Redis = Depends(get_redis),
):
    session_id = await get_or_create_session(redis, user_id, request.session_id)
    await save_message(redis, session_id, "user", request.message)
    response_text = await get_echo_response(request.message)
    await save_message(redis, session_id, "assistant", response_text)

    return ChatMessageResponse(
        response=response_text,
        session_id=session_id,
        timestamp=datetime.now(timezone.utc),
    )


@router.websocket("/ws/{session_id}")
async def chat_websocket(websocket: WebSocket, session_id: str):
    await websocket.accept()
    redis = await get_redis()

    try:
        while True:
            data = await websocket.receive_text()
            msg = json.loads(data)

            if msg.get("type") == "text":
                content = msg.get("content", "")
                await save_message(redis, session_id, "user", content)
                response = await get_echo_response(content)
                await save_message(redis, session_id, "assistant", response)
                await websocket.send_json({
                    "type": "text",
                    "content": response,
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                })
            elif msg.get("type") == "ping":
                await websocket.send_json({"type": "pong"})

    except WebSocketDisconnect:
        pass
