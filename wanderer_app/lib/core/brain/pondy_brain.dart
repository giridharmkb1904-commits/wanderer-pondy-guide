import 'dart:math';

/// Local Pondicherry tourism brain.
/// Pattern-matches visitor questions to curated responses + place cards.
/// Keeps the app working fully offline — no API keys required.
class PondyBrain {
  PondyBrain._();
  static final PondyBrain instance = PondyBrain._();

  final _rng = Random();

  /// Returns a reply plus optional place cards matching the schema used by
  /// `ChatMessage.cards`: a list of maps with name/category/description/etc.
  BrainReply answer(String input) {
    final q = input.toLowerCase();

    if (_any(q, ['hi', 'hello', 'hey', 'namaste', 'vanakkam', 'bonjour'])) {
      return BrainReply(
        _pick([
          'Hello! I\'m your Pondicherry guide. What are you in the mood for — cafés, sunsets, heritage walks, or something off-beat?',
          'Vanakkam! Ask me anything about Pondy — food, beaches, quiet corners, or a whole day plan.',
        ]),
      );
    }

    if (_any(q, ['thank', 'thanks', 'merci'])) {
      return BrainReply('Anytime. Anything else you\'d like me to plan?');
    }

    // Cafés
    if (_any(q, ['café', 'cafe', 'coffee', 'brunch', 'breakfast'])) {
      return BrainReply(
        'Pondy has a great café scene, especially in the French Quarter. Here are a few I always recommend:',
        cards: _cafes,
      );
    }

    // Beaches
    if (_any(q, ['beach', 'sea', 'sunrise', 'ocean', 'shore'])) {
      return BrainReply(
        'The coast is Pondy\'s front door. Rock Beach for the promenade, Paradise for a day trip, Serenity for quiet.',
        cards: _beaches,
      );
    }

    // Sunset / evening
    if (_any(q, ['sunset', 'evening', 'golden hour'])) {
      return BrainReply(
        'Best sunsets are actually facing west — try the Chunnambar backwaters or the rooftop at La Villa. Rock Beach is magical at sunrise instead.',
        cards: [_cafes[2], _beaches[1]],
      );
    }

    // Food — South Indian / Chettinad
    if (_any(q, ['chettinad', 'south indian', 'dosa', 'thali', 'idli', 'non-veg', 'biryani'])) {
      return BrainReply(
        'For South Indian done right — these are my go-to spots:',
        cards: _southIndian,
      );
    }

    // French cuisine / fine dining
    if (_any(q, ['french', 'fine dining', 'wine', 'crois', 'bistro'])) {
      return BrainReply(
        'For the French side of Pondy, these three rarely disappoint:',
        cards: _french,
      );
    }

    // Heritage / French Quarter / walks
    if (_any(q, ['heritage', 'french quarter', 'white town', 'walk', 'history', 'colonial', 'architect'])) {
      return BrainReply(
        'Start at Bharathi Park and wander through White Town. Mornings are cooler and the light is gorgeous on the yellow facades.',
        cards: _heritage,
      );
    }

    // Auroville
    if (_any(q, ['auroville', 'matri', 'experimental', 'township', 'commune'])) {
      return BrainReply(
        'Auroville is a 20-minute drive north. Book a Matrimandir pass the day before — there\'s a limited daily quota.',
        cards: _auroville,
      );
    }

    // Shopping
    if (_any(q, ['shop', 'shopping', 'souvenir', 'boutique', 'market', 'handicraft'])) {
      return BrainReply(
        'Skip the malls. Pondy\'s real shopping is in the French Quarter and Mission Street:',
        cards: _shopping,
      );
    }

    // Experiences / activities
    if (_any(q, ['experience', 'adventure', 'activity', 'cycle', 'bike'])) {
      return BrainReply(
        'A few unusual things I love recommending:',
        cards: _experiences,
      );
    }

    // Temples / spiritual
    if (_any(q, ['temple', 'spiritual', 'aurobindo'])) {
      return BrainReply(
        'The Aurobindo Ashram is in the heart of White Town — quiet, free, and deeply calm. Manakula Vinayagar is the oldest temple here.',
        cards: _spiritual,
      );
    }

    // Budget / cost
    if (_any(q, ['budget', 'cheap', 'cost', 'price', 'how much'])) {
      return BrainReply(
        'Daily ballpark: hostel ₹500–900, mid-range stay ₹2,500–5,000. Meals ₹150 (local) to ₹1,200 (French). Scooter rentals ₹350/day. Auroville entry is free; Matrimandir needs a booking.',
      );
    }

    // Transport
    if (_any(q, ['transport', 'taxi', 'scooter', 'rent', 'auto', 'uber', 'ola', 'how to get'])) {
      return BrainReply(
        'Rent a scooter — it\'s how locals move. Royal Brothers (near Bus Stand) has insured rentals from ₹350/day. Autos work too, always ask for the meter.',
      );
    }

    // Safety / SOS
    if (_any(q, ['safe', 'safety', 'sos', 'emergency', 'police'])) {
      return BrainReply(
        'Pondy is very safe, but stick to well-lit streets after 11pm. Emergency: 112. Tourist police: 0413-223-3333. Ashram area is quiet after 9pm.',
      );
    }

    // Weather
    if (_any(q, ['weather', 'rain', 'monsoon', 'best time', 'when to visit'])) {
      return BrainReply(
        'Nov–Feb is prime: cool evenings, clear skies. Oct and late-Dec can bring sudden rain. Mar–May gets properly hot. Avoid peak monsoon in Nov if you hate humidity.',
      );
    }

    // Itinerary / day plan
    if (_any(q, ['itinerary', 'day plan', 'schedule', 'plan', '1 day', 'one day', '2 days', 'two days'])) {
      return BrainReply(
        _dayPlan,
      );
    }

    // Languages
    if (_any(q, ['language', 'tamil', 'speak'])) {
      return BrainReply(
        'Tamil and English everywhere. French is still common in the French Quarter and older families. Hindi gets you by too.',
      );
    }

    // Nightlife / bars
    if (_any(q, ['nightlife', 'bar', 'pub', 'drinks', 'cocktail', 'nightclub'])) {
      return BrainReply(
        'Pondy\'s nightlife is low-key but good — rooftop bars beat loud clubs here. These are the best spots:',
        cards: _bars,
      );
    }

    // Yoga / wellness
    if (_any(q, ['yoga', 'meditation', 'wellness', 'ashram'])) {
      return BrainReply(
        'Pondy is a genuine wellness destination — especially around Auroville. Here are the best places to slow down:',
        cards: _yogaWellness,
      );
    }

    // Ayurveda / spa
    if (_any(q, ['ayurveda', 'spa', 'massage', 'treatment'])) {
      return BrainReply(
        'For a proper Ayurvedic treatment or massage, these three are worth booking ahead:',
        cards: _ayurvedaSpa,
      );
    }

    // Day trips
    if (_any(q, ['day trip', 'excursion', 'nearby', 'mahabalipuram', 'chidambaram', 'tranquebar', 'gingee'])) {
      return BrainReply(
        'Great day trips from Pondy:\n\n'
        '• **Mahabalipuram** (1.5h north) — UNESCO-listed Shore Temple and rock-cut bas-reliefs. Half-day is enough.\n'
        '• **Chidambaram** (2h south) — The Nataraja temple is one of the Pancha Bhuta Stalas. Stunning Dravidian gopurams.\n'
        '• **Tranquebar / Tharangambadi** (2h south) — Danish colonial fort, empty beaches, and a lovely 17th-century church.\n'
        '• **Gingee Fort** (2h west) — A dramatic hill fortress spread across three peaks. Bring water and good shoes.',
        cards: _dayTrips,
      );
    }

    // Watersports / beach activities
    if (_any(q, ['surf', 'surfing', 'swim', 'swimming', 'scuba', 'snorkel', 'kayak', 'watersports'])) {
      return BrainReply(
        'Pondy has more in the water than most people expect. Here\'s where to start:',
        cards: _watersports,
      );
    }

    // Kids / family
    if (_any(q, ['kids', 'children', 'family', 'family-friendly'])) {
      return BrainReply(
        'Pondy works well with kids — here\'s what families enjoy most:\n\n'
        '• **Paradise Beach** — Take the 15-min boat ride from Chunnambar to a sandy island. Paddling, beach games, lovely.\n'
        '• **Botanical Garden** — Spacious grounds, well-maintained, good for a morning wander.\n'
        '• **Children\'s Park** (near Bharathi Park) — Small but great for under-10s, right in the heart of town.\n'
        '• **Serenity Beach** — Calmer waves than Rock Beach, easy for kids to swim safely.\n\n'
        'Avoid Rock Beach for swimming — the promenade is great but the sea there is rough.',
        cards: _familySpots,
      );
    }

    // Photography spots
    if (_any(q, ['photo', 'photography', 'instagram', 'instagrammable', 'aesthetic'])) {
      return BrainReply(
        'Pondy is extremely photogenic. These are the spots every photographer hits:',
        cards: _photoSpots,
      );
    }

    // Bakeries / desserts
    if (_any(q, ['bakery', 'bakeries', 'dessert', 'cake', 'pastry', 'croissant', 'ice cream'])) {
      return BrainReply(
        'Pondy does pastries and sweets surprisingly well, thanks to the Franco-Tamil mix. These are the best:',
        cards: _bakeries,
      );
    }

    // "best" / "top" soft routing — map common category words to existing lists
    if (_any(q, ['best', 'top'])) {
      if (_any(q, ['eat', 'food', 'restaurant', 'lunch', 'dinner'])) {
        return BrainReply('Here are Pondy\'s top South Indian restaurants:', cards: _southIndian);
      }
      if (_any(q, ['drink', 'cocktail', 'nightlife', 'bar'])) {
        return BrainReply('Top bars and evening spots in Pondy:', cards: _bars);
      }
      if (_any(q, ['beach', 'sea', 'swim'])) {
        return BrainReply('The best beaches around Pondicherry:', cards: _beaches);
      }
      if (_any(q, ['café', 'cafe', 'coffee'])) {
        return BrainReply('The best cafés in Pondy:', cards: _cafes);
      }
    }

    // Fallback — curious, not dismissive
    return BrainReply(
      _pick([
        'Tell me a bit more — are you thinking food, beaches, a day walk, or something more off-beat?',
        'I can help with that. Are you looking for somewhere to eat, something to do, or a short itinerary?',
        'Ask me about cafés, beaches, heritage walks, Auroville, or a 2-day plan — I have opinions on all of them.',
      ]),
    );
  }

