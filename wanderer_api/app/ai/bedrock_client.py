"""AWS Bedrock client for Claude API with prompt caching and tool use."""
import boto3
import json
from typing import AsyncGenerator
from app.config import get_settings

settings = get_settings()


def get_bedrock_client():
    return boto3.client(
        "bedrock-runtime",
        region_name=settings.aws_region,
    )


def invoke_converse(
    model_id: str,
    system: list[dict],
    messages: list[dict],
    tools: list[dict] | None = None,
    max_tokens: int = 2048,
    temperature: float = 0.7,
) -> dict:
    """Synchronous Bedrock Converse call with tool use support."""
    client = get_bedrock_client()

    kwargs = {
        "modelId": model_id,
        "system": system,
        "messages": messages,
        "inferenceConfig": {"maxTokens": max_tokens, "temperature": temperature},
    }
    if tools:
        kwargs["toolConfig"] = {"tools": tools}

    response = client.converse(**kwargs)
    return response


def invoke_converse_stream(
    model_id: str,
    system: list[dict],
    messages: list[dict],
    tools: list[dict] | None = None,
    max_tokens: int = 2048,
    temperature: float = 0.7,
) -> dict:
    """Streaming Bedrock Converse call."""
    client = get_bedrock_client()

    kwargs = {
        "modelId": model_id,
        "system": system,
        "messages": messages,
        "inferenceConfig": {"maxTokens": max_tokens, "temperature": temperature},
    }
    if tools:
        kwargs["toolConfig"] = {"tools": tools}

    response = client.converse_stream(**kwargs)
    return response


def build_system_prompt(user_context: dict) -> list[dict]:
    """Build system prompt with user context and cache point."""
    base_prompt = """You are Wanderer, an expert AI tour guide for Pondicherry, India.

You are warm, knowledgeable, and speak like a trusted local friend. You know every street,
restaurant, temple, beach, and hidden gem in Pondicherry. You adapt your tone based on the traveler:
- Casual with backpackers
- Refined with luxury travelers
- Informative at heritage sites
- Practical with families

You can:
- Recommend restaurants, cafes, hotels, temples, beaches, and experiences
- Build and modify day-by-day itineraries
- Book restaurants and hotels (through tool calls)
- Navigate travelers with local transport knowledge
- Share deep history and cultural context
- Track budgets and suggest cost-optimized alternatives
- Handle emergencies (nearest hospital, police, embassy contacts)

When using tools, always explain what you're doing naturally:
"Let me find some great restaurants near you..." (then call search_places)
"I'll check availability and book that for you..." (then call make_booking)

Always be helpful, proactive, and culturally sensitive. If you don't know something, say so honestly.
Respond in the user's language — auto-detect from their message."""

    user_info = ""
    if user_context:
        if user_context.get("name"):
            user_info += f"\nTraveler: {user_context['name']}"
        if user_context.get("travel_style"):
            user_info += f"\nStyle: {user_context['travel_style']}"
        if user_context.get("dietary_preferences"):
            user_info += f"\nDietary: {', '.join(user_context['dietary_preferences'])}"
        if user_context.get("preferred_language"):
            user_info += f"\nPreferred language: {user_context['preferred_language']}"
        if user_context.get("location"):
            user_info += f"\nCurrent location: {user_context['location']}"

    full_prompt = base_prompt + user_info

    return [
        {"text": full_prompt},
        {"cachePoint": {"type": "default"}},  # Cache the system prompt
    ]


def extract_text_response(response: dict) -> str:
    """Extract text content from Bedrock Converse response."""
    output = response.get("output", {}).get("message", {})
    for block in output.get("content", []):
        if "text" in block:
            return block["text"]
    return ""


def extract_tool_calls(response: dict) -> list[dict]:
    """Extract tool use blocks from response."""
    output = response.get("output", {}).get("message", {})
    tool_calls = []
    for block in output.get("content", []):
        if "toolUse" in block:
            tool_calls.append(block["toolUse"])
    return tool_calls


def get_usage_info(response: dict) -> dict:
    """Extract token usage and cache info."""
    usage = response.get("usage", {})
    return {
        "input_tokens": usage.get("inputTokens", 0),
        "output_tokens": usage.get("outputTokens", 0),
        "cache_read": usage.get("cacheReadInputTokens", 0),
        "cache_write": usage.get("cacheWriteInputTokens", 0),
    }
