"""Chat router — REST + WebSocket endpoints powered by AI orchestrator."""
import json
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect
from sqlalchemy.ext.asyncio import AsyncSession
from redis.asyncio import Redis
from app.schemas.chat import ChatMessageRequest, ChatMessageResponse
from app.services.chat_service import (
    get_or_create_session, save_message, get_ai_response,
)
from app.database import get_db
from app.redis_client import get_redis
from app.middleware.auth_middleware import get_current_user_id

router = APIRouter(prefix="/api/v1/chat", tags=["chat"])


@router.post("/message", response_model=ChatMessageResponse)
async def send_message(
    request: ChatMessageRequest,
    user_id: str = Depends(get_current_user_id),
    redis: Redis = Depends(get_redis),
    db: AsyncSession = Depends(get_db),
):
    session_id = await get_or_create_session(redis, user_id, request.session_id)

    # Save user message
    await save_message(redis, session_id, "user", request.message)

    # Get AI response
    result = await get_ai_response(
        message=request.message,
        session_id=session_id,
        redis=redis,
        user_context={},  # TODO: load from user profile
        tier="concierge",  # TODO: load from user subscription
        db=db,
        user_id=user_id,
    )

    # Save AI response
    await save_message(redis, session_id, "assistant", result["response"])

    return ChatMessageResponse(
        response=result["response"],
        session_id=session_id,
        timestamp=datetime.now(timezone.utc),
        cards=[],
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

                # Get AI response
                result = await get_ai_response(
                    message=content,
                    session_id=session_id,
                    redis=redis,
                    user_context={},
                    tier="concierge",
                )

                await save_message(redis, session_id, "assistant", result["response"])

                await websocket.send_json({
                    "type": "text",
                    "content": result["response"],
                    "tool_calls": result.get("tool_calls_made", []),
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                })

            elif msg.get("type") == "ping":
                await websocket.send_json({"type": "pong"})

    except WebSocketDisconnect:
        pass
