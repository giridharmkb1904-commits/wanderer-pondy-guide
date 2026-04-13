from sqlalchemy import Column, String, Integer, Float, Text, ForeignKey, DateTime, Enum as SAEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from . import Base, TimestampMixin


class Booking(Base, TimestampMixin):
    __tablename__ = "bookings"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    place_id = Column(UUID(as_uuid=True), ForeignKey("places.id"), nullable=False)
    session_id = Column(UUID(as_uuid=True), ForeignKey("conversation_sessions.id"))
    booking_date = Column(DateTime(timezone=True), nullable=False)
    party_size = Column(Integer, nullable=False)
    status = Column(SAEnum(
        "pending", "confirmed", "declined", "cancelled", "completed",
        name="booking_status"
    ), default="pending")
    booking_method = Column(SAEnum("whatsapp", "twilio_call", "direct", "api", name="booking_method"))
    special_requests = Column(Text)
    amount = Column(Float)
    currency = Column(String(10))

    user = relationship("User", back_populates="bookings")
    place = relationship("Place", back_populates="bookings")
