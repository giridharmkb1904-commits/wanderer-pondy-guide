"""Wanderer AI Orchestrator — manages conversation with tool use loop."""
import json
from sqlalchemy.ext.asyncio import AsyncSession
from app.ai.bedrock_client import (
    invoke_converse, build_system_prompt,
    extract_text_response, extract_tool_calls, get_usage_info,
)
from app.ai.tools.definitions import get_tools_for_tier, get_all_tools
from app.ai.tools.executors import execute_tool
from app.config import get_settings

settings = get_settings()

# Model routing per tier
TIER_MODELS = {
    "explorer": "amazon.nova-lite-v1:0",          # Cheapest for text-only tier
    "guide": "amazon.nova-pro-v1:0",              # Mid-tier
    "concierge": settings.bedrock_model_id,        # Claude Sonnet — premium
}

# Fallback for dev/testing when Bedrock isn't configured
FALLBACK_MODE = not settings.aws_region or settings.bedrock_model_id == ""


async def chat(
    user_message: str,
    conversation_history: list[dict],
    user_context: dict,
    tier: str = "concierge",
    db: AsyncSession | None = None,
    user_id: str | None = None,
) -> dict:
    """Main conversation function with tool use loop.

    Returns:
        {
            "response": str,           # AI text response
            "messages": list[dict],     # Updated conversation history
            "tool_calls_made": list,    # Tools that were called
            "usage": dict,             # Token usage info
        }
    """
    if FALLBACK_MODE:
        return await _fallback_chat(user_message, conversation_history)

    model_id = TIER_MODELS.get(tier, settings.bedrock_model_id)

    # Try Bedrock, fall back gracefully on any connection/config error
    try:
        return await _bedrock_chat(
            user_message, conversation_history, user_context,
            model_id, tier, db, user_id,
        )
    except Exception:
        return await _fallback_chat(user_message, conversation_history)


async def _bedrock_chat(
    user_message: str,
    conversation_history: list[dict],
    user_context: dict,
    model_id: str,
    tier: str,
    db: AsyncSession | None,
    user_id: str | None,
) -> dict:
    """Bedrock-powered conversation with tool use loop."""
    system = build_system_prompt(user_context)
    tools = get_tools_for_tier(tier)

    # Add user message to history
    messages = conversation_history.copy()
    messages.append({
        "role": "user",
        "content": [{"text": user_message}],
    })

    all_tool_calls = []
    total_usage = {"input_tokens": 0, "output_tokens": 0, "cache_read": 0, "cache_write": 0}
    max_tool_rounds = 5  # Safety limit

    for _ in range(max_tool_rounds):
        response = invoke_converse(
            model_id=model_id,
            system=system,
            messages=messages,
            tools=tools,
        )

        # Track usage
        usage = get_usage_info(response)
        for k in total_usage:
            total_usage[k] += usage.get(k, 0)

        output_message = response["output"]["message"]
        messages.append(output_message)
        stop_reason = response.get("stopReason", "end_turn")

        if stop_reason != "tool_use":
            # Final response — extract text
            text = extract_text_response(response)
            return {
                "response": text,
                "messages": messages,
                "tool_calls_made": all_tool_calls,
                "usage": total_usage,
            }

        # Execute tool calls
        tool_calls = extract_tool_calls(response)
        tool_results = []

        for tool in tool_calls:
            all_tool_calls.append({"name": tool["name"], "input": tool["input"]})

            result = await execute_tool(
                name=tool["name"],
                inputs=tool["input"],
                db=db,
                user_id=user_id,
            )

            tool_results.append({
                "toolResult": {
                    "toolUseId": tool["toolUseId"],
                    "content": [{"json": result}],
                }
            })

        # Feed tool results back
        messages.append({"role": "user", "content": tool_results})

    # Exhausted tool rounds — return what we have
    return {
        "response": "I'm having trouble completing that request. Could you try rephrasing?",
        "messages": messages,
        "tool_calls_made": all_tool_calls,
        "usage": total_usage,
    }


