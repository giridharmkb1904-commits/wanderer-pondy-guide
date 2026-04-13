"""Tool executor — routes tool calls to actual implementations."""
import json
from datetime import datetime, timezone
from sqlalchemy import select, func as sa_func
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.place import Place
from app.models.booking import Booking
import uuid


async def execute_tool(name: str, inputs: dict, db: AsyncSession | None = None, user_id: str | None = None) -> dict:
    """Route tool call to implementation. Returns JSON-serializable result."""
    executors = {
        "search_places": _search_places,
        "make_booking": _make_booking,
        "get_weather": _get_weather,
        "create_itinerary": _create_itinerary,
        "get_emergency_info": _get_emergency_info,
        "track_budget": _track_budget,
        "compare_hotels": _compare_hotels,
    }

    executor = executors.get(name)
    if not executor:
        return {"error": f"Unknown tool: {name}"}

    try:
        return await executor(inputs, db=db, user_id=user_id)
    except Exception as e:
        return {"error": str(e)}


async def _search_places(inputs: dict, db: AsyncSession | None = None, **kwargs) -> dict:
    """Search places in the database."""
    if not db:
        return _mock_search_places(inputs)

    query = select(Place).where(Place.category == inputs["category"])

    if inputs.get("price_range"):
        query = query.where(Place.price_range == inputs["price_range"])

    limit = inputs.get("limit", 5)
    query = query.limit(limit)

    result = await db.execute(query)
    places = result.scalars().all()

    if not places:
        return _mock_search_places(inputs)

    return {
        "places": [
            {
                "id": str(p.id),
                "name": p.name,
                "category": p.category,
                "description": p.description,
                "address": p.address,
                "rating": p.rating,
                "price_range": p.price_range,
                "phone": p.phone,
                "cuisine_types": p.cuisine_types,
            }
            for p in places
        ],
        "count": len(places),
    }


def _mock_search_places(inputs: dict) -> dict:
    """Return mock data when DB is empty or unavailable."""
    category = inputs.get("category", "restaurant")
    mock_data = {
        "restaurant": [
            {"id": "mock-1", "name": "Le Dupleix", "category": "restaurant", "description": "Elegant French-Tamil fusion in a restored colonial mansion", "rating": 4.6, "price_range": "premium", "address": "5, Rue de la Caserne, White Town"},
            {"id": "mock-2", "name": "Villa Shanti", "category": "restaurant", "description": "Beautiful courtyard dining with contemporary Indian cuisine", "rating": 4.5, "price_range": "premium", "address": "14, Suffren Street, White Town"},
            {"id": "mock-3", "name": "Surguru", "category": "restaurant", "description": "Legendary South Indian thali. Locals swear by the filter coffee.", "rating": 4.4, "price_range": "budget", "address": "104, Mission Street"},
        ],
        "beach": [
            {"id": "mock-4", "name": "Paradise Beach", "category": "beach", "description": "Secluded golden sand beach accessible by boat from Chunnambar", "rating": 4.5, "price_range": "budget", "address": "Chunnambar Backwaters"},
            {"id": "mock-5", "name": "Promenade Beach", "category": "beach", "description": "The iconic 1.5km seafront walk. Best at sunrise or sunset.", "rating": 4.3, "price_range": "free", "address": "Goubert Avenue, White Town"},
        ],
        "temple": [
            {"id": "mock-6", "name": "Manakula Vinayagar Temple", "category": "temple", "description": "Ancient Ganesha temple with a temple elephant. A must-visit.", "rating": 4.7, "price_range": "free", "address": "Manakula Vinayagar Koil Street, White Town"},
        ],
        "cafe": [
            {"id": "mock-7", "name": "Le Cafe", "category": "cafe", "description": "Iconic beachfront cafe on the Promenade. Best sunset spot in Pondy.", "rating": 4.2, "price_range": "mid", "address": "Goubert Avenue, Beach Promenade"},
        ],
    }

    places = mock_data.get(category, mock_data["restaurant"])
    return {"places": places[:inputs.get("limit", 5)], "count": len(places)}


async def _make_booking(inputs: dict, db: AsyncSession | None = None, user_id: str | None = None, **kwargs) -> dict:
    """Create a booking record. Actual restaurant contact happens asynchronously."""
    if db and user_id:
        booking = Booking(
            id=uuid.uuid4(),
            user_id=uuid.UUID(user_id),
            place_id=uuid.UUID(inputs["place_id"]) if inputs["place_id"].startswith("mock") is False else uuid.uuid4(),
            booking_date=datetime.fromisoformat(f"{inputs['date']}T{inputs['time']}:00"),
            party_size=inputs["party_size"],
            status="pending",
            booking_method="whatsapp",
            special_requests=inputs.get("special_requests"),
        )
        db.add(booking)
        await db.flush()
        return {
            "status": "pending",
            "booking_id": str(booking.id),
            "message": f"Booking request sent for {inputs['party_size']} guests on {inputs['date']} at {inputs['time']}. I'll confirm shortly via WhatsApp.",
        }

    return {
        "status": "pending",
        "booking_id": f"mock-booking-{uuid.uuid4().hex[:8]}",
        "message": f"Booking request for {inputs['party_size']} guests on {inputs['date']} at {inputs['time']}. Confirmation pending.",
    }