  bool _any(String q, List<String> words) => words.any(q.contains);
  String _pick(List<String> choices) => choices[_rng.nextInt(choices.length)];

  // ---- Curated place library ----

  static const List<Map<String, dynamic>> _cafes = [
    {
      'name': 'Café des Arts',
      'category': 'cafe',
      'description': 'Vintage French bistro on Suffren Street. Strong coffee, crêpes, and a backyard that hides from the sun.',
      'rating': '4.6',
      'priceRange': 'mid',
      'address': 'Suffren St, White Town',
      'query': 'Cafe des Arts Pondicherry',
    },
    {
      'name': 'Baker Street',
      'category': 'cafe',
      'description': 'Pondy\'s most famous bakery. Go early for fresh croissants and the tiramisu.',
      'rating': '4.5',
      'priceRange': 'mid',
      'address': 'Rue Bussy, White Town',
      'query': 'Baker Street Pondicherry',
    },
    {
      'name': 'La Villa',
      'category': 'cafe',
      'description': 'Rooftop colonial villa, candle-lit after sunset. Worth the splurge for a slow evening.',
      'rating': '4.7',
      'priceRange': 'premium',
      'address': 'Suffren St',
      'query': 'La Villa Pondicherry',
    },
    {
      'name': 'Café Xtasi',
      'category': 'cafe',
      'description': 'Wood-fired pizzas, breezy terrace, and live music on Saturdays. A local favorite.',
      'rating': '4.4',
      'priceRange': 'mid',
      'address': 'Bussy St',
      'query': 'Cafe Xtasi Pondicherry',
    },
  ];

