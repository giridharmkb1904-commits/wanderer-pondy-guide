from sqlalchemy import Column, String, Float, ForeignKey, Enum as SAEnum, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from . import Base, TimestampMixin


class Payment(Base, TimestampMixin):
    __tablename__ = "payments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    tier = Column(SAEnum("explorer", "guide", "concierge", name="tier_type"), nullable=False)
    days_purchased = Column(Float, nullable=False)
    amount = Column(Float, nullable=False)
    currency = Column(String(10), nullable=False)
    gateway = Column(SAEnum("razorpay", "stripe", name="payment_gateway"), nullable=False)
    gateway_payment_id = Column(String(200))
    gateway_order_id = Column(String(200))
    status = Column(SAEnum("pending", "paid", "failed", "refunded", name="payment_status"), default="pending")
    valid_from = Column(DateTime(timezone=True))
    valid_until = Column(DateTime(timezone=True))

    user = relationship("User", back_populates="payments")
