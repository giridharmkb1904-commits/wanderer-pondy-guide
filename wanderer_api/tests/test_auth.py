import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from unittest.mock import AsyncMock, patch


@pytest.mark.asyncio
async def test_send_otp_returns_200():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        with patch("app.services.auth_service.send_otp", new_callable=AsyncMock, return_value=True):
            response = await client.post(
                "/api/v1/auth/send-otp",
                json={"phone": "+919876543210"}
            )
    assert response.status_code == 200
    assert response.json()["message"] == "OTP sent"


@pytest.mark.asyncio
async def test_send_otp_invalid_phone():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/auth/send-otp",
            json={"phone": "123"}
        )
    assert response.status_code == 422
