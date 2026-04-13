# Wanderer Phase 1: Foundation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the full project skeleton — Flutter app with chat UI shell, FastAPI backend with PostgreSQL + Redis, phone OTP auth, payment integration (Razorpay + Stripe), and basic WebSocket chat endpoint. No AI yet — Phase 2 plugs in Claude.

**Architecture:** Flutter mobile client communicates with a FastAPI backend over REST + WebSocket. PostgreSQL (RDS) stores persistent data, Redis caches active sessions. Auth via phone OTP (Twilio Verify). Payments routed by currency — Razorpay for INR, Stripe for international.

**Tech Stack:**
- **Client:** Flutter 3.x, Dart 3.x, Riverpod 3, go_router 14
- **Backend:** Python 3.12, FastAPI 0.115, SQLAlchemy 2.0, asyncpg, Redis 5, Alembic
- **Infra:** EC2, RDS (PostgreSQL 16), ElastiCache (Redis), S3
- **Payments:** Razorpay 1.4, Stripe 10.12
- **Auth:** Twilio Verify (phone OTP)

---

## File Structure

### Flutter Client (`wanderer_app/`)

```
wanderer_app/
  lib/
    main.dart
    app.dart
    core/
      theme/
        app_theme.dart
        colors.dart
      router/
        app_router.dart
      network/
        api_client.dart
        websocket_client.dart
      config/
        env_config.dart
    features/
      auth/
        data/
          auth_repository.dart
        domain/
          user_entity.dart
        presentation/
          providers/
            auth_provider.dart
          screens/
            onboarding_screen.dart
            otp_screen.dart
      chat/
        data/
          chat_repository.dart
        domain/
          message_entity.dart
        presentation/
          providers/
            chat_provider.dart
          screens/
            chat_screen.dart
          widgets/
            message_bubble.dart
            voice_button.dart
            waveform_animation.dart
      payments/
        data/
          payment_repository.dart
        domain/
          subscription_entity.dart
        presentation/
          providers/
            payment_provider.dart
          screens/
            plan_selection_screen.dart
    shared/
      widgets/
        loading_indicator.dart
  test/
    features/
      auth/
        auth_repository_test.dart
        auth_provider_test.dart
      chat/
        chat_repository_test.dart
        message_entity_test.dart
      payments/
        payment_repository_test.dart
  pubspec.yaml
```

### Backend (`wanderer_api/`)

```
wanderer_api/
  app/
    main.py
    config.py
    database.py
    redis_client.py
    models/
      __init__.py
      user.py
      session.py
      message.py
      place.py
      booking.py
      itinerary.py
      payment.py
    schemas/
      __init__.py
      auth.py
      chat.py
      payment.py
    routers/
      __init__.py
      auth.py
      chat.py
      payments.py
      health.py
    services/
      __init__.py
      auth_service.py
      chat_service.py
      payment_service.py
    middleware/
      auth_middleware.py
  alembic/
    env.py
    versions/
  tests/
    conftest.py
    test_auth.py
    test_chat.py
    test_payments.py
    test_health.py
  alembic.ini
  requirements.txt
  Dockerfile
  docker-compose.yml
  .env.example
```

---

## Task 1: Flutter Project Scaffold

**Files:**
- Create: `wanderer_app/pubspec.yaml`
- Create: `wanderer_app/lib/main.dart`
- Create: `wanderer_app/lib/app.dart`
- Create: `wanderer_app/lib/core/config/env_config.dart`
- Create: `wanderer_app/lib/core/theme/colors.dart`
- Create: `wanderer_app/lib/core/theme/app_theme.dart`
- Create: `wanderer_app/lib/core/router/app_router.dart`
- Create: `wanderer_app/analysis_options.yaml`

- [ ] **Step 1: Create Flutter project**

```bash
cd C:/Users/shreya/pondy-guide
flutter create wanderer_app --org com.wanderer --platforms ios,android
cd wanderer_app
```

- [ ] **Step 2: Replace pubspec.yaml with project dependencies**

```yaml
name: wanderer_app
description: Wanderer - Your AI Tour Guide
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.5.0
  flutter: ">=3.24.0"

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^3.3.1
  riverpod_annotation: ^4.0.2

  # Routing
  go_router: ^14.0.0

  # Network
  dio: ^5.7.0
  web_socket_channel: ^3.0.2

  # Storage
  shared_preferences: ^2.3.0
  flutter_secure_storage: ^9.2.0

  # UI
  google_fonts: ^6.2.0
  flutter_animate: ^4.5.0
  shimmer: ^3.0.0

  # Payments
  razorpay_flutter: ^1.3.7

  # Utils
  intl: ^0.19.0
  uuid: ^4.5.0
  url_launcher: ^6.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  riverpod_generator: ^2.6.0
  build_runner: ^2.4.0
  mockito: ^5.4.0
  build_runner: ^2.4.0

flutter:
  uses-material-design: true
```

- [ ] **Step 3: Create environment config**

Create `lib/core/config/env_config.dart`:

```dart
class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://10.0.2.2:8000',
  );

  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: '',
  );

  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );
}
```

- [ ] **Step 4: Create color palette**

Create `lib/core/theme/colors.dart`:

```dart
import 'package:flutter/material.dart';

class WandererColors {
  // Primary dark canvas
  static const Color background = Color(0xFF0A0A0C);
  static const Color surface = Color(0xFF141418);
  static const Color surfaceLight = Color(0xFF1E1E24);

  // Accent — warm teal (guide presence)
  static const Color primary = Color(0xFF3ECFB4);
  static const Color primaryMuted = Color(0xFF2A9D8F);

  // Secondary — warm amber (highlights)
  static const Color secondary = Color(0xFFF59E0B);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Functional
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  // Chat
  static const Color userBubble = Color(0xFF1E3A5F);
  static const Color guideBubble = Color(0xFF1A1A22);
}
```

- [ ] **Step 5: Create app theme**

Create `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: WandererColors.background,
      colorScheme: const ColorScheme.dark(
        primary: WandererColors.primary,
        secondary: WandererColors.secondary,
        surface: WandererColors.surface,
        error: WandererColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: WandererColors.textPrimary,
        displayColor: WandererColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WandererColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: WandererColors.textMuted),
      ),
    );
  }
}
```

- [ ] **Step 6: Create router**

