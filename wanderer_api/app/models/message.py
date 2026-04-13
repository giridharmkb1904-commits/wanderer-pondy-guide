from sqlalchemy import Column, String, Integer, Text, ForeignKey, Enum as SAEnum, Index
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
import uuid
from . import Base, TimestampMixin


class Message(Base, TimestampMixin):
    __tablename__ = "messages"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    session_id = Column(UUID(as_uuid=True), ForeignKey("conversation_sessions.id"), nullable=False)
    role = Column(SAEnum("user", "assistant", "tool", name="message_role"), nullable=False)
    content = Column(Text)
    audio_s3_key = Column(String(500))
    tool_calls = Column(JSONB)
    tool_results = Column(JSONB)
    tokens_used = Column(Integer)
    cache_read_tokens = Column(Integer)

    session = relationship("ConversationSession", back_populates="messages")

    __table_args__ = (
        Index("ix_messages_session_created", "session_id", "created_at"),
    )
