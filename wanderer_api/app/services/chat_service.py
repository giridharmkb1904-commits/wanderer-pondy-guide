"""Chat service — manages sessions and routes to AI orchestrator."""
import json
from datetime import datetime, timezone
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession
from app.ai.orchestrator import chat as ai_chat
import uuid

SESSION_TTL = 3600


async def get_or_create_session(redis: Redis, user_id: str, session_id: str | None) -> str:
    if session_id:
        exists = await redis.exists(f"chat:{session_id}")
        if exists:
            return session_id

    new_id = str(uuid.uuid4())
    session_data = {
        "user_id": user_id,
        "messages": [],
        "bedrock_messages": [],  # Bedrock-format conversation history
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    await redis.setex(f"chat:{new_id}", SESSION_TTL, json.dumps(session_data))
    return new_id


async def save_message(redis: Redis, session_id: str, role: str, content: str):
    key = f"chat:{session_id}"
    data = await redis.get(key)
    if data:
        session = json.loads(data)
    else:
        session = {"messages": [], "bedrock_messages": []}

    session["messages"].append({
        "role": role,
        "content": content,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    })
    await redis.setex(key, SESSION_TTL, json.dumps(session))


async def get_ai_response(
    message: str,
    session_id: str,
    redis: Redis,
    user_context: dict | None = None,
    tier: str = "concierge",
    db: AsyncSession | None = None,
    user_id: str | None = None,
) -> dict:
    """Get AI response through the orchestrator."""
    # Load conversation history from Redis
    key = f"chat:{session_id}"
    data = await redis.get(key)
    if data:
        session = json.loads(data)
        bedrock_messages = session.get("bedrock_messages", [])
    else:
        bedrock_messages = []

    # Call the AI orchestrator
    result = await ai_chat(
        user_message=message,
        conversation_history=bedrock_messages,
        user_context=user_context or {},
        tier=tier,
        db=db,
        user_id=user_id,
    )

    # Save updated Bedrock conversation history back to Redis
    if data:
        session = json.loads(data)
    else:
        session = {"messages": [], "bedrock_messages": []}

    session["bedrock_messages"] = result["messages"]
    await redis.setex(key, SESSION_TTL, json.dumps(session, default=str))

    return result


async def get_session_messages(redis: Redis, session_id: str) -> list:
    data = await redis.get(f"chat:{session_id}")
    if data:
        return json.loads(data).get("messages", [])
    return []
