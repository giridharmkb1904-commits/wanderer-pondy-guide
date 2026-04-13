"""
Wanderer App - Illustrative Product Story PDF Generator
Creates a visually rich, magazine-style product story using ReportLab.
"""

from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm, inch
from reportlab.lib.colors import HexColor, white, black, Color
from reportlab.pdfgen import canvas
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_RIGHT, TA_JUSTIFY
from reportlab.platypus import Paragraph, Frame
from reportlab.lib.styles import ParagraphStyle
import math
import os

# ─── Brand Colors ───
TEAL        = HexColor("#3ECFB4")
TEAL_DARK   = HexColor("#2A9D8F")
AMBER       = HexColor("#F59E0B")
BG_DARK     = HexColor("#0A0A0C")
SURFACE     = HexColor("#141418")
SURFACE_LT  = HexColor("#1E1E24")
TEXT_PRI    = HexColor("#F5F5F5")
TEXT_SEC    = HexColor("#9CA3AF")
TEXT_MUTED  = HexColor("#6B7280")
USER_BUBBLE = HexColor("#1E3A5F")
GUIDE_BUBBLE= HexColor("#1A1A22")
ERROR_RED   = HexColor("#EF4444")
SUCCESS_GRN = HexColor("#22C55E")
TEAL_10     = HexColor("#0D2B26")
TEAL_20     = HexColor("#153D36")

W, H = A4
OUTPUT = os.path.expanduser("~/Desktop/Wanderer_Product_Story.pdf")


def draw_gradient_rect(c, x, y, w, h, color1, color2, steps=60):
    """Draw a vertical gradient rectangle."""
    step_h = h / steps
    for i in range(steps):
        ratio = i / steps
        r = color1.red + (color2.red - color1.red) * ratio
        g = color1.green + (color2.green - color1.green) * ratio
        b = color1.blue + (color2.blue - color1.blue) * ratio
        c.setFillColor(Color(r, g, b))
        c.rect(x, y + h - (i + 1) * step_h, w, step_h + 0.5, fill=1, stroke=0)


def draw_circle_pattern(c, cx, cy, max_r, color, alpha=0.08):
    """Draw concentric circles as a decorative pattern."""
    for i in range(1, 8):
        r = max_r * i / 7
        c.setStrokeColor(Color(color.red, color.green, color.blue, alpha))
        c.setLineWidth(0.5)
        c.circle(cx, cy, r, fill=0, stroke=1)


def draw_dots_grid(c, x, y, cols, rows, spacing, color, alpha=0.15):
    """Draw a decorative dot grid."""
    c.setFillColor(Color(color.red, color.green, color.blue, alpha))
    for row in range(rows):
        for col in range(cols):
            c.circle(x + col * spacing, y - row * spacing, 1.2, fill=1, stroke=0)


def draw_phone_mockup(c, cx, cy, w_phone, h_phone, content_func=None):
    """Draw a stylized phone mockup frame."""
    rx, ry = 12, 12
    # Phone body shadow
    c.setFillColor(Color(0, 0, 0, 0.3))
    c.roundRect(cx - w_phone/2 + 3, cy - h_phone/2 - 3, w_phone, h_phone, rx, fill=1, stroke=0)
    # Phone body
    c.setFillColor(SURFACE)
    c.setStrokeColor(HexColor("#2A2A30"))
    c.setLineWidth(1.5)
    c.roundRect(cx - w_phone/2, cy - h_phone/2, w_phone, h_phone, rx, fill=1, stroke=1)
    # Screen area
    margin = 4
    c.setFillColor(BG_DARK)
    c.roundRect(cx - w_phone/2 + margin, cy - h_phone/2 + margin,
                w_phone - 2*margin, h_phone - 2*margin, rx-2, fill=1, stroke=0)
    # Notch
    notch_w = 40
    c.setFillColor(SURFACE)
    c.roundRect(cx - notch_w/2, cy + h_phone/2 - 14, notch_w, 10, 4, fill=1, stroke=0)
    # Content
    if content_func:
        content_func(c, cx, cy, w_phone, h_phone)


def draw_wave(c, y_base, amplitude, color, alpha=0.15):
    """Draw a decorative wave across the page."""
    p = c.beginPath()
    p.moveTo(0, y_base)
    for x in range(0, int(W) + 5, 3):
        y = y_base + amplitude * math.sin(x * 0.015)
        p.lineTo(x, y)
    p.lineTo(W, 0)
    p.lineTo(0, 0)
    p.close()
    c.setFillColor(Color(color.red, color.green, color.blue, alpha))
    c.drawPath(p, fill=1, stroke=0)


def draw_icon_compass(c, cx, cy, size):
    """Draw a compass icon."""
    c.setStrokeColor(TEAL)
    c.setLineWidth(2)
    c.circle(cx, cy, size, fill=0, stroke=1)
    # N-S needle
    c.setFillColor(TEAL)
    p = c.beginPath()
    p.moveTo(cx, cy + size * 0.7)
    p.lineTo(cx - size * 0.15, cy)
    p.lineTo(cx + size * 0.15, cy)
    p.close()
    c.drawPath(p, fill=1, stroke=0)
    c.setFillColor(AMBER)
    p = c.beginPath()
    p.moveTo(cx, cy - size * 0.7)
    p.lineTo(cx - size * 0.15, cy)
    p.lineTo(cx + size * 0.15, cy)
    p.close()
    c.drawPath(p, fill=1, stroke=0)
    # Tick marks
    c.setStrokeColor(TEXT_SEC)
    c.setLineWidth(1)
    for angle in [0, 90, 180, 270]:
        rad = math.radians(angle)
        x1 = cx + size * 0.85 * math.cos(rad)
        y1 = cy + size * 0.85 * math.sin(rad)
        x2 = cx + size * math.cos(rad)
        y2 = cy + size * math.sin(rad)
        c.line(x1, y1, x2, y2)


