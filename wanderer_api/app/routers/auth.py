from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.auth import SendOtpRequest, VerifyOtpRequest, AuthResponse
from app.services.auth_service import send_otp, verify_otp, get_or_create_user, create_access_token
from app.database import get_db

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])


@router.post("/send-otp")
async def send_otp_endpoint(request: SendOtpRequest):
    success = await send_otp(request.phone)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to send OTP")
    return {"message": "OTP sent"}


@router.post("/verify-otp", response_model=AuthResponse)
async def verify_otp_endpoint(
    request: VerifyOtpRequest,
    db: AsyncSession = Depends(get_db),
):
    valid = await verify_otp(request.phone, request.code)
    if not valid:
        raise HTTPException(status_code=401, detail="Invalid OTP")

    user, is_new = await get_or_create_user(db, request.phone)
    token = create_access_token(str(user.id))

    return AuthResponse(
        access_token=token,
        user_id=str(user.id),
        is_new_user=is_new,
    )