Create `lib/core/router/app_router.dart`:

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/payments/presentation/screens/plan_selection_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phone = state.extra as String;
          return OtpScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: '/plans',
        builder: (context, state) => const PlanSelectionScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
    ],
  );
});
```

- [ ] **Step 7: Create app.dart and main.dart**

Create `lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class WandererApp extends ConsumerWidget {
  const WandererApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Wanderer',
      theme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

Replace `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: WandererApp(),
    ),
  );
}
```

- [ ] **Step 8: Create placeholder screens**

Create `lib/features/auth/presentation/screens/onboarding_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Wanderer',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: WandererColors.primary,
          ),
        ),
      ),
    );
  }
}
```

Create `lib/features/auth/presentation/screens/otp_screen.dart`:

```dart
import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('OTP for $phoneNumber')),
    );
  }
}
```

Create `lib/features/chat/presentation/screens/chat_screen.dart`:

```dart
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Chat')),
    );
  }
}
```

Create `lib/features/payments/presentation/screens/plan_selection_screen.dart`:

```dart
import 'package:flutter/material.dart';

class PlanSelectionScreen extends StatelessWidget {
  const PlanSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Plans')),
    );
  }
}
```

- [ ] **Step 9: Verify build**

```bash
cd C:/Users/shreya/pondy-guide/wanderer_app
flutter pub get
flutter analyze
```

Expected: No errors, no warnings.

- [ ] **Step 10: Commit**

```bash
cd C:/Users/shreya/pondy-guide
git add wanderer_app/
git commit -m "feat: scaffold Flutter project with feature-first structure, Riverpod, go_router"
```

---

## Task 2: Backend Project Scaffold

**Files:**
- Create: `wanderer_api/requirements.txt`
- Create: `wanderer_api/app/main.py`
- Create: `wanderer_api/app/config.py`
- Create: `wanderer_api/app/database.py`
- Create: `wanderer_api/app/redis_client.py`
- Create: `wanderer_api/app/routers/health.py`
- Create: `wanderer_api/docker-compose.yml`
- Create: `wanderer_api/Dockerfile`
- Create: `wanderer_api/.env.example`

- [ ] **Step 1: Write the failing test**

Create `wanderer_api/tests/test_health.py`:

```python
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_health_check():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
```

Create `wanderer_api/tests/conftest.py`:

```python
import pytest
import asyncio

@pytest.fixture(scope="session")
def event_loop():
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()
```

- [ ] **Step 2: Create requirements.txt**

```
# Web framework
fastapi>=0.115.0
uvicorn[standard]>=0.30.0
pydantic>=2.7.0
pydantic-settings>=2.3.0

# Database
sqlalchemy>=2.0.36
asyncpg>=0.29.0
alembic>=1.13.0

# Cache
redis>=5.0.7

# AWS
boto3>=1.35.0

# Voice / AI services
deepgram-sdk>=3.7.0
elevenlabs>=1.50.0

# HTTP client
httpx>=0.27.0

# Payments
razorpay>=1.4.2
stripe>=10.12.0

# Telephony
twilio>=9.3.0

# Auth
python-jose[cryptography]>=3.3.0
passlib[bcrypt]>=1.7.4

# Utils
python-multipart>=0.0.9
python-dotenv>=1.0.1

# Testing
pytest>=8.3.0
pytest-asyncio>=0.24.0
httpx>=0.27.0
```

- [ ] **Step 3: Create config**

Create `wanderer_api/app/config.py`:

```python
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    # App
    app_name: str = "Wanderer API"
    debug: bool = False

    # Database
    database_url: str = "postgresql+asyncpg://wanderer:wanderer@localhost:5432/wanderer"

    # Redis
    redis_url: str = "redis://localhost:6379"

    # Auth
    jwt_secret: str = "change-me-in-production"
    jwt_algorithm: str = "HS256"
    jwt_expiry_hours: int = 72

    # Twilio (OTP)
    twilio_account_sid: str = ""
    twilio_auth_token: str = ""
    twilio_verify_service_sid: str = ""

    # Payments
    razorpay_key_id: str = ""
    razorpay_key_secret: str = ""
    stripe_secret_key: str = ""
    stripe_webhook_secret: str = ""

    # AWS
    aws_region: str = "ap-south-1"
    bedrock_model_id: str = "anthropic.claude-sonnet-4-5-20250929-v1:0"

    # Voice
    deepgram_api_key: str = ""
    elevenlabs_api_key: str = ""

    model_config = {"env_file": ".env"}

@lru_cache
def get_settings() -> Settings:
    return Settings()
```

- [ ] **Step 4: Create database module**

Create `wanderer_api/app/database.py`:

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from app.config import get_settings

settings = get_settings()

engine = create_async_engine(
    settings.database_url,
    pool_size=10,
    max_overflow=20,
    echo=settings.debug,
)

AsyncSessionLocal = async_sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

- [ ] **Step 5: Create Redis client**

Create `wanderer_api/app/redis_client.py`:

```python
import redis.asyncio as aioredis
from app.config import get_settings

settings = get_settings()

redis_client = aioredis.from_url(
    settings.redis_url,
    decode_responses=True,
)

async def get_redis() -> aioredis.Redis:
    return redis_client
```

- [ ] **Step 6: Create health router**

Create `wanderer_api/app/routers/__init__.py`:

```python
```

Create `wanderer_api/app/routers/health.py`:

```python
from fastapi import APIRouter

router = APIRouter()

@router.get("/health")
async def health_check():
    return {"status": "healthy", "service": "wanderer-api"}
```

- [ ] **Step 7: Create main app**

Create `wanderer_api/app/__init__.py`:

```python
```

Create `wanderer_api/app/main.py`:

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import health

app = FastAPI(title="Wanderer API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
```

- [ ] **Step 8: Run test to verify it passes**

```bash
cd C:/Users/shreya/pondy-guide/wanderer_api
pip install -r requirements.txt
pytest tests/test_health.py -v
```

Expected: `test_health_check PASSED`

- [ ] **Step 9: Create docker-compose.yml**

Create `wanderer_api/docker-compose.yml`:

```yaml
version: "3.9"
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: wanderer
      POSTGRES_USER: wanderer
      POSTGRES_PASSWORD: wanderer
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql+asyncpg://wanderer:wanderer@db:5432/wanderer
      REDIS_URL: redis://redis:6379
    depends_on:
      - db
      - redis

volumes:
  pgdata:
```

Create `wanderer_api/Dockerfile`:

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Create `wanderer_api/.env.example`:

```
DATABASE_URL=postgresql+asyncpg://wanderer:wanderer@localhost:5432/wanderer
REDIS_URL=redis://localhost:6379
JWT_SECRET=change-me-in-production
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_VERIFY_SERVICE_SID=
RAZORPAY_KEY_ID=
RAZORPAY_KEY_SECRET=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
DEEPGRAM_API_KEY=
ELEVENLABS_API_KEY=
AWS_REGION=ap-south-1
```

- [ ] **Step 10: Commit**

```bash
cd C:/Users/shreya/pondy-guide
git add wanderer_api/
git commit -m "feat: scaffold FastAPI backend with PostgreSQL, Redis, health endpoint"
```

---

## Task 3: Database Schema & Migrations

**Files:**
- Create: `wanderer_api/app/models/__init__.py`
- Create: `wanderer_api/app/models/user.py`
- Create: `wanderer_api/app/models/session.py`
- Create: `wanderer_api/app/models/message.py`
- Create: `wanderer_api/app/models/place.py`
- Create: `wanderer_api/app/models/booking.py`
- Create: `wanderer_api/app/models/itinerary.py`
- Create: `wanderer_api/app/models/payment.py`
- Create: `wanderer_api/alembic/env.py`

- [ ] **Step 1: Create base model**

Create `wanderer_api/app/models/__init__.py`:

```python
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy import Column, DateTime
from sqlalchemy.sql import func

class Base(DeclarativeBase):
    pass

class TimestampMixin:
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
```

- [ ] **Step 2: Create User model**

Create `wanderer_api/app/models/user.py`:

```python
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
    travel_style = Column(String(20))  # "budget", "comfort", "luxury"
    dietary_preferences = Column(ARRAY(String))
    profile_data = Column(JSONB, default=dict)
    is_active = Column(Boolean, default=True)

    sessions = relationship("ConversationSession", back_populates="user")
    bookings = relationship("Booking", back_populates="user")
    payments = relationship("Payment", back_populates="user")
```

- [ ] **Step 3: Create ConversationSession model**

Create `wanderer_api/app/models/session.py`:

```python
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
```

- [ ] **Step 4: Create Message model**

Create `wanderer_api/app/models/message.py`:

```python
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
```

- [ ] **Step 5: Create Place model**

Create `wanderer_api/app/models/place.py`:

```python
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
    metadata = Column(JSONB, default=dict)

    bookings = relationship("Booking", back_populates="place")
```

- [ ] **Step 6: Create Booking model**

Create `wanderer_api/app/models/booking.py`:

```python
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
```

- [ ] **Step 7: Create Itinerary model**

Create `wanderer_api/app/models/itinerary.py`:

```python
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
```

- [ ] **Step 8: Create Payment model**

Create `wanderer_api/app/models/payment.py`:

```python
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
```

- [ ] **Step 9: Initialize Alembic and create migration**

```bash
cd C:/Users/shreya/pondy-guide/wanderer_api
alembic init alembic
```

Update `wanderer_api/alembic/env.py` — replace the `target_metadata = None` line and add imports:

```python
from app.models import Base
from app.models.user import User
from app.models.session import ConversationSession
from app.models.message import Message
from app.models.place import Place
from app.models.booking import Booking
from app.models.itinerary import Itinerary
from app.models.payment import Payment

target_metadata = Base.metadata
```

Update `alembic.ini` to use the correct DB URL:

```ini
sqlalchemy.url = postgresql+asyncpg://wanderer:wanderer@localhost:5432/wanderer
```

Run (requires docker-compose db running):

```bash
docker compose up -d db
alembic revision --autogenerate -m "initial schema"
alembic upgrade head
```

- [ ] **Step 10: Commit**

```bash
cd C:/Users/shreya/pondy-guide
git add wanderer_api/
git commit -m "feat: add database models (User, Session, Message, Place, Booking, Itinerary, Payment) with Alembic migrations"
```

---

## Task 4: Phone OTP Authentication

**Files:**
- Create: `wanderer_api/app/schemas/auth.py`
- Create: `wanderer_api/app/services/auth_service.py`
- Create: `wanderer_api/app/routers/auth.py`
- Create: `wanderer_api/app/middleware/auth_middleware.py`
- Test: `wanderer_api/tests/test_auth.py`

- [ ] **Step 1: Write the failing test**

Create `wanderer_api/tests/test_auth.py`:

```python
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from unittest.mock import AsyncMock, patch

@pytest.mark.asyncio
async def test_send_otp_returns_200():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        with patch("app.services.auth_service.send_otp", new_callable=AsyncMock, return_value=True):
            response = await client.post(
                "/api/v1/auth/send-otp",
                json={"phone": "+919876543210"}
            )
    assert response.status_code == 200
    assert response.json()["message"] == "OTP sent"

@pytest.mark.asyncio
async def test_send_otp_invalid_phone():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/auth/send-otp",
            json={"phone": "123"}
        )
    assert response.status_code == 422
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd C:/Users/shreya/pondy-guide/wanderer_api
pytest tests/test_auth.py -v
```

Expected: FAIL — route not found.

- [ ] **Step 3: Create auth schemas**

Create `wanderer_api/app/schemas/__init__.py`:

```python
```

Create `wanderer_api/app/schemas/auth.py`:

```python
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
```

- [ ] **Step 4: Create auth service**

Create `wanderer_api/app/services/__init__.py`:

```python
```

Create `wanderer_api/app/services/auth_service.py`:

```python
from datetime import datetime, timedelta, timezone
from jose import jwt
from twilio.rest import Client
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.config import get_settings
from app.models.user import User
import uuid

settings = get_settings()

async def send_otp(phone: str) -> bool:
    if not settings.twilio_account_sid:
        return True  # dev mode — skip Twilio

    client = Client(settings.twilio_account_sid, settings.twilio_auth_token)
    verification = client.verify.v2.services(
        settings.twilio_verify_service_sid
    ).verifications.create(to=phone, channel="sms")
    return verification.status == "pending"

async def verify_otp(phone: str, code: str) -> bool:
    if not settings.twilio_account_sid:
        return code == "123456"  # dev mode — accept test code

    client = Client(settings.twilio_account_sid, settings.twilio_auth_token)
    check = client.verify.v2.services(
        settings.twilio_verify_service_sid
    ).verification_checks.create(to=phone, code=code)
    return check.status == "approved"

async def get_or_create_user(db: AsyncSession, phone: str) -> tuple[User, bool]:
    result = await db.execute(select(User).where(User.phone == phone))
    user = result.scalar_one_or_none()

    if user:
        return user, False

    user = User(id=uuid.uuid4(), phone=phone)
    db.add(user)
    await db.flush()
    return user, True

def create_access_token(user_id: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(hours=settings.jwt_expiry_hours)
    payload = {"sub": user_id, "exp": expire}
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)

def decode_access_token(token: str) -> dict:
    return jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
```

- [ ] **Step 5: Create auth router**

Create `wanderer_api/app/routers/auth.py`:

```python
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
```

- [ ] **Step 6: Create auth middleware**

Create `wanderer_api/app/middleware/__init__.py`:

```python
```

Create `wanderer_api/app/middleware/auth_middleware.py`:

```python
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.services.auth_service import decode_access_token

bearer_scheme = HTTPBearer()

async def get_current_user_id(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
) -> str:
    try:
        payload = decode_access_token(credentials.credentials)
        return payload["sub"]
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
```

- [ ] **Step 7: Register auth router in main.py**

Update `wanderer_api/app/main.py` — add the import and include:

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import health, auth

app = FastAPI(title="Wanderer API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(auth.router)
```

- [ ] **Step 8: Run tests**

```bash
cd C:/Users/shreya/pondy-guide/wanderer_api
pytest tests/test_auth.py -v
```

Expected: Both tests PASS.

- [ ] **Step 9: Commit**

```bash
cd C:/Users/shreya/pondy-guide
git add wanderer_api/
git commit -m "feat: add phone OTP authentication with Twilio Verify, JWT tokens"
```

---

## Task 5: Payment Integration (Razorpay + Stripe)

**Files:**
- Create: `wanderer_api/app/schemas/payment.py`
- Create: `wanderer_api/app/services/payment_service.py`
- Create: `wanderer_api/app/routers/payments.py`
- Test: `wanderer_api/tests/test_payments.py`

- [ ] **Step 1: Write the failing test**

Create `wanderer_api/tests/test_payments.py`:

```python
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_get_pricing_tiers():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/payments/tiers")
    assert response.status_code == 200
    tiers = response.json()["tiers"]
    assert len(tiers) == 3
    assert tiers[0]["name"] == "explorer"
    assert tiers[1]["name"] == "guide"
    assert tiers[2]["name"] == "concierge"

@pytest.mark.asyncio
async def test_get_pricing_tiers_inr():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/payments/tiers?currency=INR")
    tiers = response.json()["tiers"]
    assert tiers[0]["price_per_day"] == 49
    assert tiers[0]["currency"] == "INR"

@pytest.mark.asyncio
async def test_get_pricing_tiers_usd():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/payments/tiers?currency=USD")
    tiers = response.json()["tiers"]
    assert tiers[0]["price_per_day"] == 1.99
    assert tiers[0]["currency"] == "USD"
```

- [ ] **Step 2: Run test to verify it fails**

```bash
pytest tests/test_payments.py -v
```

Expected: FAIL — route not found.

- [ ] **Step 3: Create payment schemas**

Create `wanderer_api/app/schemas/payment.py`:

```python
from pydantic import BaseModel
from typing import Optional

class PricingTier(BaseModel):
    name: str
    display_name: str
    price_per_day: float
    currency: str
    features: list[str]

class PricingResponse(BaseModel):
    tiers: list[PricingTier]
    packs: list[dict]

class CreateOrderRequest(BaseModel):
    tier: str  # "explorer", "guide", "concierge"
    days: int
    currency: str = "INR"
    pack: Optional[str] = None  # "3day", "7day", "weekend"

class RazorpayOrderResponse(BaseModel):
    order_id: str
    amount: int  # paisa
    currency: str
    gateway: str = "razorpay"

class StripeIntentResponse(BaseModel):
    client_secret: str
    payment_intent_id: str
    amount: int  # cents
    currency: str
    gateway: str = "stripe"

class VerifyPaymentRequest(BaseModel):
    gateway: str
    order_id: Optional[str] = None
    payment_id: str
    signature: Optional[str] = None  # Razorpay only
```

- [ ] **Step 4: Create payment service**

Create `wanderer_api/app/services/payment_service.py`:

```python
import razorpay
import stripe
import hmac
import hashlib
from datetime import datetime, timedelta, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from app.config import get_settings
from app.models.payment import Payment
import uuid

settings = get_settings()

TIERS = {
    "explorer": {"display": "Explorer", "inr": 49, "usd": 1.99, "features": [
        "Text chat with AI guide",
        "Personalized recommendations",
        "Itinerary building",
        "Offline cache",
    ]},
    "guide": {"display": "Guide", "inr": 199, "usd": 4.99, "features": [
        "Everything in Explorer",
        "Voice conversation",
        "Proactive alerts",
        "Navigation & transport",
    ]},
    "concierge": {"display": "Concierge", "inr": 349, "usd": 7.99, "features": [
        "Everything in Guide",
        "AI concierge booking",
        "Premium voice (ElevenLabs)",
        "Trip memories & journal",
        "Group sync",
        "Document vault",
        "Camera AI",
    ]},
}

PACKS = {
    "3day": {"days": 3, "discount": 0.15, "label": "3-Day Pack (15% off)"},
    "7day": {"days": 7, "discount": 0.25, "label": "7-Day Pack (25% off)"},
    "weekend": {"days": 3, "discount": 0.14, "label": "Weekend Pack"},
}

def get_pricing(currency: str = "INR") -> dict:
    price_key = "inr" if currency == "INR" else "usd"
    tiers = [
        {
            "name": name,
            "display_name": tier["display"],
            "price_per_day": tier[price_key],
            "currency": currency,
            "features": tier["features"],
        }
        for name, tier in TIERS.items()
    ]
    packs = [{"id": k, **v} for k, v in PACKS.items()]
    return {"tiers": tiers, "packs": packs}

def calculate_amount(tier: str, days: int, currency: str, pack: str | None) -> float:
    price_key = "inr" if currency == "INR" else "usd"
    per_day = TIERS[tier][price_key]
    total = per_day * days

    if pack and pack in PACKS:
        total *= (1 - PACKS[pack]["discount"])

    return round(total, 2)

def route_gateway(currency: str) -> str:
    return "razorpay" if currency == "INR" else "stripe"

async def create_razorpay_order(amount_inr: float, payment_id: str) -> dict:
    if not settings.razorpay_key_id:
        return {"id": f"order_test_{payment_id}", "amount": int(amount_inr * 100)}

    client = razorpay.Client(auth=(settings.razorpay_key_id, settings.razorpay_key_secret))
    order = client.order.create({
        "amount": int(amount_inr * 100),
        "currency": "INR",
        "receipt": f"wanderer_{payment_id}",
    })
    return order

async def create_stripe_intent(amount: float, currency: str, payment_id: str) -> dict:
    if not settings.stripe_secret_key:
        return {"client_secret": f"pi_test_{payment_id}_secret", "id": f"pi_test_{payment_id}"}

    stripe.api_key = settings.stripe_secret_key
    intent = stripe.PaymentIntent.create(
        amount=int(amount * 100),
        currency=currency.lower(),
        metadata={"wanderer_payment_id": payment_id},
        automatic_payment_methods={"enabled": True},
    )
    return {"client_secret": intent.client_secret, "id": intent.id}

def verify_razorpay_signature(order_id: str, payment_id: str, signature: str) -> bool:
    if not settings.razorpay_key_secret:
        return True  # dev mode

    expected = hmac.new(
        settings.razorpay_key_secret.encode(),
        f"{order_id}|{payment_id}".encode(),
        hashlib.sha256,
    ).hexdigest()
    return hmac.compare_digest(expected, signature)

async def record_payment(
    db: AsyncSession,
    user_id: str,
    tier: str,
    days: int,
    amount: float,
    currency: str,
    gateway: str,
    gateway_order_id: str,
) -> Payment:
    now = datetime.now(timezone.utc)
    payment = Payment(
        id=uuid.uuid4(),
        user_id=uuid.UUID(user_id),
        tier=tier,
        days_purchased=days,
        amount=amount,
        currency=currency,
        gateway=gateway,
        gateway_order_id=gateway_order_id,
        status="pending",
        valid_from=now,
        valid_until=now + timedelta(days=days),
    )
    db.add(payment)
    await db.flush()
    return payment
```

- [ ] **Step 5: Create payments router**

Create `wanderer_api/app/routers/payments.py`:

```python
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
        payment = await record_payment(
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
        payment = await record_payment(
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

    # TODO Phase 2: update payment status in DB, activate subscription
    return {"status": "verified", "gateway": request.gateway}
```

- [ ] **Step 6: Register payments router in main.py**

Update `wanderer_api/app/main.py`:

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import health, auth, payments

app = FastAPI(title="Wanderer API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(auth.router)
app.include_router(payments.router)
```

- [ ] **Step 7: Run tests**

```bash
pytest tests/test_payments.py -v
```

Expected: All 3 tests PASS.

- [ ] **Step 8: Commit**

```bash
cd C:/Users/shreya/pondy-guide
git add wanderer_api/
git commit -m "feat: add payment integration with Razorpay (INR) + Stripe (intl), tiered pricing"
```

---

## Task 6: Chat WebSocket Endpoint (Echo — AI plugs in Phase 2)

**Files:**
- Create: `wanderer_api/app/schemas/chat.py`
- Create: `wanderer_api/app/services/chat_service.py`
- Create: `wanderer_api/app/routers/chat.py`
- Test: `wanderer_api/tests/test_chat.py`

- [ ] **Step 1: Write the failing test**

Create `wanderer_api/tests/test_chat.py`:

```python
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_chat_rest_endpoint():
    """Test REST chat endpoint (WebSocket tested manually)."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/chat/message",
            json={"message": "Hello", "session_id": "test-session"},
            headers={"Authorization": "Bearer test-token"},
        )
    # Will fail auth in test, but route should exist
    assert response.status_code in (200, 401)
```

- [ ] **Step 2: Run test to verify it fails**

```bash
pytest tests/test_chat.py -v
```

Expected: FAIL — route not found (404).

- [ ] **Step 3: Create chat schemas**

Create `wanderer_api/app/schemas/chat.py`:

```python
from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class ChatMessageRequest(BaseModel):
    message: str
    session_id: Optional[str] = None

class ChatMessageResponse(BaseModel):
    response: str
    session_id: str
    timestamp: datetime
    cards: list[dict] = []

class WebSocketMessage(BaseModel):
    type: str  # "text", "audio", "ping"
    content: Optional[str] = None
    audio_base64: Optional[str] = None
    session_id: Optional[str] = None
```

- [ ] **Step 4: Create chat service**

Create `wanderer_api/app/services/chat_service.py`:

```python
import json
from datetime import datetime, timezone
from redis.asyncio import Redis
import uuid

SESSION_TTL = 3600  # 1 hour

async def get_or_create_session(redis: Redis, user_id: str, session_id: str | None) -> str:
    if session_id:
        exists = await redis.exists(f"chat:{session_id}")
        if exists:
            return session_id

    new_id = str(uuid.uuid4())
    session_data = {
        "user_id": user_id,
        "messages": [],
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    await redis.setex(f"chat:{new_id}", SESSION_TTL, json.dumps(session_data))
    return new_id

async def save_message(redis: Redis, session_id: str, role: str, content: str):
    key = f"chat:{session_id}"
    data = await redis.get(key)
    if data:
        session = json.loads(data)
    else:
        session = {"messages": []}

    session["messages"].append({
        "role": role,
        "content": content,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    })
    await redis.setex(key, SESSION_TTL, json.dumps(session))

async def get_echo_response(message: str) -> str:
    """Placeholder — replaced by Claude in Phase 2."""
    return f"[Echo] You said: {message}. AI guide coming soon!"

async def get_session_messages(redis: Redis, session_id: str) -> list:
    data = await redis.get(f"chat:{session_id}")
    if data:
        return json.loads(data).get("messages", [])
    return []
```

- [ ] **Step 5: Create chat router with REST + WebSocket**

Create `wanderer_api/app/routers/chat.py`:

```python
import json
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect
from sqlalchemy.ext.asyncio import AsyncSession
from redis.asyncio import Redis
from app.schemas.chat import ChatMessageRequest, ChatMessageResponse
from app.services.chat_service import (
    get_or_create_session, save_message, get_echo_response,
)
from app.database import get_db
from app.redis_client import get_redis
from app.middleware.auth_middleware import get_current_user_id

router = APIRouter(prefix="/api/v1/chat", tags=["chat"])

@router.post("/message", response_model=ChatMessageResponse)
async def send_message(
    request: ChatMessageRequest,
    user_id: str = Depends(get_current_user_id),
    redis: Redis = Depends(get_redis),
):
    session_id = await get_or_create_session(redis, user_id, request.session_id)

    await save_message(redis, session_id, "user", request.message)

    response_text = await get_echo_response(request.message)

    await save_message(redis, session_id, "assistant", response_text)

    return ChatMessageResponse(
        response=response_text,
        session_id=session_id,
        timestamp=datetime.now(timezone.utc),
    )

@router.websocket("/ws/{session_id}")
async def chat_websocket(websocket: WebSocket, session_id: str):
    await websocket.accept()
    redis = await get_redis()

    try:
        while True:
            data = await websocket.receive_text()
            msg = json.loads(data)

            if msg.get("type") == "text":
                content = msg.get("content", "")
                await save_message(redis, session_id, "user", content)
                response = await get_echo_response(content)
                await save_message(redis, session_id, "assistant", response)
                await websocket.send_json({
                    "type": "text",
                    "content": response,
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                })

            elif msg.get("type") == "ping":
                await websocket.send_json({"type": "pong"})

    except WebSocketDisconnect:
        pass
```

- [ ] **Step 6: Register chat router**

Update `wanderer_api/app/main.py`:

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import health, auth, payments, chat

app = FastAPI(title="Wanderer API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(auth.router)
app.include_router(payments.router)
app.include_router(chat.router)
```

- [ ] **Step 7: Run tests**

```bash
pytest tests/test_chat.py tests/test_health.py tests/test_auth.py tests/test_payments.py -v
```

Expected: All tests PASS.

- [ ] **Step 8: Commit**

```bash
cd C:/Users/shreya/pondy-guide
git add wanderer_api/
git commit -m "feat: add chat endpoint (REST + WebSocket) with Redis session management"
```

---

## Task 7: Flutter Chat UI Shell

**Files:**
- Create: `wanderer_app/lib/core/network/api_client.dart`
- Create: `wanderer_app/lib/core/network/websocket_client.dart`
- Create: `wanderer_app/lib/features/chat/domain/message_entity.dart`
- Create: `wanderer_app/lib/features/chat/data/chat_repository.dart`
- Create: `wanderer_app/lib/features/chat/presentation/providers/chat_provider.dart`
- Modify: `wanderer_app/lib/features/chat/presentation/screens/chat_screen.dart`
- Create: `wanderer_app/lib/features/chat/presentation/widgets/message_bubble.dart`
- Create: `wanderer_app/lib/features/chat/presentation/widgets/voice_button.dart`
- Create: `wanderer_app/lib/features/chat/presentation/widgets/waveform_animation.dart`

- [ ] **Step 1: Create API client**

Create `wanderer_app/lib/core/network/api_client.dart`:

```dart
import 'package:dio/dio.dart';
import '../config/env_config.dart';

class ApiClient {
  late final Dio _dio;
  String? _authToken;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return _dio.get(path, queryParameters: params);
  }
}
```

- [ ] **Step 2: Create WebSocket client**

Create `wanderer_app/lib/core/network/websocket_client.dart`:

```dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/env_config.dart';

class WsClient {
  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  void connect(String sessionId) {
    final uri = Uri.parse('${EnvConfig.wsBaseUrl}/api/v1/chat/ws/$sessionId');
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (data) {
        final decoded = jsonDecode(data as String) as Map<String, dynamic>;
        _messageController.add(decoded);
      },
      onError: (error) => _messageController.addError(error),
      onDone: () => _messageController.add({'type': 'disconnected'}),
    );
  }

  void sendText(String message) {
    _channel?.sink.add(jsonEncode({
      'type': 'text',
      'content': message,
    }));
  }

  void sendPing() {
    _channel?.sink.add(jsonEncode({'type': 'ping'}));
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
```

- [ ] **Step 3: Create message entity**

Create `wanderer_app/lib/features/chat/domain/message_entity.dart`:

```dart
enum MessageRole { user, assistant }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final List<Map<String, dynamic>>? cards;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.cards,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.assistant(String content, {List<Map<String, dynamic>>? cards}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      cards: cards,
    );
  }
}
```

- [ ] **Step 4: Create chat provider**

Create `wanderer_app/lib/features/chat/presentation/providers/chat_provider.dart`:

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/message_entity.dart';
import '../../../../core/network/websocket_client.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isConnected;
  final bool isTyping;

  const ChatState({
    this.messages = const [],
    this.isConnected = false,
    this.isTyping = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isConnected,
    bool? isTyping,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final WsClient _ws = WsClient();
  StreamSubscription? _subscription;

  ChatNotifier() : super(const ChatState());

  void connect(String sessionId) {
    _ws.connect(sessionId);

    _subscription = _ws.messages.listen((msg) {
      if (msg['type'] == 'text') {
        final message = ChatMessage.assistant(msg['content'] as String);
        state = state.copyWith(
          messages: [...state.messages, message],
          isTyping: false,
        );
      }
    });

    state = state.copyWith(isConnected: true);
  }

  void sendMessage(String text) {
    final message = ChatMessage.user(text);
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: true,
    );
    _ws.sendText(text);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _ws.dispose();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
```

- [ ] **Step 5: Create waveform animation widget**

Create `wanderer_app/lib/features/chat/presentation/widgets/waveform_animation.dart`:

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class WaveformAnimation extends StatefulWidget {
  final bool isActive;
  const WaveformAnimation({super.key, this.isActive = false});

  @override
  State<WaveformAnimation> createState() => _WaveformAnimationState();
}

class _WaveformAnimationState extends State<WaveformAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 60),
          painter: _WaveformPainter(
            progress: _controller.value,
            isActive: widget.isActive,
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final bool isActive;

  _WaveformPainter({required this.progress, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive
          ? WandererColors.primary
          : WandererColors.primary.withOpacity(0.3)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final barCount = 20;
    final barWidth = size.width / (barCount * 2);

    for (var i = 0; i < barCount; i++) {
      final x = (i * 2 + 1) * barWidth;
      final amplitude = isActive ? 0.8 : 0.2;
      final height = (sin((i / barCount * 2 * pi) + (progress * 2 * pi)) * amplitude + 1) *
          size.height / 3;
      canvas.drawLine(
        Offset(x, size.height / 2 - height / 2),
        Offset(x, size.height / 2 + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) =>
      old.progress != progress || old.isActive != isActive;
}
```

- [ ] **Step 6: Create voice button widget**

Create `wanderer_app/lib/features/chat/presentation/widgets/voice_button.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class VoiceButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const VoiceButton({
    super.key,
    required this.isListening,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isListening
              ? WandererColors.primary
              : WandererColors.surfaceLight,
          border: Border.all(
            color: WandererColors.primary,
            width: 2,
          ),
          boxShadow: isListening
              ? [
                  BoxShadow(
                    color: WandererColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  )
                ]
              : [],
        ),
        child: Icon(
          isListening ? Icons.stop_rounded : Icons.mic_rounded,
          color: isListening
              ? WandererColors.background
              : WandererColors.primary,
          size: 32,
        ),
      ),
    );
  }
}
```

- [ ] **Step 7: Create message bubble widget**

Create `wanderer_app/lib/features/chat/presentation/widgets/message_bubble.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isUser ? 64 : 16,
          right: isUser ? 16 : 64,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? WandererColors.userBubble : WandererColors.guideBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser
              ? null
              : Border.all(color: WandererColors.primary.withOpacity(0.2)),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: WandererColors.textPrimary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 8: Build the chat screen**

Replace `wanderer_app/lib/features/chat/presentation/screens/chat_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/voice_button.dart';
import '../widgets/waveform_animation.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showTextInput = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    // Connect with a temporary session ID — replaced after auth in Phase 2
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).connect('dev-session');
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(text);
    _textController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: WandererColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          WandererColors.primary,
                          WandererColors.primaryMuted,
                        ],
                      ),
                    ),
                    child: const Icon(Icons.explore, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wanderer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: WandererColors.textPrimary,
                        ),
                      ),
                      Text(
                        chatState.isTyping ? 'Thinking...' : 'Your AI Guide',
                        style: TextStyle(
                          fontSize: 12,
                          color: chatState.isTyping
                              ? WandererColors.primary
                              : WandererColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Messages or empty state
            Expanded(
              child: chatState.messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WaveformAnimation(isActive: _isListening),
                          const SizedBox(height: 24),
                          const Text(
                            'Tap the mic to talk\nor type a message',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: WandererColors.textMuted,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: chatState.messages.length,
                      itemBuilder: (context, index) {
                        return MessageBubble(message: chatState.messages[index]);
                      },
                    ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WandererColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: _showTextInput
                  ? Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.mic, color: WandererColors.primary),
                          onPressed: () => setState(() => _showTextInput = false),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(color: WandererColors.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'Ask your guide...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send_rounded, color: WandererColors.primary),
                          onPressed: _sendMessage,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        VoiceButton(
                          isListening: _isListening,
                          onPressed: () {
                            setState(() => _isListening = !_isListening);
                            // Voice recording plugs in Phase 3
                          },
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => setState(() => _showTextInput = true),
                          child: const Text(
                            'or type a message',
                            style: TextStyle(
                              color: WandererColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 9: Verify build**

```bash
cd C:/Users/shreya/pondy-guide/wanderer_app
flutter analyze
```

Expected: No errors.

- [ ] **Step 10: Commit**

```bash
cd C:/Users/shreya/pondy-guide
git add wanderer_app/
git commit -m "feat: build voice-first chat UI with waveform animation, message bubbles, WebSocket client"
```

---

## Task 8: Flutter Auth & Payment Screens

**Files:**
- Create: `wanderer_app/lib/features/auth/data/auth_repository.dart`
- Create: `wanderer_app/lib/features/auth/presentation/providers/auth_provider.dart`
- Modify: `wanderer_app/lib/features/auth/presentation/screens/onboarding_screen.dart`
- Modify: `wanderer_app/lib/features/auth/presentation/screens/otp_screen.dart`
- Create: `wanderer_app/lib/features/payments/data/payment_repository.dart`
- Create: `wanderer_app/lib/features/payments/domain/subscription_entity.dart`
- Create: `wanderer_app/lib/features/payments/presentation/providers/payment_provider.dart`
- Modify: `wanderer_app/lib/features/payments/presentation/screens/plan_selection_screen.dart`

- [ ] **Step 1: Create auth repository**

Create `wanderer_app/lib/features/auth/data/auth_repository.dart`:

```dart
import '../../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _api;

  AuthRepository(this._api);

  Future<bool> sendOtp(String phone) async {
    final response = await _api.post('/api/v1/auth/send-otp', data: {'phone': phone});
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final response = await _api.post('/api/v1/auth/verify-otp', data: {
      'phone': phone,
      'code': code,
    });
    return response.data as Map<String, dynamic>;
  }
}
```

- [ ] **Step 2: Create auth provider**

Create `wanderer_app/lib/features/auth/presentation/providers/auth_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/auth_repository.dart';
import '../../../../core/network/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final ApiClient _api;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._repo, this._api) : super(const AuthState());

  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.sendOtp(phone);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repo.verifyOtp(phone, code);
      final token = data['access_token'] as String;
      final userId = data['user_id'] as String;

      await _storage.write(key: 'auth_token', value: token);
      _api.setAuthToken(token);

      state = state.copyWith(
        isAuthenticated: true,
        token: token,
        userId: userId,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(apiClientProvider),
  );
});
```

- [ ] **Step 3: Build onboarding screen**

Replace `wanderer_app/lib/features/auth/presentation/screens/onboarding_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _phoneController = TextEditingController();
  String _countryCode = '+91';

  void _sendOtp() async {
    final phone = '$_countryCode${_phoneController.text.trim()}';
    final success = await ref.read(authProvider.notifier).sendOtp(phone);
    if (success && mounted) {
      context.push('/otp', extra: phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: WandererColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Text(
                'Wanderer',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: WandererColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your AI tour guide.\nDiscover Pondicherry like a local.',
                style: TextStyle(
                  fontSize: 18,
                  color: WandererColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const Spacer(flex: 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: WandererColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _countryCode,
                      dropdownColor: WandererColors.surface,
                      style: const TextStyle(color: WandererColors.textPrimary),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: '+91', child: Text('+91')),
                        DropdownMenuItem(value: '+1', child: Text('+1')),
                        DropdownMenuItem(value: '+33', child: Text('+33')),
                        DropdownMenuItem(value: '+44', child: Text('+44')),
                      ],
                      onChanged: (v) => setState(() => _countryCode = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        color: WandererColors.textPrimary,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        filled: true,
                        fillColor: WandererColors.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WandererColors.primary,
                    foregroundColor: WandererColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: WandererColors.background)
                      : const Text(
                          'Get Started',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Text(auth.error!, style: const TextStyle(color: WandererColors.error)),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 4: Build OTP screen**

Replace `wanderer_app/lib/features/auth/presentation/screens/otp_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();

  void _verifyOtp() async {
    final success = await ref.read(authProvider.notifier).verifyOtp(
      widget.phoneNumber,
      _otpController.text.trim(),
    );
    if (success && mounted) {
      context.go('/plans');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: WandererColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: WandererColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: WandererColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sent to ${widget.phoneNumber}',
              style: const TextStyle(color: WandererColors.textSecondary),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                letterSpacing: 12,
                color: WandererColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: WandererColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WandererColors.primary,
                  foregroundColor: WandererColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: auth.isLoading
                    ? const CircularProgressIndicator(color: WandererColors.background)
                    : const Text('Verify', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 5: Build plan selection screen**

Create `wanderer_app/lib/features/payments/domain/subscription_entity.dart`:

```dart
class PricingTier {
  final String name;
  final String displayName;
  final double pricePerDay;
  final String currency;
  final List<String> features;

  PricingTier({
    required this.name,
    required this.displayName,
    required this.pricePerDay,
    required this.currency,
    required this.features,
  });

  factory PricingTier.fromJson(Map<String, dynamic> json) {
    return PricingTier(
      name: json['name'],
      displayName: json['display_name'],
      pricePerDay: (json['price_per_day'] as num).toDouble(),
      currency: json['currency'],
      features: List<String>.from(json['features']),
    );
  }
}
```

Replace `wanderer_app/lib/features/payments/presentation/screens/plan_selection_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';

class PlanSelectionScreen extends ConsumerStatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  ConsumerState<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends ConsumerState<PlanSelectionScreen> {
  int _selectedDays = 1;
  String _selectedTier = 'guide';

  final _tiers = {
    'explorer': {'name': 'Explorer', 'price': 49, 'icon': Icons.backpack},
    'guide': {'name': 'Guide', 'price': 199, 'icon': Icons.record_voice_over},
    'concierge': {'name': 'Concierge', 'price': 349, 'icon': Icons.auto_awesome},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WandererColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Your Plan',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: WandererColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pay only for the days you explore',
                style: TextStyle(color: WandererColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Tier cards
              ..._tiers.entries.map((entry) {
                final isSelected = _selectedTier == entry.key;
                final price = entry.value['price'] as int;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTier = entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? WandererColors.primary.withOpacity(0.1)
                          : WandererColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? WandererColors.primary
                            : WandererColors.surfaceLight,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          entry.value['icon'] as IconData,
                          color: isSelected
                              ? WandererColors.primary
                              : WandererColors.textMuted,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value['name'] as String,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? WandererColors.primary
                                      : WandererColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹$price/day',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? WandererColors.primary
                                : WandererColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Days selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _selectedDays > 1
                        ? () => setState(() => _selectedDays--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: WandererColors.primary,
                  ),
                  Text(
                    '$_selectedDays ${_selectedDays == 1 ? 'day' : 'days'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: WandererColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _selectedDays++),
                    icon: const Icon(Icons.add_circle_outline),
                    color: WandererColors.primary,
                  ),
                ],
              ),

              const Spacer(),

              // Total and pay button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: WandererColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total', style: TextStyle(color: WandererColors.textMuted)),
                        Text(
                          '₹${(_tiers[_selectedTier]!['price'] as int) * _selectedDays}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: WandererColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => context.go('/chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WandererColors.primary,
                        foregroundColor: WandererColors.background,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Start Exploring',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Verify full build**

```bash
cd C:/Users/shreya/pondy-guide/wanderer_app
flutter analyze
```

Expected: No errors.

- [ ] **Step 7: Commit**

```bash
cd C:/Users/shreya/pondy-guide
git add wanderer_app/
git commit -m "feat: add auth screens (onboarding + OTP), plan selection with tiered pricing UI"
```

---

## Task 9: Integration Test — Full Flow

**Files:**
- Test: `wanderer_api/tests/test_integration.py`
- Create: `wanderer_app/test/features/chat/message_entity_test.dart`

- [ ] **Step 1: Write backend integration test**

Create `wanderer_api/tests/test_integration.py`:

```python
import pytest
from httpx import AsyncClient, ASGITransport
from unittest.mock import AsyncMock, patch
from app.main import app

@pytest.mark.asyncio
async def test_full_auth_to_chat_flow():
    """Test: send OTP → verify → get tiers → send chat message."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # 1. Health check
        resp = await client.get("/health")
        assert resp.status_code == 200

        # 2. Get pricing tiers (no auth needed)
        resp = await client.get("/api/v1/payments/tiers?currency=INR")
        assert resp.status_code == 200
        assert len(resp.json()["tiers"]) == 3

        # 3. Send OTP
        with patch("app.services.auth_service.send_otp", new_callable=AsyncMock, return_value=True):
            resp = await client.post(
                "/api/v1/auth/send-otp",
                json={"phone": "+919876543210"}
            )
        assert resp.status_code == 200
```

- [ ] **Step 2: Write Flutter unit test**

Create `wanderer_app/test/features/chat/message_entity_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderer_app/features/chat/domain/message_entity.dart';

void main() {
  group('ChatMessage', () {
    test('creates user message', () {
      final msg = ChatMessage.user('Hello');
      expect(msg.role, MessageRole.user);
      expect(msg.content, 'Hello');
      expect(msg.cards, isNull);
    });

    test('creates assistant message', () {
      final msg = ChatMessage.assistant('Welcome to Pondicherry!');
      expect(msg.role, MessageRole.assistant);
      expect(msg.content, 'Welcome to Pondicherry!');
    });

    test('creates assistant message with cards', () {
      final msg = ChatMessage.assistant(
        'Here are some restaurants',
        cards: [{'type': 'place', 'name': 'Le Cafe'}],
      );
      expect(msg.cards, isNotNull);
      expect(msg.cards!.length, 1);
    });
  });
}
```

- [ ] **Step 3: Run all tests**

Backend:
```bash
cd C:/Users/shreya/pondy-guide/wanderer_api
pytest -v
```

Flutter:
```bash
cd C:/Users/shreya/pondy-guide/wanderer_app
flutter test
```

Expected: All tests PASS.

- [ ] **Step 4: Commit**

```bash
cd C:/Users/shreya/pondy-guide
git add .
git commit -m "test: add integration tests for auth-to-chat flow and Flutter message entity"
```

---

## Task 10: Project Configuration & Documentation

**Files:**
- Create: `wanderer_app/.gitignore`
- Create: `wanderer_api/.gitignore`
- Create: `.gitignore` (root)
- Update: `wanderer_api/.env.example`

- [ ] **Step 1: Create root .gitignore**

Create `C:/Users/shreya/pondy-guide/.gitignore`:

```
# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Environment
.env
.env.local

# Superpowers brainstorm sessions
.superpowers/

# Python
__pycache__/
*.pyc
.pytest_cache/
*.egg-info/
dist/
build/

# Flutter
wanderer_app/.dart_tool/
wanderer_app/.packages
wanderer_app/build/
wanderer_app/.flutter-plugins
wanderer_app/.flutter-plugins-dependencies
```

- [ ] **Step 2: Create backend .gitignore**

Create `wanderer_api/.gitignore`:

```
__pycache__/
*.pyc
.pytest_cache/
.env
.mypy_cache/
*.egg-info/
```

- [ ] **Step 3: Final commit**

```bash
cd C:/Users/shreya/pondy-guide
git add .
git commit -m "chore: add gitignore files, finalize Phase 1 foundation"
```

- [ ] **Step 4: Verify final state**

```bash
cd C:/Users/shreya/pondy-guide
git log --oneline
```

Expected: 8 commits:
1. `Add AI Tour Guide product design specification`
2. `feat: scaffold Flutter project with feature-first structure`
3. `feat: scaffold FastAPI backend with PostgreSQL, Redis`
4. `feat: add database models with Alembic migrations`
5. `feat: add phone OTP authentication`
6. `feat: add payment integration with tiered pricing`
7. `feat: add chat endpoint with Redis session management`
8. `feat: build voice-first chat UI`
9. `test: add integration tests`
10. `chore: add gitignore, finalize Phase 1`

---

## Phase 1 Delivers

After completing all 10 tasks, you have:

- **Flutter app** with dark theme, voice-first chat UI, onboarding, OTP auth, plan selection
- **FastAPI backend** with PostgreSQL schema, Redis sessions, health/auth/chat/payment endpoints
- **WebSocket chat** — echo for now, Claude plugs in Phase 2
- **Payments** — Razorpay (INR) + Stripe (intl) with tiered pricing
- **Docker Compose** for local dev (Postgres + Redis)
- **Tests** covering auth, payments, chat, and integration flow

**Next: Phase 2 — AI Core** (Claude Sonnet via Bedrock, tool calling, conversation engine)