def draw_icon_chat(c, cx, cy, size):
    """Draw a chat bubble icon."""
    c.setFillColor(TEAL)
    c.roundRect(cx - size, cy - size * 0.6, size * 2, size * 1.4, 6, fill=1, stroke=0)
    # Tail
    p = c.beginPath()
    p.moveTo(cx - size * 0.3, cy - size * 0.6)
    p.lineTo(cx - size * 0.6, cy - size)
    p.lineTo(cx + size * 0.1, cy - size * 0.6)
    p.close()
    c.drawPath(p, fill=1, stroke=0)
    # Dots
    c.setFillColor(BG_DARK)
    for dx in [-size * 0.4, 0, size * 0.4]:
        c.circle(cx + dx, cy + size * 0.1, 2, fill=1, stroke=0)


def draw_icon_map_pin(c, cx, cy, size):
    """Draw a map pin icon."""
    c.setFillColor(AMBER)
    # Pin body
    p = c.beginPath()
    p.moveTo(cx, cy - size)
    p.curveTo(cx - size * 0.8, cy - size * 0.3,
              cx - size * 0.8, cy + size * 0.5,
              cx, cy + size)
    p.curveTo(cx + size * 0.8, cy + size * 0.5,
              cx + size * 0.8, cy - size * 0.3,
              cx, cy - size)
    p.close()
    c.drawPath(p, fill=1, stroke=0)
    # Inner circle
    c.setFillColor(BG_DARK)
    c.circle(cx, cy + size * 0.15, size * 0.3, fill=1, stroke=0)


def draw_icon_shield(c, cx, cy, size):
    """Draw a shield/secure icon."""
    c.setFillColor(SUCCESS_GRN)
    p = c.beginPath()
    p.moveTo(cx, cy + size)
    p.lineTo(cx - size * 0.8, cy + size * 0.5)
    p.lineTo(cx - size * 0.8, cy - size * 0.3)
    p.lineTo(cx, cy - size)
    p.lineTo(cx + size * 0.8, cy - size * 0.3)
    p.lineTo(cx + size * 0.8, cy + size * 0.5)
    p.close()
    c.drawPath(p, fill=1, stroke=0)
    # Checkmark
    c.setStrokeColor(BG_DARK)
    c.setLineWidth(2)
    c.line(cx - size * 0.3, cy + size * 0.1, cx - size * 0.05, cy - size * 0.2)
    c.line(cx - size * 0.05, cy - size * 0.2, cx + size * 0.35, cy + size * 0.35)


def make_style(name, font="Helvetica", size=10, color=TEXT_PRI, align=TA_LEFT, leading=None, space_after=0):
    """Create a paragraph style."""
    return ParagraphStyle(
        name, fontName=font, fontSize=size, textColor=color,
        alignment=align, leading=leading or size * 1.4, spaceAfter=space_after
    )


def draw_text_block(c, text, x, y, w, style, max_h=500):
    """Draw a text block using Paragraph for word wrapping."""
    p = Paragraph(text, style)
    pw, ph = p.wrap(w, max_h)
    p.drawOn(c, x, y - ph)
    return ph