async def _get_weather(inputs: dict, **kwargs) -> dict:
    """Get weather data. Mock for now — integrate OpenWeatherMap in Phase 4."""
    return {
        "location": "Pondicherry",
        "current": {"temp_c": 32, "humidity": 78, "condition": "Partly Cloudy", "wind_kph": 15},
        "forecast": [
            {"date": "today", "high_c": 34, "low_c": 26, "condition": "Partly Cloudy", "rain_chance": 20},
            {"date": "tomorrow", "high_c": 33, "low_c": 25, "condition": "Sunny", "rain_chance": 10},
        ],
        "tip": "Great weather for the beach! Carry sunscreen and stay hydrated.",
    }


async def _create_itinerary(inputs: dict, **kwargs) -> dict:
    """Generate itinerary structure. The AI fills in the narrative."""
    days = inputs.get("days", 1)
    interests = inputs.get("interests", ["sightseeing"])
    style = inputs.get("travel_style", "balanced")

    itinerary = []
    for d in range(1, days + 1):
        stops = []
        if style == "packed":
            times = ["06:00", "08:00", "10:00", "12:30", "14:30", "16:30", "19:00", "21:00"]
        elif style == "relaxed":
            times = ["09:00", "12:00", "15:00", "19:00"]
        else:
            times = ["08:00", "10:30", "13:00", "15:30", "18:00", "20:00"]

        for t in times:
            stops.append({"time": t, "activity": "TBD", "notes": ""})

        itinerary.append({"day": d, "stops": stops})

    return {
        "itinerary": itinerary,
        "days": days,
        "interests": interests,
        "style": style,
        "message": f"Created a {style} {days}-day itinerary framework. Let me fill in the details based on your interests.",
    }


async def _get_emergency_info(inputs: dict, **kwargs) -> dict:
    """Return emergency contacts for Pondicherry."""
    info = {
        "police": {"name": "Pondicherry Police Control Room", "phone": "100", "address": "Mahatma Gandhi Road"},
        "hospital": {"name": "JIPMER Hospital", "phone": "+91 413 227 2380", "address": "Dhanvantri Nagar"},
        "ambulance": {"phone": "108"},
        "fire": {"phone": "101"},
        "tourist_helpline": {"phone": "1363"},
    }

    if inputs.get("nationality"):
        nat = inputs["nationality"].lower()
        embassies = {
            "french": {"name": "French Consulate Pondicherry", "phone": "+91 413 223 1000", "address": "2, Marine Street, White Town"},
            "american": {"name": "US Consulate Chennai", "phone": "+91 44 2857 4000", "address": "Gemini Circle, Chennai (3hr drive)"},
            "british": {"name": "British Deputy High Commission Chennai", "phone": "+91 44 4219 2151", "address": "Anderson Road, Chennai"},
        }
        for key, embassy in embassies.items():
            if key in nat:
                info["embassy"] = embassy
                break

    req_type = inputs.get("type", "all")
    if req_type != "all":
        return {req_type: info.get(req_type, "Not found"), "emergency": "112"}

    return {**info, "emergency_universal": "112"}


async def _track_budget(inputs: dict, **kwargs) -> dict:
    """Track trip budget. Mock — persists in Redis session in production."""
    action = inputs["action"]
    if action == "set_budget":
        return {"status": "set", "total_budget": inputs.get("amount", 0), "currency": "INR", "remaining": inputs.get("amount", 0)}
    elif action == "add_expense":
        return {
            "status": "recorded",
            "expense": {"amount": inputs.get("amount", 0), "category": inputs.get("category", "other"), "description": inputs.get("description", "")},
            "message": f"Recorded expense of ₹{inputs.get('amount', 0)} for {inputs.get('description', 'misc')}",
        }
    else:
        return {"total_budget": 10000, "spent": 3500, "remaining": 6500, "currency": "INR", "breakdown": {"food": 1500, "transport": 500, "activities": 1000, "hotel": 500}}


async def _compare_hotels(inputs: dict, **kwargs) -> dict:
    """Compare hotel prices across platforms. Mock for now — real API integration in Phase 6."""
    return {
        "hotel": inputs.get("query", "Hotel"),
        "check_in": inputs.get("check_in"),
        "check_out": inputs.get("check_out"),
        "platforms": [
            {"platform": "Booking.com", "price_per_night": 3200, "currency": "INR", "rating": 4.3},
            {"platform": "Goibibo", "price_per_night": 2900, "currency": "INR", "rating": 4.3},
            {"platform": "MakeMyTrip", "price_per_night": 3100, "currency": "INR", "rating": 4.3},
            {"platform": "Agoda", "price_per_night": 3050, "currency": "INR", "rating": 4.3},
        ],
        "cheapest": {"platform": "Goibibo", "price_per_night": 2900},
        "message": f"Found {inputs.get('query', 'hotel')} on 4 platforms. Goibibo has the best rate at ₹2,900/night.",
    }
