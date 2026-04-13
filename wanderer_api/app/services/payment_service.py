import hmac
import hashlib
from datetime import datetime, timedelta, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from app.config import get_settings
from app.models.payment import Payment
import uuid

settings = get_settings()

TIERS = {
    "explorer": {"display": "Explorer", "inr": 49, "usd": 1.99, "features": [
        "Text chat with AI guide",
        "Personalized recommendations",
        "Itinerary building",
        "Offline cache",
    ]},
    "guide": {"display": "Guide", "inr": 199, "usd": 4.99, "features": [
        "Everything in Explorer",
        "Voice conversation",
        "Proactive alerts",
        "Navigation & transport",
    ]},
    "concierge": {"display": "Concierge", "inr": 349, "usd": 7.99, "features": [
        "Everything in Guide",
        "AI concierge booking",
        "Premium voice (ElevenLabs)",
        "Trip memories & journal",
        "Group sync",
        "Document vault",
        "Camera AI",
    ]},
}

PACKS = {
    "3day": {"days": 3, "discount": 0.15, "label": "3-Day Pack (15% off)"},
    "7day": {"days": 7, "discount": 0.25, "label": "7-Day Pack (25% off)"},
    "weekend": {"days": 3, "discount": 0.14, "label": "Weekend Pack"},
}


def get_pricing(currency: str = "INR") -> dict:
    price_key = "inr" if currency == "INR" else "usd"
    tiers = [
        {
            "name": name,
            "display_name": tier["display"],
            "price_per_day": tier[price_key],
            "currency": currency,
            "features": tier["features"],
        }
        for name, tier in TIERS.items()
    ]
    packs = [{"id": k, **v} for k, v in PACKS.items()]
    return {"tiers": tiers, "packs": packs}


def calculate_amount(tier: str, days: int, currency: str, pack: str | None) -> float:
    price_key = "inr" if currency == "INR" else "usd"
    per_day = TIERS[tier][price_key]
    total = per_day * days
    if pack and pack in PACKS:
        total *= (1 - PACKS[pack]["discount"])
    return round(total, 2)


def route_gateway(currency: str) -> str:
    return "razorpay" if currency == "INR" else "stripe"


async def create_razorpay_order(amount_inr: float, payment_id: str) -> dict:
    if not settings.razorpay_key_id:
        return {"id": f"order_test_{payment_id}", "amount": int(amount_inr * 100)}

    import razorpay
    client = razorpay.Client(auth=(settings.razorpay_key_id, settings.razorpay_key_secret))
    order = client.order.create({
        "amount": int(amount_inr * 100),
        "currency": "INR",
        "receipt": f"wanderer_{payment_id}",
    })
    return order


async def create_stripe_intent(amount: float, currency: str, payment_id: str) -> dict:
    if not settings.stripe_secret_key:
        return {"client_secret": f"pi_test_{payment_id}_secret", "id": f"pi_test_{payment_id}"}

    import stripe
    stripe.api_key = settings.stripe_secret_key
    intent = stripe.PaymentIntent.create(
        amount=int(amount * 100),
        currency=currency.lower(),
        metadata={"wanderer_payment_id": payment_id},
        automatic_payment_methods={"enabled": True},
    )
    return {"client_secret": intent.client_secret, "id": intent.id}


def verify_razorpay_signature(order_id: str, payment_id: str, signature: str) -> bool:
    if not settings.razorpay_key_secret:
        return True

    expected = hmac.new(
        settings.razorpay_key_secret.encode(),
        f"{order_id}|{payment_id}".encode(),
        hashlib.sha256,
    ).hexdigest()
    return hmac.compare_digest(expected, signature)


async def record_payment(
    db: AsyncSession,
    user_id: str,
    tier: str,
    days: int,
    amount: float,
    currency: str,
    gateway: str,
    gateway_order_id: str,
) -> Payment:
    now = datetime.now(timezone.utc)
    payment = Payment(
        id=uuid.uuid4(),
        user_id=uuid.UUID(user_id),
        tier=tier,
        days_purchased=days,
        amount=amount,
        currency=currency,
        gateway=gateway,
        gateway_order_id=gateway_order_id,
        status="pending",
        valid_from=now,
        valid_until=now + timedelta(days=days),
    )
    db.add(payment)
    await db.flush()
    return payment