# ════════════════════════════════════════════════════
# PAGE 1 — COVER
# ════════════════════════════════════════════════════
def page_cover(c):
    # Full page dark background
    c.setFillColor(BG_DARK)
    c.rect(0, 0, W, H, fill=1, stroke=0)

    # Gradient overlay at top
    draw_gradient_rect(c, 0, H * 0.55, W, H * 0.45, TEAL_10, BG_DARK)

    # Decorative concentric circles
    draw_circle_pattern(c, W * 0.85, H * 0.8, 180, TEAL, 0.06)
    draw_circle_pattern(c, W * 0.15, H * 0.2, 120, AMBER, 0.04)

    # Decorative dots
    draw_dots_grid(c, 40, H - 40, 6, 6, 12, TEAL, 0.12)
    draw_dots_grid(c, W - 120, 140, 6, 6, 12, AMBER, 0.08)

    # Top wave
    draw_wave(c, H * 0.35, 15, TEAL, 0.06)
    draw_wave(c, H * 0.33, 10, TEAL_DARK, 0.04)

    # Badge: "Product Story"
    badge_w, badge_h = 130, 26
    c.setFillColor(Color(TEAL.red, TEAL.green, TEAL.blue, 0.15))
    c.roundRect(W/2 - badge_w/2, H - 120, badge_w, badge_h, 13, fill=1, stroke=0)
    c.setFillColor(TEAL)
    c.setFont("Helvetica", 10)
    c.drawCentredString(W/2, H - 112, "PRODUCT STORY")

    # Main title
    c.setFont("Helvetica-Bold", 56)
    c.setFillColor(TEXT_PRI)
    c.drawCentredString(W/2, H - 185, "Wanderer")

    # Compass icon
    draw_icon_compass(c, W/2, H - 250, 28)

    # Subtitle
    c.setFont("Helvetica", 18)
    c.setFillColor(TEAL)
    c.drawCentredString(W/2, H - 310, "Your AI Tour Guide")

    # Tagline
    style = make_style("tagline", size=13, color=TEXT_SEC, align=TA_CENTER, leading=20)
    draw_text_block(c, "Discover Pondicherry like never before. An intelligent<br/>"
                       "companion that knows every lane, every story, every flavor.",
                    W/2 - 180, H - 340, 360, style)

    # Three feature pills
    pills = [
        ("AI-Powered", TEAL),
        ("Real-Time", AMBER),
        ("Personalized", TEAL_DARK),
    ]
    pill_w = 110
    total = len(pills) * pill_w + (len(pills) - 1) * 15
    start_x = W/2 - total/2
    for i, (label, color) in enumerate(pills):
        px = start_x + i * (pill_w + 15)
        py = H - 425
        c.setFillColor(Color(color.red, color.green, color.blue, 0.15))
        c.roundRect(px, py, pill_w, 28, 14, fill=1, stroke=0)
        c.setStrokeColor(Color(color.red, color.green, color.blue, 0.3))
        c.setLineWidth(0.5)
        c.roundRect(px, py, pill_w, 28, 14, fill=0, stroke=1)
        c.setFont("Helvetica", 9)
        c.setFillColor(color)
        c.drawCentredString(px + pill_w/2, py + 9, label.upper())

    # Phone mockup on cover
    def cover_phone_content(c, cx, cy, pw, ph):
        # Status bar
        c.setFont("Helvetica", 7)
        c.setFillColor(TEXT_SEC)
        c.drawString(cx - pw/2 + 12, cy + ph/2 - 20, "9:41")
        # App header
        c.setFont("Helvetica-Bold", 11)
        c.setFillColor(TEAL)
        c.drawCentredString(cx, cy + ph/2 - 42, "Wanderer")
        c.setFont("Helvetica", 7)
        c.setFillColor(TEXT_MUTED)
        c.drawCentredString(cx, cy + ph/2 - 55, "AI Tour Guide")
        # Divider
        c.setStrokeColor(SURFACE_LT)
        c.setLineWidth(0.5)
        c.line(cx - pw/2 + 10, cy + ph/2 - 62, cx + pw/2 - 10, cy + ph/2 - 62)
        # Guide message
        c.setFillColor(GUIDE_BUBBLE)
        c.roundRect(cx - pw/2 + 10, cy + ph/2 - 110, pw * 0.7, 40, 8, fill=1, stroke=0)
        c.setFont("Helvetica", 7)
        c.setFillColor(TEXT_PRI)
        c.drawString(cx - pw/2 + 18, cy + ph/2 - 82, "Welcome to Pondy!")
        c.setFillColor(TEXT_SEC)
        c.drawString(cx - pw/2 + 18, cy + ph/2 - 95, "Where would you like to")
        c.drawString(cx - pw/2 + 18, cy + ph/2 - 105, "explore first?")
        # User message
        c.setFillColor(USER_BUBBLE)
        c.roundRect(cx + pw/2 - 10 - pw * 0.6, cy + ph/2 - 155, pw * 0.6, 30, 8, fill=1, stroke=0)
        c.setFont("Helvetica", 7)
        c.setFillColor(TEXT_PRI)
        c.drawString(cx + pw/2 - 8 - pw * 0.55, cy + ph/2 - 140, "Show me hidden gems!")
        # Guide response
        c.setFillColor(GUIDE_BUBBLE)
        c.roundRect(cx - pw/2 + 10, cy + ph/2 - 210, pw * 0.75, 45, 8, fill=1, stroke=0)
        c.setFont("Helvetica", 7)
        c.setFillColor(TEAL)
        c.drawString(cx - pw/2 + 18, cy + ph/2 - 175, "Great choice!")
        c.setFillColor(TEXT_SEC)
        c.drawString(cx - pw/2 + 18, cy + ph/2 - 188, "Try Aurobindo Ashram's")
        c.drawString(cx - pw/2 + 18, cy + ph/2 - 200, "secret garden entrance...")
        # Input bar
        c.setFillColor(SURFACE_LT)
        c.roundRect(cx - pw/2 + 8, cy - ph/2 + 10, pw - 16, 28, 14, fill=1, stroke=0)
        c.setFont("Helvetica", 7)
        c.setFillColor(TEXT_MUTED)
        c.drawString(cx - pw/2 + 22, cy - ph/2 + 20, "Ask your guide...")
        # Send button
        c.setFillColor(TEAL)
        c.circle(cx + pw/2 - 24, cy - ph/2 + 24, 10, fill=1, stroke=0)
        c.setFillColor(BG_DARK)
        c.setFont("Helvetica-Bold", 8)
        c.drawCentredString(cx + pw/2 - 24, cy - ph/2 + 21, ">")

    draw_phone_mockup(c, W/2, H * 0.32, 130, 250, cover_phone_content)

    # Bottom bar
    c.setFillColor(SURFACE)
    c.rect(0, 0, W, 45, fill=1, stroke=0)
    c.setStrokeColor(TEAL_DARK)
    c.setLineWidth(0.5)
    c.line(0, 45, W, 45)
    c.setFont("Helvetica", 8)
    c.setFillColor(TEXT_MUTED)
    c.drawString(30, 18, "Wanderer App  |  Pondicherry, India")
    c.drawRightString(W - 30, 18, "Built with Flutter & AI")


