from sqlalchemy import Column, String, ForeignKey, DateTime, Enum as SAEnum
from sqlalchemy.dialects.postgresql import UUID, JSONB
import uuid
from . import Base, TimestampMixin


class Itinerary(Base, TimestampMixin):
    __tablename__ = "itineraries"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    title = Column(String(200))
    start_date = Column(DateTime(timezone=True))
    end_date = Column(DateTime(timezone=True))
    days = Column(JSONB)
    status = Column(SAEnum("draft", "active", "completed", name="itinerary_status"), default="draft")
    generated_by_session = Column(UUID(as_uuid=True), ForeignKey("conversation_sessions.id"))