  static const List<Map<String, dynamic>> _beaches = [
    {
      'name': 'Rock Beach (Promenade)',
      'category': 'beach',
      'description': 'Stone seawall in the heart of Pondy. Sunrise here is unbeatable. Closed to traffic in evenings.',
      'rating': '4.5',
      'priceRange': 'free',
      'address': 'Goubert Ave, White Town',
      'query': 'Rock Beach Pondicherry',
    },
    {
      'name': 'Paradise Beach',
      'category': 'beach',
      'description': 'Sandy island across the Chunnambar backwaters. Take the ferry (₹300). Pack for a day.',
      'rating': '4.4',
      'priceRange': 'budget',
      'address': 'Chunnambar',
      'query': 'Paradise Beach Pondicherry',
    },
    {
      'name': 'Serenity Beach',
      'category': 'beach',
      'description': 'Surfer hangout 10 min north. Quiet weekdays, busy Sunday mornings. Surf lessons from Kallialay.',
      'rating': '4.3',
      'priceRange': 'free',
      'address': 'Kottakuppam',
      'query': 'Serenity Beach Pondicherry',
    },
  ];

  static const List<Map<String, dynamic>> _southIndian = [
    {
      'name': 'Surguru',
      'category': 'restaurant',
      'description': 'Classic South Indian vegetarian. The ₹180 thali at lunch is ridiculous value.',
      'rating': '4.4',
      'priceRange': 'budget',
      'address': 'Mission St',
      'query': 'Surguru Pondicherry',
    },
    {
      'name': 'Appachi',
      'category': 'restaurant',
      'description': 'Chettinad specialist. Order the Chettinad chicken and pepper fry — they know what they\'re doing.',
      'rating': '4.5',
      'priceRange': 'mid',
      'address': 'SV Patel Rd',
      'query': 'Appachi Chettinad Pondicherry',
    },
    {
      'name': 'Hotel Aristo',
      'category': 'restaurant',
      'description': 'Old-school Tamil breakfast joint. Pesarattu and filter coffee done the proper way.',
      'rating': '4.2',
      'priceRange': 'budget',
      'address': 'Nehru St',
      'query': 'Hotel Aristo Pondicherry',
    },
  ];

