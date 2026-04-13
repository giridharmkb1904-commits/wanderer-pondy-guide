from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.payment import (
    PricingResponse, CreateOrderRequest,
    RazorpayOrderResponse, StripeIntentResponse, VerifyPaymentRequest,
)
from app.services.payment_service import (
    get_pricing, calculate_amount, route_gateway,
    create_razorpay_order, create_stripe_intent,
    verify_razorpay_signature, record_payment,
)
from app.database import get_db
from app.middleware.auth_middleware import get_current_user_id

router = APIRouter(prefix="/api/v1/payments", tags=["payments"])


@router.get("/tiers", response_model=PricingResponse)
async def get_tiers(currency: str = "INR"):
    return get_pricing(currency)


@router.post("/create-order")
async def create_order(
    request: CreateOrderRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    if request.tier not in ("explorer", "guide", "concierge"):
        raise HTTPException(status_code=400, detail="Invalid tier")

    amount = calculate_amount(request.tier, request.days, request.currency, request.pack)
    gateway = route_gateway(request.currency)

    if gateway == "razorpay":
        order = await create_razorpay_order(amount, str(user_id))
        await record_payment(
            db, user_id, request.tier, request.days,
            amount, request.currency, "razorpay", order["id"],
        )
        return RazorpayOrderResponse(
            order_id=order["id"],
            amount=int(amount * 100),
            currency=request.currency,
        )
    else:
        intent = await create_stripe_intent(amount, request.currency, str(user_id))
        await record_payment(
            db, user_id, request.tier, request.days,
            amount, request.currency, "stripe", intent["id"],
        )
        return StripeIntentResponse(
            client_secret=intent["client_secret"],
            payment_intent_id=intent["id"],
            amount=int(amount * 100),
            currency=request.currency,
        )


@router.post("/verify")
async def verify_payment(
    request: VerifyPaymentRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    if request.gateway == "razorpay":
        if not verify_razorpay_signature(request.order_id, request.payment_id, request.signature):
            raise HTTPException(status_code=400, detail="Invalid payment signature")
    return {"status": "verified", "gateway": request.gateway}