# ════════════════════════════════════════════════════
# PAGE 2 — THE PROBLEM & VISION
# ════════════════════════════════════════════════════
def page_problem_vision(c):
    c.setFillColor(BG_DARK)
    c.rect(0, 0, W, H, fill=1, stroke=0)

    # Top accent bar
    draw_gradient_rect(c, 0, H - 8, W, 8, TEAL, TEAL_DARK)

    # Section number
    c.setFont("Helvetica-Bold", 72)
    c.setFillColor(Color(TEAL.red, TEAL.green, TEAL.blue, 0.08))
    c.drawString(30, H - 95, "01")

    # Title
    c.setFont("Helvetica-Bold", 28)
    c.setFillColor(TEXT_PRI)
    c.drawString(30, H - 80, "The Problem")

    # Accent line
    c.setStrokeColor(TEAL)
    c.setLineWidth(3)
    c.line(30, H - 90, 130, H - 90)

    # Problem cards
    problems = [
        ("Generic Guides", "Travel apps offer the same cookie-cutter itineraries to every tourist. "
         "The real Pondicherry stays hidden behind a wall of sponsored listings and outdated reviews.",
         ERROR_RED),
        ("Language Barriers", "Navigating French Quarter streets, Tamil neighborhoods, and local markets "
         "becomes overwhelming without a companion who speaks your language and knows the culture.",
         AMBER),
        ("Information Overload", "Tourists drown in 50-tab browser sessions, conflicting blog posts, "
         "and social media noise. No single source gives real-time, contextual guidance.",
         HexColor("#8B5CF6")),
    ]

    card_y = H - 130
    for title, desc, accent in problems:
        card_h = 90
        # Card bg
        c.setFillColor(SURFACE)
        c.roundRect(30, card_y - card_h, W - 60, card_h, 8, fill=1, stroke=0)
        # Accent left bar
        c.setFillColor(accent)
        c.roundRect(30, card_y - card_h, 4, card_h, 2, fill=1, stroke=0)
        # Title
        c.setFont("Helvetica-Bold", 12)
        c.setFillColor(TEXT_PRI)
        c.drawString(50, card_y - 22, title)
        # Desc
        style = make_style("prob", size=9, color=TEXT_SEC, leading=13)
        draw_text_block(c, desc, 50, card_y - 32, W - 120, style)
        card_y -= card_h + 12

    # Vision section
    vision_y = card_y - 30
    c.setFont("Helvetica-Bold", 72)
    c.setFillColor(Color(AMBER.red, AMBER.green, AMBER.blue, 0.08))
    c.drawString(30, vision_y + 15, "02")

    c.setFont("Helvetica-Bold", 28)
    c.setFillColor(TEXT_PRI)
    c.drawString(30, vision_y + 28, "The Vision")
    c.setStrokeColor(AMBER)
    c.setLineWidth(3)
    c.line(30, vision_y + 18, 130, vision_y + 18)

    # Vision statement box
    c.setFillColor(TEAL_10)
    c.setStrokeColor(Color(TEAL.red, TEAL.green, TEAL.blue, 0.2))
    c.setLineWidth(1)
    c.roundRect(30, vision_y - 110, W - 60, 105, 10, fill=1, stroke=1)

    draw_icon_compass(c, 65, vision_y - 20, 16)

    style_vision = make_style("vision", font="Helvetica-Bold", size=14, color=TEAL, leading=20, align=TA_LEFT)
    draw_text_block(c, "\"What if every traveler had a brilliant local friend<br/>"
                       "who knew every hidden lane, every untold story,<br/>"
                       "and was available 24/7?\"",
                    90, vision_y - 18, W - 150, style_vision)

    style_vdesc = make_style("vdesc", size=10, color=TEXT_SEC, leading=15)
    draw_text_block(c, "Wanderer transforms your phone into an omniscient, always-available tour "
                       "companion. Powered by AI that has ingested decades of Pondicherry history, "
                       "culture, and local knowledge \u2014 it doesn\u2019t just answer questions, it "
                       "anticipates your curiosity.",
                    90, vision_y - 68, W - 150, style_vdesc)

    # Bottom stats bar
    stats_y = 70
    c.setFillColor(SURFACE)
    c.roundRect(30, stats_y, W - 60, 60, 8, fill=1, stroke=0)

    stat_items = [
        ("24/7", "Always Available"),
        ("AI", "Powered Guidance"),
        ("Real-time", "Local Intelligence"),
        ("Multi", "Language Support"),
    ]
    stat_w = (W - 60) / len(stat_items)
    for i, (val, label) in enumerate(stat_items):
        sx = 30 + i * stat_w + stat_w / 2
        c.setFont("Helvetica-Bold", 18)
        c.setFillColor(TEAL)
        c.drawCentredString(sx, stats_y + 35, val)
        c.setFont("Helvetica", 8)
        c.setFillColor(TEXT_MUTED)
        c.drawCentredString(sx, stats_y + 18, label)
        # Divider
        if i < len(stat_items) - 1:
            c.setStrokeColor(SURFACE_LT)
            c.setLineWidth(0.5)
            c.line(30 + (i + 1) * stat_w, stats_y + 10, 30 + (i + 1) * stat_w, stats_y + 50)

    # Page number
    c.setFont("Helvetica", 8)
    c.setFillColor(TEXT_MUTED)
    c.drawRightString(W - 30, 20, "02")