  static const List<Map<String, dynamic>> _french = [
    {
      'name': 'Villa Shanti',
      'category': 'restaurant',
      'description': 'French-meets-South Indian tasting menu. Best served slow, ideally with wine.',
      'rating': '4.6',
      'priceRange': 'premium',
      'address': 'Suffren St',
      'query': 'Villa Shanti Pondicherry',
    },
    {
      'name': 'Le Café',
      'category': 'restaurant',
      'description': 'On the Promenade itself. 24/7, decent food, and the only seat in Pondy facing the sea all day.',
      'rating': '4.3',
      'priceRange': 'mid',
      'address': 'Goubert Ave',
      'query': 'Le Cafe Pondicherry',
    },
    {
      'name': 'Carte Blanche',
      'category': 'restaurant',
      'description': 'Boutique hotel restaurant, candle-lit courtyard. Great for a quiet anniversary dinner.',
      'rating': '4.5',
      'priceRange': 'premium',
      'address': 'Romain Rolland St',
      'query': 'Carte Blanche Pondicherry',
    },
  ];

  static const List<Map<String, dynamic>> _heritage = [
    {
      'name': 'French Quarter (White Town)',
      'category': 'experience',
      'description': 'Mustard-yellow facades, bougainvillea, and Tamil-French bilingual street signs. Walkable in 2 hours.',
      'rating': '4.7',
      'priceRange': 'free',
      'address': 'White Town',
      'query': 'French Quarter Pondicherry',
    },
    {
      'name': 'Bharathi Park',
      'category': 'experience',
      'description': 'Park with a 19th-century Aayi Mandapam monument at its centre. Lovely early mornings.',
      'rating': '4.4',
      'priceRange': 'free',
      'address': 'Goubert Ave',
      'query': 'Bharathi Park Pondicherry',
    },
    {
      'name': 'Pondicherry Museum',
      'category': 'museum',
      'description': 'Small but well-curated — colonial artefacts, Chola bronzes, and a surprisingly good coin collection.',
      'rating': '4.1',
      'priceRange': 'budget',
      'address': 'Bharathi Park',
      'query': 'Pondicherry Museum',
    },
  ];

