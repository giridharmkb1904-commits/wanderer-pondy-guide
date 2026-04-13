"""Admin dashboard routes — serves HTML pages with live data."""
from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from pathlib import Path
from datetime import datetime, timezone, timedelta
import random

router = APIRouter(prefix="/admin", tags=["admin"])

templates = Jinja2Templates(directory=str(Path(__file__).parent / "templates"))


def _mock_metrics() -> dict:
    """Generate realistic mock metrics for the dashboard."""
    today = datetime.now(timezone.utc)
    return {
        "total_users": 847,
        "active_today": 43,
        "revenue_today": 12_650,
        "revenue_month": 287_400,
        "bookings_today": 18,
        "bookings_pending": 5,
        "conversations_today": 156,
        "avg_session_minutes": 8.3,
        "top_tier": "Guide",
        "tier_breakdown": {"explorer": 312, "guide": 389, "concierge": 146},
        "revenue_7day": [
            {"date": (today - timedelta(days=i)).strftime("%b %d"), "amount": random.randint(8000, 18000)}
            for i in range(6, -1, -1)
        ],
        "popular_places": [
            {"name": "Le Dupleix", "category": "restaurant", "visits": 234, "bookings": 67},
            {"name": "Paradise Beach", "category": "beach", "visits": 198, "bookings": 0},
            {"name": "Manakula Vinayagar Temple", "category": "temple", "visits": 187, "bookings": 0},
            {"name": "Le Cafe", "category": "cafe", "visits": 156, "bookings": 0},
            {"name": "Villa Shanti", "category": "restaurant", "visits": 142, "bookings": 45},
            {"name": "Promenade Beach", "category": "beach", "visits": 134, "bookings": 0},
            {"name": "Auroville", "category": "ashram", "visits": 128, "bookings": 12},
            {"name": "Surguru", "category": "restaurant", "visits": 119, "bookings": 0},
        ],
        "recent_bookings": [
            {"user": "Priya M.", "place": "Le Dupleix", "date": "Today 7:30 PM", "party": 4, "status": "confirmed"},
            {"user": "James W.", "place": "Villa Shanti", "date": "Today 8:00 PM", "party": 2, "status": "pending"},
            {"user": "Arun K.", "place": "Scuba Diving", "date": "Tomorrow 9:00 AM", "party": 3, "status": "confirmed"},
            {"user": "Marie D.", "place": "Le Dupleix", "date": "Tomorrow 7:00 PM", "party": 2, "status": "pending"},
            {"user": "Ravi S.", "place": "Cooking Class", "date": "Apr 16 10:00 AM", "party": 1, "status": "confirmed"},
        ],
        "recent_users": [
            {"name": "Priya Menon", "phone": "+91 98765***10", "tier": "concierge", "days": 3, "joined": "2 hours ago"},
            {"name": "James Wilson", "phone": "+44 7700***42", "tier": "guide", "days": 5, "joined": "4 hours ago"},
            {"name": "Arun Kumar", "phone": "+91 87654***21", "tier": "explorer", "days": 1, "joined": "6 hours ago"},
            {"name": "Marie Dupont", "phone": "+33 6 12***89", "tier": "concierge", "days": 7, "joined": "8 hours ago"},
            {"name": "Ravi Shankar", "phone": "+91 99887***33", "tier": "guide", "days": 2, "joined": "12 hours ago"},
        ],
        "agent_stats": [
            {"name": "Restaurant Agent", "calls": 89, "avg_ms": 340, "model": "GPT-4.1-mini"},
            {"name": "Sightseeing Agent", "calls": 67, "avg_ms": 280, "model": "Claude Haiku"},
            {"name": "Itinerary Agent", "calls": 45, "avg_ms": 520, "model": "GPT-4.1-mini"},
            {"name": "Booking Agent", "calls": 23, "avg_ms": 180, "model": "GPT-4.1-nano"},
            {"name": "Safety Agent", "calls": 12, "avg_ms": 150, "model": "GPT-4.1-nano"},
            {"name": "Transport Agent", "calls": 34, "avg_ms": 160, "model": "GPT-4.1-nano"},
            {"name": "Budget Agent", "calls": 28, "avg_ms": 140, "model": "GPT-4.1-nano"},
            {"name": "Hotel Agent", "calls": 19, "avg_ms": 450, "model": "GPT-4.1-mini"},
        ],
    }


@router.get("", response_class=HTMLResponse)
@router.get("/", response_class=HTMLResponse)
async def dashboard(request: Request):
    metrics = _mock_metrics()
    return templates.TemplateResponse("dashboard.html", {"request": request, **metrics})


@router.get("/places", response_class=HTMLResponse)
async def places_page(request: Request):
    metrics = _mock_metrics()
    return templates.TemplateResponse("places.html", {"request": request, **metrics})


@router.get("/bookings", response_class=HTMLResponse)
async def bookings_page(request: Request):
    metrics = _mock_metrics()
    return templates.TemplateResponse("bookings.html", {"request": request, **metrics})


@router.get("/users", response_class=HTMLResponse)
async def users_page(request: Request):
    metrics = _mock_metrics()
    return templates.TemplateResponse("users.html", {"request": request, **metrics})


@router.get("/agents", response_class=HTMLResponse)
async def agents_page(request: Request):
    metrics = _mock_metrics()
    return templates.TemplateResponse("agents.html", {"request": request, **metrics})
