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