# ════════════════════════════════════════════════════
# PAGE 3 — USER JOURNEY
# ════════════════════════════════════════════════════
def page_user_journey(c):
    c.setFillColor(BG_DARK)
    c.rect(0, 0, W, H, fill=1, stroke=0)

    draw_gradient_rect(c, 0, H - 8, W, 8, AMBER, TEAL)

    # Section number & title
    c.setFont("Helvetica-Bold", 72)
    c.setFillColor(Color(TEAL.red, TEAL.green, TEAL.blue, 0.08))
    c.drawString(30, H - 95, "03")
    c.setFont("Helvetica-Bold", 28)
    c.setFillColor(TEXT_PRI)
    c.drawString(30, H - 80, "User Journey")
    c.setStrokeColor(TEAL)
    c.setLineWidth(3)
    c.line(30, H - 90, 160, H - 90)

    # Journey steps
    steps = [
        {
            "num": "01",
            "title": "Welcome & Onboard",
            "subtitle": "First Impression",
            "desc": "Open the app and land on a stunning dark-themed splash screen. "
                     "The Wanderer brand greets you with a calming teal glow \u2014 "
                     "your journey starts with a single tap.",
            "color": TEAL,
            "icon": draw_icon_compass,
        },
        {
            "num": "02",
            "title": "Quick Verification",
            "subtitle": "Phone OTP",
            "desc": "Enter your phone number and verify with a one-time password. "
                     "No lengthy sign-ups. Secure, fast, and respectful of your time \u2014 "
                     "you\u2019re here to explore, not fill forms.",
            "color": AMBER,
            "icon": draw_icon_shield,
        },
        {
            "num": "03",
            "title": "Choose Your Plan",
            "subtitle": "Flexible Pricing",
            "desc": "Pick from thoughtfully designed plans \u2014 from a free discovery tier "
                     "to full-access premium. Powered by Razorpay & Stripe for seamless, "
                     "secure payments.",
            "color": HexColor("#8B5CF6"),
            "icon": draw_icon_map_pin,
        },
        {
            "num": "04",
            "title": "Start Exploring",
            "subtitle": "AI Chat Guide",
            "desc": "Chat with your AI guide in natural language. Ask about hidden cafes, "
                     "colonial history, sunset spots, or the best filter coffee in town. "
                     "Real-time WebSocket-powered conversations that feel alive.",
            "color": TEAL,
            "icon": draw_icon_chat,
        },
    ]

    card_h = 120
    start_y = H - 135
    for i, step in enumerate(steps):
        y = start_y - i * (card_h + 16)
        col = step["color"]

        # Card
        c.setFillColor(SURFACE)
        c.roundRect(30, y - card_h, W - 60, card_h, 10, fill=1, stroke=0)

        # Left accent
        c.setFillColor(col)
        c.roundRect(30, y - card_h, 5, card_h, 2, fill=1, stroke=0)

        # Step number circle
        c.setFillColor(Color(col.red, col.green, col.blue, 0.15))
        c.circle(72, y - 30, 20, fill=1, stroke=0)
        c.setFont("Helvetica-Bold", 14)
        c.setFillColor(col)
        c.drawCentredString(72, y - 35, step["num"])

        # Icon
        step["icon"](c, W - 80, y - card_h/2, 14)

        # Title and subtitle
        c.setFont("Helvetica-Bold", 14)
        c.setFillColor(TEXT_PRI)
        c.drawString(105, y - 28, step["title"])

        c.setFont("Helvetica", 8)
        c.setFillColor(col)
        c.drawString(105, y - 42, step["subtitle"].upper())

        # Description
        style = make_style(f"step{i}", size=9, color=TEXT_SEC, leading=13)
        draw_text_block(c, step["desc"], 105, y - 52, W - 220, style)

        # Connector line between cards
        if i < len(steps) - 1:
            c.setStrokeColor(Color(col.red, col.green, col.blue, 0.2))
            c.setLineWidth(1)
            c.setDash(3, 3)
            c.line(72, y - card_h, 72, y - card_h - 16)
            c.setDash()

    # Page number
    c.setFont("Helvetica", 8)
    c.setFillColor(TEXT_MUTED)
    c.drawRightString(W - 30, 20, "03")


