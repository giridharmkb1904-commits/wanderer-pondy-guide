from pydantic import BaseModel, field_validator
import re


class SendOtpRequest(BaseModel):
    phone: str

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        pattern = r"^\+[1-9]\d{6,14}$"
        if not re.match(pattern, v):
            raise ValueError("Phone must be in E.164 format (e.g. +919876543210)")
        return v


class VerifyOtpRequest(BaseModel):
    phone: str
    code: str

    @field_validator("code")
    @classmethod
    def validate_code(cls, v: str) -> str:
        if not v.isdigit() or len(v) != 6:
            raise ValueError("OTP must be a 6-digit code")
        return v


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    is_new_user: bool
