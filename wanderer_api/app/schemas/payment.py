from pydantic import BaseModel
from typing import Optional


class PricingTier(BaseModel):
    name: str
    display_name: str
    price_per_day: float
    currency: str
    features: list[str]


class PricingResponse(BaseModel):
    tiers: list[PricingTier]
    packs: list[dict]


class CreateOrderRequest(BaseModel):
    tier: str
    days: int
    currency: str = "INR"
    pack: Optional[str] = None


class RazorpayOrderResponse(BaseModel):
    order_id: str
    amount: int
    currency: str
    gateway: str = "razorpay"


class StripeIntentResponse(BaseModel):
    client_secret: str
    payment_intent_id: str
    amount: int
    currency: str
    gateway: str = "stripe"


class VerifyPaymentRequest(BaseModel):
    gateway: str
    order_id: Optional[str] = None
    payment_id: str
    signature: Optional[str] = None
