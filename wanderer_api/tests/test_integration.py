import pytest
from httpx import AsyncClient, ASGITransport
from unittest.mock import AsyncMock, patch
from app.main import app


@pytest.mark.asyncio
async def test_full_auth_to_chat_flow():
    """Test: health → tiers → send OTP."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # 1. Health check
        resp = await client.get("/health")
        assert resp.status_code == 200

        # 2. Get pricing tiers (no auth needed)
        resp = await client.get("/api/v1/payments/tiers?currency=INR")
        assert resp.status_code == 200
        assert len(resp.json()["tiers"]) == 3

        # 3. Send OTP
        with patch("app.services.auth_service.send_otp", new_callable=AsyncMock, return_value=True):
            resp = await client.post(
                "/api/v1/auth/send-otp",
                json={"phone": "+919876543210"}
            )
        assert resp.status_code == 200