async def _fallback_chat(user_message: str, conversation_history: list[dict]) -> dict:
    """Fallback when Bedrock is not configured — smart echo with context."""
    msg_lower = user_message.lower()

    # Simple intent matching for dev/demo
    if any(word in msg_lower for word in ["restaurant", "eat", "food", "hungry", "dinner", "lunch"]):
        response = (
            "Great question! Here are my top picks in Pondicherry:\n\n"
            "🍽️ **Le Dupleix** — Elegant French-Tamil fusion in White Town (Premium)\n"
            "🍽️ **Villa Shanti** — Beautiful courtyard dining (Premium)\n"
            "🍽️ **Surguru** — Legendary South Indian thali, amazing filter coffee (Budget)\n\n"
            "Want me to book a table at any of these? Just tell me when and how many people!"
        )
    elif any(word in msg_lower for word in ["beach", "sea", "swim", "sunset"]):
        response = (
            "Pondicherry has beautiful beaches! Here are my favorites:\n\n"
            "🏖️ **Paradise Beach** — Secluded golden sand, reach by boat from Chunnambar\n"
            "🏖️ **Promenade Beach** — The iconic 1.5km seafront walk, best at sunrise\n"
            "🏖️ **Serenity Beach** — Perfect for surfing and quieter crowds\n\n"
            "The sunset today should be gorgeous — about 6:15 PM. Want me to plan a beach evening?"
        )
    elif any(word in msg_lower for word in ["temple", "pray", "spiritual"]):
        response = (
            "Pondicherry has beautiful temples!\n\n"
            "🛕 **Manakula Vinayagar Temple** — Ancient Ganesha temple with a temple elephant\n"
            "🛕 **Sri Aurobindo Ashram** — Peaceful meditation center in White Town\n"
            "🛕 **Auroville Matrimandir** — The iconic golden sphere (book in advance!)\n\n"
            "Would you like me to plan a spiritual morning?"
        )
    elif any(word in msg_lower for word in ["help", "emergency", "hospital", "police"]):
        response = (
            "🚨 Emergency contacts for Pondicherry:\n\n"
            "📞 **Emergency:** 112\n"
            "🏥 **JIPMER Hospital:** +91 413 227 2380\n"
            "👮 **Police:** 100\n"
            "🚑 **Ambulance:** 108\n"
            "📞 **Tourist Helpline:** 1363\n\n"
            "Are you safe? Let me know how I can help."
        )
    elif any(word in msg_lower for word in ["hello", "hi", "hey", "start"]):
        response = (
            "Welcome to Pondicherry! 🌊 I'm Wanderer, your AI tour guide.\n\n"
            "I know every street, restaurant, temple, and hidden gem in this beautiful city. "
            "Just tell me what you're in the mood for — food, beaches, history, adventure — "
            "and I'll make it happen.\n\n"
            "What would you like to explore first?"
        )
    elif any(word in msg_lower for word in ["plan", "itinerary", "schedule", "day"]):
        response = (
            "I'd love to plan your day! To build the perfect itinerary, tell me:\n\n"
            "1. How many days are you staying?\n"
            "2. What interests you most? (food, history, beaches, adventure, shopping)\n"
            "3. Budget preference? (budget, mid-range, premium)\n\n"
            "I'll create a custom day-by-day plan with timings, travel routes, and meal stops!"
        )
    else:
        response = (
            f"I heard you! You said: \"{user_message}\"\n\n"
            "I'm running in demo mode right now — the full AI brain (Claude Sonnet) "
            "will be connected when AWS Bedrock credentials are configured.\n\n"
            "Try asking about restaurants, beaches, temples, or say 'plan my day'!"
        )

    messages = conversation_history.copy()
    messages.append({"role": "user", "content": [{"text": user_message}]})
    messages.append({"role": "assistant", "content": [{"text": response}]})

    return {
        "response": response,
        "messages": messages,
        "tool_calls_made": [],
        "usage": {"input_tokens": 0, "output_tokens": 0, "cache_read": 0, "cache_write": 0},
    }
