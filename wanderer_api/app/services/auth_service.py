from datetime import datetime, timedelta, timezone
from jose import jwt
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.config import get_settings
from app.models.user import User
import uuid

settings = get_settings()


async def send_otp(phone: str) -> bool:
    if not settings.twilio_account_sid:
        return True  # dev mode — skip Twilio

    from twilio.rest import Client
    client = Client(settings.twilio_account_sid, settings.twilio_auth_token)
    verification = client.verify.v2.services(
        settings.twilio_verify_service_sid
    ).verifications.create(to=phone, channel="sms")
    return verification.status == "pending"


async def verify_otp(phone: str, code: str) -> bool:
    if not settings.twilio_account_sid:
        return code == "123456"  # dev mode — accept test code

    from twilio.rest import Client
    client = Client(settings.twilio_account_sid, settings.twilio_auth_token)
    check = client.verify.v2.services(
        settings.twilio_verify_service_sid
    ).verification_checks.create(to=phone, code=code)
    return check.status == "approved"


async def get_or_create_user(db: AsyncSession, phone: str) -> tuple[User, bool]:
    result = await db.execute(select(User).where(User.phone == phone))
    user = result.scalar_one_or_none()

    if user:
        return user, False

    user = User(id=uuid.uuid4(), phone=phone)
    db.add(user)
    await db.flush()
    return user, True


def create_access_token(user_id: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(hours=settings.jwt_expiry_hours)
    payload = {"sub": user_id, "exp": expire}
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def decode_access_token(token: str) -> dict:
    return jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
