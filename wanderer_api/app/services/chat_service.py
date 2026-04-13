import json
from datetime import datetime, timezone
from redis.asyncio import Redis
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
        session = {"messages": []}

    session["messages"].append({
        "role": role,
        "content": content,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    })
    await redis.setex(key, SESSION_TTL, json.dumps(session))


async def get_echo_response(message: str) -> str:
    """Placeholder — replaced by Claude in Phase 2."""
    return f"[Echo] You said: {message}. AI guide coming soon!"


async def get_session_messages(redis: Redis, session_id: str) -> list:
    data = await redis.get(f"chat:{session_id}")
    if data:
        return json.loads(data).get("messages", [])
    return []