  static const List<Map<String, dynamic>> _auroville = [
    {
      'name': 'Matrimandir',
      'category': 'experience',
      'description': 'Golden geodesic dome at the centre of Auroville. Book a pass for the inner chamber — it\'s silent and remarkable.',
      'rating': '4.7',
      'priceRange': 'free',
      'address': 'Auroville',
      'query': 'Matrimandir Auroville',
    },
    {
      'name': 'Visitor Centre',
      'category': 'experience',
      'description': 'Start here. Exhibition, café, and the handicrafts boutique with Auroville-made goods.',
      'rating': '4.4',
      'priceRange': 'free',
      'address': 'Auroville',
      'query': 'Auroville Visitor Centre',
    },
    {
      'name': 'Marc\'s Coffees',
      'category': 'cafe',
      'description': 'Best roasted coffee around Auroville. Tiny spot, outdoor seating, slow-dripped pour-overs.',
      'rating': '4.6',
      'priceRange': 'mid',
      'address': 'Auroville',
      'query': 'Marcs Coffees Auroville',
    },
  ];

  static const List<Map<String, dynamic>> _shopping = [
    {
      'name': 'Kalki',
      'category': 'shopping',
      'description': 'Indo-French textiles, scarves, and cotton dresses. Good quality, fair prices.',
      'rating': '4.5',
      'priceRange': 'mid',
      'address': 'Mission St',
      'query': 'Kalki Pondicherry',
    },
    {
      'name': 'Auroville Boutique',
      'category': 'shopping',
      'description': 'Incense, aromatic oils, eco-clothing from Auroville units. Thoughtfully made.',
      'rating': '4.4',
      'priceRange': 'mid',
      'address': 'Nehru St',
      'query': 'Auroville Boutique Pondicherry',
    },
    {
      'name': 'Goubert Market',
      'category': 'shopping',
      'description': 'Chaotic, colourful, and real. Best for spices, fresh produce, and flowers.',
      'rating': '4.2',
      'priceRange': 'budget',
      'address': 'MG Rd',
      'query': 'Goubert Market Pondicherry',
    },
  ];

  static const List<Map<String, dynamic>> _experiences = [
    {
      'name': 'Kallialay Surf School',
      'category': 'experience',
      'description': 'Lessons at Serenity Beach. Best in the morning, October–March.',
      'rating': '4.7',
      'priceRange': 'mid',
      'address': 'Kottakuppam',
      'query': 'Kallialay Surf School Pondicherry',
    },
    {
      'name': 'Sita Cultural Centre — Cycling Tour',
      'category': 'experience',
      'description': 'Sunrise cycle through the French Quarter and Tamil Quarter. 3 hours, includes chai stops.',
      'rating': '4.6',
      'priceRange': 'mid',
      'address': 'White Town',
      'query': 'Sita Cultural Centre Pondicherry',
    },
    {
      'name': 'Temple Adventures — Diving',
      'category': 'experience',
      'description': 'Only PADI dive centre on this coast. Discover-dive for beginners, trips out to shipwrecks for certified.',
      'rating': '4.5',
      'priceRange': 'premium',
      'address': 'Thengaithittu',
      'query': 'Temple Adventures Pondicherry',
    },
  ];

  static const List<Map<String, dynamic>> _spiritual = [
    {
      'name': 'Sri Aurobindo Ashram',
      'category': 'temple',
      'description': 'The heart of spiritual Pondy. Silence around the Samadhi shrine. Free, open 08:00–12:00 and 14:00–18:00.',
      'rating': '4.7',
      'priceRange': 'free',
      'address': 'Rue de la Marine',
      'query': 'Sri Aurobindo Ashram Pondicherry',
    },
    {
      'name': 'Manakula Vinayagar Temple',
      'category': 'temple',
      'description': 'Oldest temple in town, dedicated to Ganesha. There\'s usually a temple elephant at the entrance.',
      'rating': '4.6',
      'priceRange': 'free',
      'address': 'Manakula Vinayagar St',
      'query': 'Manakula Vinayagar Temple Pondicherry',
    },
    {
      'name': 'Notre Dame des Anges',
      'category': 'temple',
      'description': 'Pale-pink 19th-century church with a Tamil-inscribed crucifix. Quiet, very photogenic.',
      'rating': '4.5',
      'priceRange': 'free',
      'address': 'Dumas St',
      'query': 'Notre Dame des Anges Pondicherry',
    },
  ];