# ════════════════════════════════════════════════════
# PAGE 4 — TECH & ARCHITECTURE
# ════════════════════════════════════════════════════
def page_tech(c):
    c.setFillColor(BG_DARK)
    c.rect(0, 0, W, H, fill=1, stroke=0)

    draw_gradient_rect(c, 0, H - 8, W, 8, TEAL_DARK, TEAL)

    # Section
    c.setFont("Helvetica-Bold", 72)
    c.setFillColor(Color(TEAL.red, TEAL.green, TEAL.blue, 0.08))
    c.drawString(30, H - 95, "04")
    c.setFont("Helvetica-Bold", 28)
    c.setFillColor(TEXT_PRI)
    c.drawString(30, H - 80, "Architecture")
    c.setStrokeColor(TEAL)
    c.setLineWidth(3)
    c.line(30, H - 90, 170, H - 90)

    # Architecture diagram - layered boxes
    layers = [
        ("Presentation Layer", "Flutter Widgets  |  GoRouter  |  Riverpod Providers", TEAL, H - 155),
        ("Domain Layer", "Use Cases  |  Entities  |  Business Logic", AMBER, H - 225),
        ("Data Layer", "Dio HTTP  |  WebSocket  |  Secure Storage", HexColor("#8B5CF6"), H - 295),
        ("Backend", "REST API  |  WebSocket Server  |  AI Engine", TEAL_DARK, H - 365),
    ]

    for label, sub, color, ly in layers:
        # Shadow
        c.setFillColor(Color(0, 0, 0, 0.2))
        c.roundRect(52, ly - 2, W - 104, 55, 8, fill=1, stroke=0)
        # Layer box
        c.setFillColor(SURFACE)
        c.setStrokeColor(Color(color.red, color.green, color.blue, 0.3))
        c.setLineWidth(1)
        c.roundRect(50, ly, W - 100, 55, 8, fill=1, stroke=1)
        # Color accent
        c.setFillColor(color)
        c.roundRect(50, ly, 5, 55, 2, fill=1, stroke=0)
        # Text
        c.setFont("Helvetica-Bold", 12)
        c.setFillColor(TEXT_PRI)
        c.drawString(70, ly + 33, label)
        c.setFont("Helvetica", 9)
        c.setFillColor(TEXT_SEC)
        c.drawString(70, ly + 15, sub)

        # Arrow between layers (except last)
        if ly != layers[-1][3]:
            c.setStrokeColor(Color(color.red, color.green, color.blue, 0.3))
            c.setLineWidth(1)
            c.setDash(4, 3)
            c.line(W/2, ly, W/2, ly - 15)
            # Arrowhead
            c.setFillColor(Color(color.red, color.green, color.blue, 0.3))
            p = c.beginPath()
            p.moveTo(W/2 - 4, ly - 11)
            p.lineTo(W/2, ly - 17)
            p.lineTo(W/2 + 4, ly - 11)
            p.close()
            c.drawPath(p, fill=1, stroke=0)
            c.setDash()

    # Tech stack cards
    stack_y = H - 430
    c.setFont("Helvetica-Bold", 16)
    c.setFillColor(TEXT_PRI)
    c.drawString(30, stack_y, "Tech Stack")
    c.setStrokeColor(AMBER)
    c.setLineWidth(2)
    c.line(30, stack_y - 8, 120, stack_y - 8)

    techs = [
        ("Flutter", "Cross-platform UI", TEAL),
        ("Riverpod", "State Management", AMBER),
        ("GoRouter", "Navigation", HexColor("#8B5CF6")),
        ("Dio", "HTTP Client", TEAL_DARK),
        ("WebSocket", "Real-time Chat", SUCCESS_GRN),
        ("Razorpay", "Payments", ERROR_RED),
    ]

    cols = 3
    card_w = (W - 60 - 20) / cols
    card_h = 65
    for i, (name, desc, color) in enumerate(techs):
        col_idx = i % cols
        row_idx = i // cols
        tx = 30 + col_idx * (card_w + 10)
        ty = stack_y - 30 - row_idx * (card_h + 10)

        c.setFillColor(SURFACE)
        c.roundRect(tx, ty - card_h, card_w, card_h, 8, fill=1, stroke=0)
        # Color dot
        c.setFillColor(color)
        c.circle(tx + 18, ty - 20, 6, fill=1, stroke=0)
        c.setFont("Helvetica-Bold", 11)
        c.setFillColor(TEXT_PRI)
        c.drawString(tx + 30, ty - 24, name)
        c.setFont("Helvetica", 8)
        c.setFillColor(TEXT_SEC)
        c.drawString(tx + 12, ty - card_h + 18, desc)

    # Design system preview
    ds_y = stack_y - 30 - 2 * (card_h + 10) - 40
    c.setFont("Helvetica-Bold", 16)
    c.setFillColor(TEXT_PRI)
    c.drawString(30, ds_y, "Design System")
    c.setStrokeColor(TEAL)
    c.setLineWidth(2)
    c.line(30, ds_y - 8, 145, ds_y - 8)

    # Color swatches
    colors_display = [
        ("#3ECFB4", "Primary", TEAL),
        ("#2A9D8F", "Muted", TEAL_DARK),
        ("#F59E0B", "Accent", AMBER),
        ("#0A0A0C", "Background", BG_DARK),
        ("#141418", "Surface", SURFACE),
        ("#1E1E24", "Surface Lt", SURFACE_LT),
        ("#1E3A5F", "User Msg", USER_BUBBLE),
        ("#1A1A22", "Guide Msg", GUIDE_BUBBLE),
    ]
    swatch_size = 32
    sw_spacing = (W - 60) / len(colors_display)
    for i, (hex_val, name, color) in enumerate(colors_display):
        sx = 30 + i * sw_spacing + sw_spacing / 2
        sy = ds_y - 35
        # Swatch
        c.setFillColor(color)
        c.setStrokeColor(Color(1, 1, 1, 0.1))
        c.setLineWidth(0.5)
        c.roundRect(sx - swatch_size/2, sy - swatch_size, swatch_size, swatch_size, 4, fill=1, stroke=1)
        # Label
        c.setFont("Helvetica", 6)
        c.setFillColor(TEXT_MUTED)
        c.drawCentredString(sx, sy - swatch_size - 10, name)
        c.setFillColor(Color(1, 1, 1, 0.25))
        c.drawCentredString(sx, sy - swatch_size - 20, hex_val)

    # Page number
    c.setFont("Helvetica", 8)
    c.setFillColor(TEXT_MUTED)
    c.drawRightString(W - 30, 20, "04")


