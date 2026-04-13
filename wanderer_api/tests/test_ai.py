"""Tests for AI orchestrator — runs in fallback mode (no Bedrock needed)."""
import pytest
from app.ai.orchestrator import chat as ai_chat, _fallback_chat
from app.ai.tools.definitions import get_all_tools, get_tools_for_tier
from app.ai.tools.executors import execute_tool
from app.ai.bedrock_client import build_system_prompt


@pytest.mark.asyncio
async def test_fallback_chat_greeting():
    result = await _fallback_chat("Hello!", [])
    assert "Welcome" in result["response"] or "Wanderer" in result["response"]
    assert len(result["messages"]) == 2  # user + assistant


@pytest.mark.asyncio
async def test_fallback_chat_restaurant():
    result = await _fallback_chat("Where should I eat dinner?", [])
    assert "restaurant" in result["response"].lower() or "dupleix" in result["response"].lower()


@pytest.mark.asyncio
async def test_fallback_chat_beach():
    result = await _fallback_chat("Tell me about beaches", [])
    assert "beach" in result["response"].lower()


@pytest.mark.asyncio
async def test_fallback_chat_emergency():
    result = await _fallback_chat("I need help! Emergency!", [])
    assert "112" in result["response"] or "emergency" in result["response"].lower()


@pytest.mark.asyncio
async def test_orchestrator_uses_fallback():
    """Orchestrator should use fallback when Bedrock is not configured."""
    result = await ai_chat(
        user_message="Hello!",
        conversation_history=[],
        user_context={},
        tier="concierge",
    )
    assert result["response"]
    assert isinstance(result["messages"], list)
    assert isinstance(result["tool_calls_made"], list)


@pytest.mark.asyncio
async def test_tool_search_places():
    result = await execute_tool("search_places", {"query": "seafood", "category": "restaurant"})
    assert "places" in result
    assert len(result["places"]) > 0


@pytest.mark.asyncio
async def test_tool_get_weather():
    result = await execute_tool("get_weather", {"days": 1})
    assert "current" in result
    assert result["location"] == "Pondicherry"


@pytest.mark.asyncio
async def test_tool_emergency_info():
    result = await execute_tool("get_emergency_info", {"type": "all"})
    assert "police" in result
    assert "hospital" in result


@pytest.mark.asyncio
async def test_tool_compare_hotels():
    result = await execute_tool("compare_hotels", {
        "query": "Le Dupleix",
        "check_in": "2026-04-20",
        "check_out": "2026-04-22",
        "guests": 2,
    })
    assert "cheapest" in result
    assert result["cheapest"]["platform"] == "Goibibo"


@pytest.mark.asyncio
async def test_tool_budget_tracking():
    result = await execute_tool("track_budget", {"action": "get_status"})
    assert "remaining" in result


def test_tool_definitions_all():
    tools = get_all_tools()
    assert len(tools) >= 7  # 7 tools + cache point


def test_tool_definitions_tier_explorer():
    tools = get_tools_for_tier("explorer")
    tool_names = [t["toolSpec"]["name"] for t in tools if "toolSpec" in t]
    assert "search_places" in tool_names
    assert "make_booking" not in tool_names  # Not available in explorer


def test_tool_definitions_tier_concierge():
    tools = get_tools_for_tier("concierge")
    tool_names = [t["toolSpec"]["name"] for t in tools if "toolSpec" in t]
    assert "search_places" in tool_names
    assert "make_booking" in tool_names
    assert "compare_hotels" in tool_names


def test_system_prompt_building():
    system = build_system_prompt({"name": "John", "travel_style": "luxury"})
    assert len(system) == 2  # prompt + cache point
    assert "Wanderer" in system[0]["text"]
    assert "John" in system[0]["text"]
    assert "luxury" in system[0]["text"]


def test_system_prompt_empty_context():
    system = build_system_prompt({})
    assert "Wanderer" in system[0]["text"]