  static const String _dayPlan =
      'A great 2-day Pondy:\n\n'
      '**Day 1 — French side**\n'
      '• 07:00 Sunrise on Rock Beach\n'
      '• 08:30 Breakfast at Baker Street\n'
      '• 10:00 Walk the French Quarter — Dumas St, Romain Rolland St, Bharathi Park\n'
      '• 13:00 Lunch at Villa Shanti or Le Café\n'
      '• 16:00 Nap or pool\n'
      '• 19:30 Dinner at Carte Blanche, nightcap on Suffren\n\n'
      '**Day 2 — Beyond the city**\n'
      '• 08:00 Drive to Auroville, Matrimandir viewpoint\n'
      '• 11:30 Visitor Centre shopping + Marc\'s Coffees\n'
      '• 13:30 Lunch at Tanto\'s or Solar Kitchen\n'
      '• 15:30 Back via Serenity Beach for a dip\n'
      '• 18:30 Boat at Chunnambar backwaters for sunset\n'
      '• 20:30 Chettinad dinner at Appachi';

  // ---- New clusters ----

  static const List<Map<String, dynamic>> _bars = [
    {
      'name': 'L\'aqua Bar at Le Dupleix',
      'category': 'bar',
      'description': 'Elegant poolside bar inside a restored heritage hotel. Craft cocktails, calm crowd, excellent ambience.',
      'rating': '4.5',
      'priceRange': 'premium',
      'address': 'Rue de la Caserne, White Town',
      'query': 'L\'aqua Bar Le Dupleix Pondicherry',
    },
    {
      'name': 'Seagulls Restaurant & Bar',
      'category': 'bar',
      'description': 'Rooftop bar with sweeping sea views. Best at dusk. Cold beer, basic cocktails, and a killer breeze.',
      'rating': '4.3',
      'priceRange': 'mid',
      'address': 'Goubert Ave, Rock Beach',
      'query': 'Seagulls Bar Pondicherry rooftop',
    },
    {
      'name': 'The Promenade Cliff Lounge',
      'category': 'bar',
      'description': 'Clifftop lounge right on the Promenade. Great sundowners; the sea-facing seats go fast.',
      'rating': '4.4',
      'priceRange': 'mid',
      'address': 'Promenade Beach Rd',
      'query': 'Promenade Cliff Lounge Pondicherry',
    },
  ];

  static const List<Map<String, dynamic>> _yogaWellness = [
    {
      'name': 'Sri Aurobindo Ashram — Meditation Hall',
      'category': 'wellness',
      'description': 'Open morning and evening, silent sitting around the Samadhi. Profound even for non-practitioners.',
      'rating': '4.8',
      'priceRange': 'free',
      'address': 'Rue de la Marine, White Town',
      'query': 'Sri Aurobindo Ashram meditation Pondicherry',
    },
    {
      'name': 'Ananda Yoga Centre',
      'category': 'wellness',
      'description': 'Drop-in Hatha and Vinyasa classes, small batches, experienced teachers. Mats provided.',
      'rating': '4.5',
      'priceRange': 'budget',
      'address': 'Nehru St, Pondicherry',
      'query': 'Ananda Yoga Centre Pondicherry',
    },
    {
      'name': 'International Yoga Centre Auroville',
      'category': 'wellness',
      'description': 'Immersive yoga and pranayama programs set inside the Auroville forest. Week-long retreats available.',
      'rating': '4.6',
      'priceRange': 'mid',
      'address': 'Auroville',
      'query': 'International Yoga Centre Auroville',
    },
  ];

