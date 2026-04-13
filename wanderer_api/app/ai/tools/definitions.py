"""Tool definitions for Claude's function calling via Bedrock Converse API."""


SEARCH_PLACES_TOOL = {
    "toolSpec": {
        "name": "search_places",
        "description": "Search for restaurants, temples, beaches, cafes, hotels, or attractions in Pondicherry. Returns a list of matching places with details.",
        "inputSchema": {
            "json": {
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "Natural language search query, e.g. 'best seafood restaurant' or 'quiet beach for sunset'",
                    },
                    "category": {
                        "type": "string",
                        "enum": [
                            "restaurant", "temple", "beach", "museum", "cafe", "hotel",
                            "ashram", "market", "nightlife", "shopping", "experience",
                            "transport", "photo_spot", "hidden_gem",
                        ],
                        "description": "Category to filter by",
                    },
                    "price_range": {
                        "type": "string",
                        "enum": ["free", "budget", "mid", "premium"],
                        "description": "Optional price filter",
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Max results to return (default 5)",
                        "default": 5,
                    },
                },
                "required": ["query", "category"],
            }
        },
    }
}

MAKE_BOOKING_TOOL = {
    "toolSpec": {
        "name": "make_booking",
        "description": "Make a restaurant or experience booking. The system will handle the actual booking via WhatsApp or phone call.",
        "inputSchema": {
            "json": {
                "type": "object",
                "properties": {
                    "place_id": {"type": "string", "description": "UUID of the place to book"},
                    "date": {"type": "string", "description": "Booking date in YYYY-MM-DD format"},
                    "time": {"type": "string", "description": "Booking time in HH:MM format"},
                    "party_size": {"type": "integer", "description": "Number of guests"},
                    "special_requests": {"type": "string", "description": "Any special requests or dietary needs"},
                },
                "required": ["place_id", "date", "time", "party_size"],
            }
        },
    }
}

GET_WEATHER_TOOL = {
    "toolSpec": {
        "name": "get_weather",
        "description": "Get current weather and forecast for Pondicherry. Useful for planning outdoor activities.",
        "inputSchema": {
            "json": {
                "type": "object",
                "properties": {
                    "days": {
                        "type": "integer",
                        "description": "Number of forecast days (1-7)",
                        "default": 1,
                    },
                },
                "required": [],
            }
        },
    }
}

CREATE_ITINERARY_TOOL = {
    "toolSpec": {
        "name": "create_itinerary",
        "description": "Create or modify a day-by-day trip itinerary based on the traveler's preferences, dates, and interests.",
        "inputSchema": {
            "json": {
                "type": "object",
                "properties": {
                    "days": {"type": "integer", "description": "Number of days for the itinerary"},
                    "interests": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "List of interests, e.g. ['temples', 'seafood', 'beaches', 'history']",
                    },
                    "budget": {
                        "type": "string",
                        "enum": ["budget", "mid", "premium"],
                        "description": "Budget level",
                    },
                    "travel_style": {
                        "type": "string",
                        "enum": ["relaxed", "packed", "balanced"],
                        "description": "How packed should each day be",
                    },
                },
                "required": ["days", "interests"],
            }
        },
    }
}

GET_EMERGENCY_INFO_TOOL = {
    "toolSpec": {
        "name": "get_emergency_info",
        "description": "Get emergency contacts, nearest hospitals, police stations, or embassy information.",
        "inputSchema": {
            "json": {
                "type": "object",
                "properties": {
                    "type": {
                        "type": "string",
                        "enum": ["hospital", "police", "embassy", "all"],
                        "description": "Type of emergency info needed",
                    },
                    "nationality": {
                        "type": "string",
                        "description": "Traveler's nationality for embassy lookup",
                    },
                },
                "required": ["type"],
            }
        },
    }
}

TRACK_BUDGET_TOOL = {
    "toolSpec": {
        "name": "track_budget",
        "description": "Track trip spending or get budget status. Can add expenses or query remaining budget.",
        "inputSchema": {
            "json": {
                "type": "object",
                "properties": {
                    "action": {
                        "type": "string",
                        "enum": ["add_expense", "get_status", "set_budget"],
                        "description": "What to do with the budget",
                    },
                    "amount": {"type": "number", "description": "Amount in INR (for add_expense or set_budget)"},
                    "category": {"type": "string", "description": "Expense category (food, transport, activity, hotel)"},
                    "description": {"type": "string", "description": "What the expense was for"},
                },
                "required": ["action"],
            }
        },
    }
}

COMPARE_HOTELS_TOOL = {
    "toolSpec": {
        "name": "compare_hotels",
        "description": "Compare hotel prices across Booking.com, Goibibo, MakeMyTrip, and Agoda. Returns the cheapest option for the same property.",
        "inputSchema": {
            "json": {
                "type": "object",
                "properties": {
                    "query": {"type": "string", "description": "Hotel name or search query"},
                    "check_in": {"type": "string", "description": "Check-in date YYYY-MM-DD"},
                    "check_out": {"type": "string", "description": "Check-out date YYYY-MM-DD"},
                    "guests": {"type": "integer", "description": "Number of guests"},
                    "budget_max": {"type": "number", "description": "Max budget per night in INR"},
                },
                "required": ["query", "check_in", "check_out", "guests"],
            }
        },
    }
}


def get_all_tools() -> list[dict]:
    """Get all tool definitions for the orchestrator."""
    return [
        SEARCH_PLACES_TOOL,
        MAKE_BOOKING_TOOL,
        GET_WEATHER_TOOL,
        CREATE_ITINERARY_TOOL,
        GET_EMERGENCY_INFO_TOOL,
        TRACK_BUDGET_TOOL,
        COMPARE_HOTELS_TOOL,
        # Cache point after tools — they rarely change
        {"cachePoint": {"type": "default"}},
    ]


def get_tools_for_tier(tier: str) -> list[dict]:
    """Return tools available per pricing tier."""
    base = [SEARCH_PLACES_TOOL, GET_WEATHER_TOOL, CREATE_ITINERARY_TOOL]

    if tier in ("guide", "concierge"):
        base.append(GET_EMERGENCY_INFO_TOOL)
        base.append(TRACK_BUDGET_TOOL)

    if tier == "concierge":
        base.append(MAKE_BOOKING_TOOL)
        base.append(COMPARE_HOTELS_TOOL)

    base.append({"cachePoint": {"type": "default"}})
    return base
