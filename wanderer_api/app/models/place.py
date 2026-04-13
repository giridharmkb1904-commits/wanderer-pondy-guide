from sqlalchemy import Column, String, Float, Boolean, Text, Enum as SAEnum
from sqlalchemy.dialects.postgresql import UUID, JSONB, ARRAY
from sqlalchemy.orm import relationship
import uuid
from . import Base, TimestampMixin


class Place(Base, TimestampMixin):
    __tablename__ = "places"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(200), nullable=False)
    name_tamil = Column(String(200))
    name_french = Column(String(200))
    category = Column(SAEnum(
        "restaurant", "temple", "beach", "museum", "cafe", "hotel",
        "ashram", "market", "nightlife", "shopping", "experience",
        "transport", "photo_spot", "hidden_gem",
        name="place_category"
    ))
    description = Column(Text)
    address = Column(Text)
    latitude = Column(Float)
    longitude = Column(Float)
    phone = Column(String(20))
    whatsapp_number = Column(String(20))
    opening_hours = Column(JSONB)
    price_range = Column(SAEnum("free", "budget", "mid", "premium", name="price_range"))
    cuisine_types = Column(ARRAY(String))
    tags = Column(ARRAY(String))
    accepts_bookings = Column(Boolean, default=False)
    google_place_id = Column(String(100))
    rating = Column(Float)
    photos = Column(JSONB, default=list)
    extra_data = Column(JSONB, default=dict)

    bookings = relationship("Booking", back_populates="place")