# ════════════════════════════════════════════════════
# PAGE 5 — FEATURE DEEP DIVE
# ════════════════════════════════════════════════════
def page_features(c):
    c.setFillColor(BG_DARK)
    c.rect(0, 0, W, H, fill=1, stroke=0)

    draw_gradient_rect(c, 0, H - 8, W, 8, AMBER, TEAL)

    # Section
    c.setFont("Helvetica-Bold", 72)
    c.setFillColor(Color(AMBER.red, AMBER.green, AMBER.blue, 0.08))
    c.drawString(30, H - 95, "05")
    c.setFont("Helvetica-Bold", 28)
    c.setFillColor(TEXT_PRI)
    c.drawString(30, H - 80, "Feature Deep Dive")
    c.setStrokeColor(AMBER)
    c.setLineWidth(3)
    c.line(30, H - 90, 210, H - 90)

    # Feature cards - 2 column layout
    features = [
        {
            "title": "AI Chat Guide",
            "icon": draw_icon_chat,
            "color": TEAL,
            "points": [
                "Natural language conversations",
                "Real-time WebSocket messaging",
                "Context-aware recommendations",
                "Historical & cultural insights",
            ]
        },
        {
            "title": "Smart Navigation",
            "icon": draw_icon_compass,
            "color": AMBER,
            "points": [
                "Turn-by-turn guidance",
                "Hidden gem discovery",
                "Neighborhood walkthroughs",
                "Offline route caching",
            ]
        },
        {
            "title": "Local Intelligence",
            "icon": draw_icon_map_pin,
            "color": HexColor("#8B5CF6"),
            "points": [
                "Best food & caf\u00e9 picks",
                "Cultural event calendar",
                "Weather-aware suggestions",
                "Crowd-level indicators",
            ]
        },
        {
            "title": "Secure & Personal",
            "icon": draw_icon_shield,
            "color": SUCCESS_GRN,
            "points": [
                "OTP authentication",
                "Encrypted local storage",
                "Flexible subscription tiers",
                "Privacy-first design",
            ]
        },
    ]

    col_w = (W - 70) / 2
    card_h = 185
    start_y = H - 125

    for i, feat in enumerate(features):
        col = i % 2
        row = i // 2
        fx = 30 + col * (col_w + 10)
        fy = start_y - row * (card_h + 15)

        # Card
        c.setFillColor(SURFACE)
        c.roundRect(fx, fy - card_h, col_w, card_h, 10, fill=1, stroke=0)

        # Top accent
        c.setFillColor(feat["color"])
        c.roundRect(fx, fy - 4, col_w, 4, 2, fill=1, stroke=0)

        # Icon
        feat["icon"](c, fx + 28, fy - 35, 14)

        # Title
        c.setFont("Helvetica-Bold", 14)
        c.setFillColor(TEXT_PRI)
        c.drawString(fx + 52, fy - 40, feat["title"])

        # Divider
        c.setStrokeColor(SURFACE_LT)
        c.setLineWidth(0.5)
        c.line(fx + 15, fy - 58, fx + col_w - 15, fy - 58)

        # Points
        for j, point in enumerate(feat["points"]):
            py = fy - 78 - j * 22
            # Bullet dot
            c.setFillColor(feat["color"])
            c.circle(fx + 22, py + 3, 3, fill=1, stroke=0)
            c.setFont("Helvetica", 9)
            c.setFillColor(TEXT_SEC)
            c.drawString(fx + 32, py - 2, point)

    # Bottom CTA section
    cta_y = start_y - 2 * (card_h + 15) - 20
    c.setFillColor(TEAL_10)
    c.setStrokeColor(Color(TEAL.red, TEAL.green, TEAL.blue, 0.15))
    c.setLineWidth(1)
    c.roundRect(30, cta_y - 70, W - 60, 70, 10, fill=1, stroke=1)

    c.setFont("Helvetica-Bold", 14)
    c.setFillColor(TEAL)
    c.drawCentredString(W/2, cta_y - 22, "Built for Wanderers, by Wanderers")
    style = make_style("cta", size=9, color=TEXT_SEC, align=TA_CENTER, leading=14)
    draw_text_block(c,
        "Every feature is designed with the modern traveler in mind \u2014 fast, intuitive, "
        "and deeply personal. Your next adventure is one conversation away.",
        W/2 - 200, cta_y - 38, 400, style)

    # Page number
    c.setFont("Helvetica", 8)
    c.setFillColor(TEXT_MUTED)
    c.drawRightString(W - 30, 20, "05")


