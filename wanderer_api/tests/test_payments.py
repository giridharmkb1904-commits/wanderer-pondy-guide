import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app


@pytest.mark.asyncio
async def test_get_pricing_tiers():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/payments/tiers")
    assert response.status_code == 200
    tiers = response.json()["tiers"]
    assert len(tiers) == 3
    assert tiers[0]["name"] == "explorer"
    assert tiers[1]["name"] == "guide"
    assert tiers[2]["name"] == "concierge"


@pytest.mark.asyncio
async def test_get_pricing_tiers_inr():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/payments/tiers?currency=INR")
    tiers = response.json()["tiers"]
    assert tiers[0]["price_per_day"] == 49
    assert tiers[0]["currency"] == "INR"


@pytest.mark.asyncio
async def test_get_pricing_tiers_usd():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/payments/tiers?currency=USD")
    tiers = response.json()["tiers"]
    assert tiers[0]["price_per_day"] == 1.99
    assert tiers[0]["currency"] == "USD"
