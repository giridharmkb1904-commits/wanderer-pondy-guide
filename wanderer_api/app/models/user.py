from sqlalchemy import Column, String, Boolean
from sqlalchemy.dialects.postgresql import UUID, JSONB, ARRAY
from sqlalchemy.orm import relationship
import uuid
from . import Base, TimestampMixin


class User(Base, TimestampMixin):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    phone = Column(String(20), unique=True, nullable=False, index=True)
    name = Column(String(100))
    preferred_language = Column(String(10), default="en")
    nationality = Column(String(50))
    travel_style = Column(String(20))
    dietary_preferences = Column(ARRAY(String))
    profile_data = Column(JSONB, default=dict)
    is_active = Column(Boolean, default=True)

    sessions = relationship("ConversationSession", back_populates="user")
    bookings = relationship("Booking", back_populates="user")
    payments = relationship("Payment", back_populates="user")