# ════════════════════════════════════════════════════
# PAGE 6 — PONDICHERRY STORY + CLOSING
# ════════════════════════════════════════════════════
def page_closing(c):
    c.setFillColor(BG_DARK)
    c.rect(0, 0, W, H, fill=1, stroke=0)

    # Top gradient
    draw_gradient_rect(c, 0, H * 0.65, W, H * 0.35, TEAL_10, BG_DARK)

    # Decorative circles
    draw_circle_pattern(c, W * 0.8, H * 0.7, 150, TEAL, 0.05)
    draw_circle_pattern(c, W * 0.2, H * 0.3, 100, AMBER, 0.04)

    # Top accent
    draw_gradient_rect(c, 0, H - 8, W, 8, TEAL, AMBER)

    # Section
    c.setFont("Helvetica-Bold", 72)
    c.setFillColor(Color(TEAL.red, TEAL.green, TEAL.blue, 0.08))
    c.drawString(30, H - 95, "06")
    c.setFont("Helvetica-Bold", 28)
    c.setFillColor(TEXT_PRI)
    c.drawString(30, H - 80, "The Pondicherry Story")
    c.setStrokeColor(TEAL)
    c.setLineWidth(3)
    c.line(30, H - 90, 255, H - 90)

    # Story content
    story_style = make_style("story", size=11, color=TEXT_SEC, leading=18, align=TA_JUSTIFY)
    quote_style = make_style("quote", font="Helvetica-BoldOblique", size=13, color=TEAL, leading=20, align=TA_CENTER)

    y = H - 120

    # Opening quote
    c.setFillColor(Color(TEAL.red, TEAL.green, TEAL.blue, 0.1))
    c.roundRect(50, y - 65, W - 100, 60, 8, fill=1, stroke=0)
    h = draw_text_block(c,
        "\u201CPondicherry is not a destination \u2014 it\u2019s a feeling. A place where French "
        "colonial charm meets Tamil warmth, where every street has a secret.\u201D",
        70, y - 10, W - 140, quote_style)
    y -= 90

    # Paragraphs
    paragraphs = [
        "For centuries, Pondicherry has been a crossroads of cultures. Tamil kings, French colonists, "
        "spiritual seekers, and modern-day travelers have all left their mark on this coastal gem. "
        "Yet most visitors only scratch the surface \u2014 the same beach promenade, the same "
        "restaurant row.",

        "Wanderer was born from a simple frustration: why does discovering a city\u2019s soul require "
        "knowing the right person? What if technology could democratize that privilege? What if an AI "
        "could be trained not just on facts, but on the <i>feeling</i> of a place?",

        "That\u2019s the promise of Wanderer. It\u2019s not a map. It\u2019s not a list. It\u2019s a "
        "conversation with someone who has walked every lane of the White Town at dawn, tasted every "
        "filter coffee on Mission Street, and watched a thousand sunsets from the Rock Beach.",
    ]

    for para in paragraphs:
        h = draw_text_block(c, para, 50, y, W - 100, story_style)
        y -= h + 12

    # Roadmap preview
    y -= 20
    c.setFont("Helvetica-Bold", 16)
    c.setFillColor(TEXT_PRI)
    c.drawString(50, y, "What\u2019s Next")
    c.setStrokeColor(AMBER)
    c.setLineWidth(2)
    c.line(50, y - 8, 140, y - 8)

    roadmap = [
        ("Offline Mode", "Full city guide without internet", TEAL),
        ("Voice Guide", "Hands-free audio tour narration", AMBER),
        ("AR Overlays", "History overlaid on your camera view", HexColor("#8B5CF6")),
        ("Community", "Share & discover traveler routes", SUCCESS_GRN),
    ]

    y -= 28
    for label, desc, color in roadmap:
        # Timeline dot
        c.setFillColor(color)
        c.circle(65, y + 3, 5, fill=1, stroke=0)
        # Line
        c.setStrokeColor(Color(color.red, color.green, color.blue, 0.2))
        c.setLineWidth(1)
        c.line(65, y - 5, 65, y - 18)
        # Text
        c.setFont("Helvetica-Bold", 10)
        c.setFillColor(TEXT_PRI)
        c.drawString(82, y, label)
        c.setFont("Helvetica", 8)
        c.setFillColor(TEXT_SEC)
        c.drawString(82, y - 13, desc)
        y -= 35

    # Bottom closing
    c.setFillColor(SURFACE)
    c.rect(0, 0, W, 80, fill=1, stroke=0)
    c.setStrokeColor(TEAL_DARK)
    c.setLineWidth(0.5)
    c.line(0, 80, W, 80)

    # Logo text
    c.setFont("Helvetica-Bold", 20)
    c.setFillColor(TEAL)
    c.drawCentredString(W/2, 48, "Wanderer")
    c.setFont("Helvetica", 9)
    c.setFillColor(TEXT_MUTED)
    c.drawCentredString(W/2, 32, "Your AI Tour Guide  \u2022  Pondicherry, India")
    c.setFont("Helvetica", 7)
    c.setFillColor(TEXT_MUTED)
    c.drawCentredString(W/2, 16, "Built with Flutter  \u2022  Powered by AI  \u2022  Designed with love")


# ════════════════════════════════════════════════════
# GENERATE PDF
# ════════════════════════════════════════════════════
def main():
    c = canvas.Canvas(OUTPUT, pagesize=A4)
    c.setTitle("Wanderer - Product Story")
    c.setAuthor("Wanderer Team")
    c.setSubject("AI Tour Guide for Pondicherry")

    pages = [
        page_cover,
        page_problem_vision,
        page_user_journey,
        page_tech,
        page_features,
        page_closing,
    ]

    for i, page_func in enumerate(pages):
        page_func(c)
        if i < len(pages) - 1:
            c.showPage()

    c.save()
    print(f"PDF saved to: {OUTPUT}")

if __name__ == "__main__":
    main()