  static const List<Map<String, dynamic>> _ayurvedaSpa = [
    {
      'name': 'Sri Kairali Ayurvedic Centre',
      'category': 'wellness',
      'description': 'Authentic Kerala-style Ayurvedic treatments — Shirodhara, Abhyanga, Panchakarma. Book a day in advance.',
      'rating': '4.5',
      'priceRange': 'premium',
      'address': 'Maraimalai Adigal Salai',
      'query': 'Sri Kairali Ayurvedic Pondicherry',
    },
    {
      'name': 'Quietude Wellness',
      'category': 'wellness',
      'description': 'Boutique spa with Ayurvedic massages and yoga. Set in a peaceful garden property outside the city.',
      'rating': '4.6',
      'priceRange': 'premium',
      'address': 'ECR, near Pondicherry',
      'query': 'Quietude Wellness Pondicherry spa',
    },
    {
      'name': 'Le Pondy Spa',
      'category': 'wellness',
      'description': 'Resort spa with steam, hydrotherapy, and signature Indo-French aromatherapy treatments.',
      'rating': '4.3',
      'priceRange': 'premium',
      'address': 'Le Pondy Resort, ECR',
      'query': 'Le Pondy Spa Pondicherry',
    },
  ];

  static const List<Map<String, dynamic>> _dayTrips = [
    {
      'name': 'Mahabalipuram',
      'category': 'experience',
      'description': 'UNESCO Shore Temple and extraordinary 7th-century rock-cut bas-reliefs. 1.5 hours north by road.',
      'rating': '4.7',
      'priceRange': 'budget',
      'address': 'Mahabalipuram, Tamil Nadu',
      'query': 'Mahabalipuram Shore Temple day trip Pondicherry',
    },
    {
      'name': 'Chidambaram Nataraja Temple',
      'category': 'experience',
      'description': 'One of the five elemental Shiva temples (space / akasha). The gopurams are spectacular. 2 hours south.',
      'rating': '4.6',
      'priceRange': 'free',
      'address': 'Chidambaram, Tamil Nadu',
      'query': 'Chidambaram Nataraja Temple day trip',
    },
    {
      'name': 'Tranquebar (Tharangambadi)',
      'category': 'experience',
      'description': 'Former Danish colonial town. Fort Dansborg, empty beaches, and a quiet pace. 2 hours south of Pondy.',
      'rating': '4.4',
      'priceRange': 'free',
      'address': 'Tharangambadi, Tamil Nadu',
      'query': 'Tranquebar Tharangambadi day trip Pondicherry',
    },
    {
      'name': 'Gingee Fort',
      'category': 'experience',
      'description': 'Dramatic hill fortress called the "Troy of the East" — three peaks, massive ramparts, panoramic views. 2 hours west.',
      'rating': '4.5',
      'priceRange': 'budget',
      'address': 'Gingee, Tamil Nadu',
      'query': 'Gingee Fort hill fortress day trip',
    },
  ];

  static const List<Map<String, dynamic>> _watersports = [
    {
      'name': 'Kallialay Surf School',
      'category': 'experience',
      'description': 'Best surf lessons on this coast. Small groups, safety-first. October to March for consistent waves.',
      'rating': '4.7',
      'priceRange': 'mid',
      'address': 'Serenity Beach, Kottakuppam',
      'query': 'Kallialay Surf School Serenity Beach Pondicherry',
    },
    {
      'name': 'Temple Adventures',
      'category': 'experience',
      'description': 'Only PADI-certified dive centre on this coast. Discover dives for beginners, shipwreck dives for certified divers.',
      'rating': '4.5',
      'priceRange': 'premium',
      'address': 'Auroville Rd, Thengaithittu',
      'query': 'Temple Adventures scuba diving Pondicherry',
    },
    {
      'name': 'Aquasub Scuba Diving',
      'category': 'experience',
      'description': 'PADI courses and guided dives with experienced local instructors. Snorkelling trips available too.',
      'rating': '4.4',
      'priceRange': 'premium',
      'address': 'Pondicherry coast',
      'query': 'Aquasub Scuba Diving Pondicherry',
    },
  ];

