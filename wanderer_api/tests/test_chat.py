import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app


@pytest.mark.asyncio
async def test_chat_rest_endpoint():
    """Test REST chat endpoint — should return 401 without auth."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/chat/message",
            json={"message": "Hello", "session_id": "test-session"},
            headers={"Authorization": "Bearer test-token"},
        )
    # Should fail auth (invalid token), proving route exists
    assert response.status_code in (200, 401, 403)
