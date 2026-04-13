# AI Tour Guide — Product Design Specification

**Author:** Giridhar Kannabiran
**Date:** 2026-04-13
**Status:** Draft

---

## 1. Vision

An AI-native, voice-first personal tour guide app that replaces human tour guides with an intelligent, multilingual AI companion. Starting with Pondicherry, expanding to cities across India.

The AI IS the app — no traditional screens, no tabs, no menus. Users talk to their guide and it handles everything: recommendations, bookings, navigation, safety, and trip memories.

**Positioning:** 5-8x cheaper than a human guide, available 24/7, speaks 4+ languages, knows every street, restaurant, and hidden gem.

---

## 2. Target Audience

- **Domestic tourists** — Indians visiting Pondy (primarily Chennai weekend travelers). Hindi/Tamil/English, UPI payments, budget to mid-range.
- **International tourists** — Foreigners visiting India. English/French-first, forex-friendly, seeking curated experiences.
- The app adapts to both — language auto-detection, dual currency pricing, culturally-aware recommendations.

---

## 3. Core Experience

### 3.1 AI-Native Interface

The app opens to a single screen: the AI guide, ready to talk.

- **Full-screen dark canvas** with subtle animated waveform (the guide's "presence")
- **Mic button** at the bottom — tap to talk (primary interaction)
- **Text input** as secondary — swipe up or tap keyboard icon
- **Rich media cards** float up from the bottom during conversation:
  - Place cards — photo, name, rating, distance, tap to expand
  - Itinerary cards — timeline view of your day
  - Map snippets — inline mini-map showing route or location
  - Booking confirmations — status of reservations
  - Photo carousels — "here are the top 5 sunset spots"
- **Persistent conversation** — scroll up to see full history with cards and recommendations
- **Proactive intelligence** — the guide initiates based on context:
  - Time-based: "Good morning! 34C today — perfect for the beach"
  - Location-based: "You're near Promenade — the sunset is in 20 minutes"
  - Itinerary-based: "Dinner at Villa Shanti in 2 hours — want suggestions for nearby activities?"

### 3.2 AI Guide Persona & Voice

The guide is a character, not a generic bot.

**Persona:**
- Distinct name (chosen during onboarding or user picks from options)
- Custom ElevenLabs voice — warm, friendly, confident
- Voice options: Male/Female/Neutral, regional accent options (soft Tamil-English, French-accented English, neutral international)

**Adaptive tone:**
- Casual with backpackers: "Skip the tourist traps — let me show you where locals actually eat"
- Refined with luxury travelers: "I'd recommend the degustation menu at Palais de Mahe"
- Informative at heritage sites: "This temple dates to the 8th century Pallava dynasty..."

**Multilingual (from day 1):**
- English, Tamil, Hindi, French + auto-detect
- Seamless mid-sentence language switching
- Manual override in settings

### 3.3 Onboarding (Conversational, Not Forms)

No signup forms. The guide asks:

1. "Hey! I'm your guide to Pondicherry. What brings you here?" (trip purpose)
2. "How many days are you staying?" (trip length / billing)
3. "Traveling solo, couple, family, or friends?" (recommendation context)
4. "What's your vibe — budget explorer, comfort seeker, or luxury all the way?" (price range)
5. "Any food preferences I should know about?" (dietary restrictions)

Authentication: phone OTP or social login (Google/Apple), captured naturally during payment.

---

## 4. Features & Capabilities

All features are accessed through conversation — no menus, no tabs.

### 4.1 Discovery & Recommendations

- Personalized restaurant suggestions with photos, ratings, price range
- Ranked beaches by time of day, crowd level, activity type
- Community-sourced hidden gems and secret spots
- Events, festivals, markets, live music calendar
- Deep history narrations with photos and audio

**Categories (14+):** Restaurants, Hotels, Sightseeing, Temples, Beaches, Cafes, Nightlife, Shopping, Experiences (scuba, surfing, cooking classes), Transport, Events/Festivals, Local History, Photo Spots, Hidden Gems

### 4.2 Itinerary Building

- "I have 3 days, plan my trip" — full day-by-day plan with timings, travel time, meal breaks
- Real-time rearrangement: "Do the temple first"
- Weather-aware pivoting: "It's raining, what now?"
- Morning push notification: "Here's your day — ready to start?"

### 4.3 Concierge Booking (No Commission)

- Restaurant booking via WhatsApp Business API + Twilio calling
- Hotel booking with **price comparison engine** — AI queries Booking.com, Goibibo, MakeMyTrip, Agoda APIs simultaneously, compares rates for the same property, and books the cheapest option. Shows the user: "Found this hotel on 4 platforms — Goibibo has the best rate at X." Direct WhatsApp outreach as fallback for unlisted properties.
- Experience booking — scuba, surfing, cooking classes, heritage walks
- Cancellation handling through conversation
- AI makes the booking for you — true concierge, not a link-out

### 4.4 Navigation & Transport

- Route suggestions with local transport options (auto, bike rental, ferry)
- Local pricing context: "A shared auto should cost ~20, don't pay more than 50"
- Real-time "am I being overcharged?" check

### 4.5 Safety & Travel Companion

- **SOS button** — always accessible, even from lock screen
- Nearest hospital/police with directions
- **Document vault** — encrypted passport/visa/insurance copies with biometric lock
- Embassy contacts for international tourists
- Real-time alerts — weather, beach currents, local advisories
- Travel insurance integration — buy/claim through conversation

### 4.6 Community & Social

- Voice reviews after visits — AI transcribes and posts
- Community reviews surfaced conversationally
- Local contributor tips woven into AI knowledge
- Community-suggested photo spots

### 4.7 Smart Additions

- **Camera AI** — point at a building, dish, or sign. AI identifies and tells the story. Uses on-device ML (Google ML Kit) + Claude for context.
- **Mood-aware suggestions** — "I'm tired" triggers low-effort nearby options. "I'm bored" activates adventure mode.
- **Trip budget tracker** — tracks spending, warns before overshoot, suggests cheaper alternatives for remaining days.
- **Trip memories** — end-of-trip compiled journal: photos, places, voice highlights, map of everywhere visited. Exportable as reel or PDF.
- **Group sync** — share guide session with travel companions. Shared itinerary, vote on restaurants, split bills via UPI.
- **Return traveler intelligence** — AI remembers returning users. New places since last visit, updated recommendations, "welcome back" experience.
- **Local language coach** — key phrases with pronunciation, contextual to upcoming activity (ordering food, bargaining, greeting).

---

## 5. Technical Architecture

### 5.1 Client — Flutter (iOS + Android)

- Single Dart codebase for iOS and Android
- Voice: device mic → streamed to Deepgram WebSocket (real-time STT)
- TTS: ElevenLabs streaming for guide voice playback
- Maps: MapLibre or Mapbox for inline map snippets
- Camera: Flutter camera plugin + Google ML Kit (on-device object/text recognition)
- Offline: SQLite + Hive for cached itineraries, place data, map tiles
- Background location services for proactive suggestions
- Push notifications via Firebase Cloud Messaging

### 5.2 Backend — API Layer

- **Compute:** EC2 (no SST/serverless)
- **Database:** PostgreSQL on RDS — users, trips, bookings, reviews, places
- **Cache:** Redis — session cache, conversation context, rate limiting
- **Storage:** S3 — photos, audio files, document vault (AES-256 encrypted)
- **API framework:** Node.js/Express or FastAPI (Python)
- **Booking integration:** Twilio (calling), WhatsApp Business API, partner hotel APIs

### 5.3 AI Orchestration Layer

- **Conversation engine:** Claude Sonnet 4.6 via AWS Bedrock
- **System prompt context:** user profile, location, time, weather, active itinerary, preferences, conversation history
- **Prompt caching:** 5-minute TTL — system prompt + user context cached (~90% input token savings)
- **Tool use / function calling:** AI calls internal APIs for:
  - Place search & filtering
  - Booking actions (restaurant, hotel, experience)
  - Weather lookup
  - Navigation/routing
  - Budget tracking
  - Itinerary CRUD
  - SOS/emergency services
- **STT:** Deepgram Nova-2 — streaming via WebSocket
- **TTS:** ElevenLabs — streaming with custom cloned voice
- **Language detection:** auto-routes to appropriate system prompt variant
- **Cost-optimized model routing:**
  - Explorer tier → GPT-4.1-nano
  - Guide tier → GPT-4.1-mini
  - Concierge tier → Claude Sonnet 4.6

### 5.4 Data Pipeline

- **Seed:** Google Places API for all categories
- **Enrichment:** community contributions moderated by AI before publishing
- **AI synthesis:** place data enriched over time (synthesizing reviews, adding context, updating info)
- **Offline packs:** pre-compiled city bundles (place data + map tiles + pre-generated audio for top 50 spots)
- **Smart pre-caching:** based on itinerary + location, pre-cache likely-needed content

### 5.5 Security & Compliance

- End-to-end encryption for document vault
- Biometric lock (Face ID / fingerprint) for sensitive data
- GDPR compliant (international tourists)
- India DPDP Act compliant
- Conversation data: retained for trip duration + 30 days, then anonymized
- Payment: Razorpay (domestic UPI/cards) + Stripe (international)

---

## 6. Monetization

### 6.1 Pricing — Pay-Per-Day, Tiered

| Tier | India | International | Includes |
|------|-------|---------------|----------|
| **Explorer** | 49/day | $1.99/day | Text chat, recommendations, itinerary, offline cache |
| **Guide** | 199/day | $4.99/day | + Voice conversation, proactive alerts, navigation |
| **Concierge** | 349/day | $7.99/day | + AI booking, premium voice, trip memories, group sync, document vault, camera AI |

### 6.2 Multi-Day Packs

- 3-day Concierge: 899 (300/day, save 148)
- 7-day Guide: 999 (143/day, save 394)
- Weekend Concierge (Fri-Sun): 899

### 6.3 Revenue Model

**Pure pay-per-day. No commissions. No ads. No sponsored placements.**

Unbiased recommendations — the AI always recommends the best option, never the one that pays. This is a trust differentiator.

Bookings are a free service for the user, not a revenue stream.

### 6.4 Unit Economics

| Tier | Revenue | AI Cost | Voice Cost | Infra | Total Cost | Margin |
|------|---------|---------|------------|-------|------------|--------|
| Explorer | 49 | 3 | 0 | 1 | ~3 | 94% |
| Guide | 199 | 5 | 30 | 3 | ~35 | 82% |
| Concierge | 349 | 19 | 55 | 8 | ~85 | 76% |

### 6.5 Break-Even

- Monthly fixed costs: ~75,000 (EC2, RDS, Redis, S3, ElevenLabs, misc)
- Break-even: **~13 paying users/day** at blended 200 average
- Achievable within first 1-2 months in Pondicherry

---

## 7. Launch Strategy

### Phase 1 — Pondicherry (v1)

- Seed data: Google Places API for 14+ categories
- Manually curate top 100 spots with rich descriptions, photos, insider tips
- Partner: 20-30 restaurants, 10-15 hotels for concierge booking
- Recruit: 10-15 local contributors (food bloggers, history buffs, auto drivers)
- Target: Chennai weekend travelers (3hr drive) + international tourists in French Quarter
- Growth: "Try free for 2 hours" trial, trip memory reels shared on social, hotel partnerships (value-add, not commission), travel influencer seeding

### Phase 2 — Nearby Destinations

- Mahabalipuram, Auroville, Chidambaram — natural day-trip extensions
- Seamless experience when tourists take day trips from Pondy
- Same pipeline, new city packs

### Phase 3 — Top Tourist Cities

- Goa, Jaipur, Varanasi, Kerala — high international tourist volume
- Each city: curated seed data + local contributor network + partner restaurants/hotels
- City-specific guide persona and voice options

---

## 8. Success Metrics

- **Activation:** % of downloads → first paid day
- **Engagement:** conversations per user per day, voice vs text ratio
- **Retention:** return usage on multi-day trips, return travelers
- **Revenue:** daily paying users, blended ARPU, break-even timeline
- **NPS:** post-trip survey score
- **Community:** reviews contributed, local tips submitted

---

## 9. Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| AI hallucination (wrong hours, closed places) | Community verification loop + Google Places API real-time checks |
| Voice quality in noisy environments | Noise cancellation on-device, fallback to text, push-to-talk mode |
| Concierge booking failures | Small outsourced support team (2-3 people, Pondy-based) for failed bookings in v1, automated retry logic, escalation to human within 5 minutes |
| Spotty internet in tourist areas | Smart pre-caching + offline city packs |
| High voice API costs at scale | Monitor per-user costs, adjust tier pricing, negotiate volume discounts |
| Data freshness (restaurant closed, menu changed) | Community flagging + periodic Google Places sync + AI cross-referencing |
| Multi-language TTS quality | Test ElevenLabs quality per language, fallback to OpenAI TTS for non-English if needed |

---

## 10. Out of Scope (v1)

- Web app / desktop companion
- Social features beyond group sync (no social feed, no followers)
- AR overlays (camera AI is recognition only, not augmented reality)
- Marketplace for local guides/vendors
- Loyalty/rewards program
- Integration with airline/train booking