  static const List<Map<String, dynamic>> _familySpots = [
    {
      'name': 'Paradise Beach',
      'category': 'beach',
      'description': 'Boat ride from Chunnambar to a calm sandy island. Kids love the ferry crossing and the clear shallow water.',
      'rating': '4.4',
      'priceRange': 'budget',
      'address': 'Chunnambar Boat House',
      'query': 'Paradise Beach Pondicherry boat ride',
    },
    {
      'name': 'Botanical Garden',
      'category': 'experience',
      'description': 'Spacious 19th-century garden with shaded paths, fountains, and a toy train on weekends. Great for kids.',
      'rating': '4.2',
      'priceRange': 'budget',
      'address': 'Bharathi Park Rd',
      'query': 'Botanical Garden Pondicherry',
    },
    {
      'name': 'Children\'s Park',
      'category': 'experience',
      'description': 'Well-maintained playground near Bharathi Park with swings, slides, and open lawns. Free entry.',
      'rating': '4.1',
      'priceRange': 'free',
      'address': 'Near Bharathi Park, White Town',
      'query': 'Children\'s Park Pondicherry Bharathi',
    },
    {
      'name': 'Serenity Beach',
      'category': 'beach',
      'description': 'Calmer than Rock Beach. Gentle entry for safe swimming; surf school nearby for older kids and teens.',
      'rating': '4.3',
      'priceRange': 'free',
      'address': 'Kottakuppam',
      'query': 'Serenity Beach Pondicherry swimming',
    },
  ];

  static const List<Map<String, dynamic>> _photoSpots = [
    {
      'name': 'Rock Beach Promenade at Dawn',
      'category': 'experience',
      'description': 'The clean seafront, pastel sky, and sea spray make for magical early-morning shots. Best 06:00–07:30.',
      'rating': '4.7',
      'priceRange': 'free',
      'address': 'Goubert Ave, White Town',
      'query': 'Rock Beach Pondicherry sunrise photography',
    },
    {
      'name': 'French Quarter Yellow Walls (Rue Romain Rolland)',
      'category': 'experience',
      'description': 'The iconic mustard-yellow walls, shuttered windows, and bougainvillea. Every lane is a frame.',
      'rating': '4.8',
      'priceRange': 'free',
      'address': 'Rue Romain Rolland, White Town',
      'query': 'French Quarter yellow walls Pondicherry Instagram',
    },
    {
      'name': 'Paradise Beach',
      'category': 'beach',
      'description': 'The boat crossing and the pristine sandbar offer great wide-angle and golden-hour shots.',
      'rating': '4.4',
      'priceRange': 'budget',
      'address': 'Chunnambar',
      'query': 'Paradise Beach Pondicherry photography',
    },
    {
      'name': 'Auroville Matrimandir Viewpoint',
      'category': 'experience',
      'description': 'The golden sphere through a gap in the banyan canopy. The official viewpoint at dusk is stunning.',
      'rating': '4.7',
      'priceRange': 'free',
      'address': 'Auroville',
      'query': 'Matrimandir viewpoint photography Auroville',
    },
  ];

  static const List<Map<String, dynamic>> _bakeries = [
    {
      'name': 'Baker Street',
      'category': 'cafe',
      'description': 'Pondy\'s best-known bakery. Fresh croissants every morning, tiramisu, and proper sourdough.',
      'rating': '4.5',
      'priceRange': 'mid',
      'address': 'Rue Bussy, White Town',
      'query': 'Baker Street bakery Pondicherry',
    },
    {
      'name': 'Zuka Choco-La',
      'category': 'cafe',
      'description': 'Artisan chocolatier with handmade truffles and hot chocolate. Great for gifting.',
      'rating': '4.4',
      'priceRange': 'mid',
      'address': 'Mission St, Pondicherry',
      'query': 'Zuka Chocolate Pondicherry',
    },
    {
      'name': 'Bread & Chocolate (Auroville)',
      'category': 'cafe',
      'description': 'Hidden Auroville gem. Banana bread, tarts, and excellent filter coffee under the trees.',
      'rating': '4.5',
      'priceRange': 'mid',
      'address': 'Auroville',
      'query': 'Bread and Chocolate Auroville bakery',
    },
    {
      'name': 'GMT Ice Cream',
      'category': 'cafe',
      'description': 'Old-school ice cream parlour on ECR. Natural fruit flavours, generous scoops, very local crowd.',
      'rating': '4.3',
      'priceRange': 'budget',
      'address': 'ECR Road, Pondicherry',
      'query': 'GMT Ice Cream Pondicherry ECR',
    },
  ];
}

class BrainReply {
  final String content;
  final List<Map<String, dynamic>>? cards;

  BrainReply(this.content, {this.cards});
}
