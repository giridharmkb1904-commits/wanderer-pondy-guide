from sqlalchemy import Column, String, ForeignKey, Enum as SAEnum
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
import uuid
from . import Base, TimestampMixin


class ConversationSession(Base, TimestampMixin):
    __tablename__ = "conversation_sessions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    session_type = Column(SAEnum("voice", "text", "mixed", name="session_type"), default="text")
    current_location = Column(JSONB)
    active_itinerary_id = Column(UUID(as_uuid=True), ForeignKey("itineraries.id"), nullable=True)
    is_active = Column(String(10), default="active")

    user = relationship("User", back_populates="sessions")
    messages = relationship("Message", back_populates="session", order_by="Message.created_at")
