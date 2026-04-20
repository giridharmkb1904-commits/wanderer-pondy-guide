import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/maps/maps_launcher.dart';
import '../../../../core/theme/colors.dart';

class PlaceCard extends StatelessWidget {
  final String name;
  final String category;
  final String description;
  final String? rating;
  final String? priceRange;
  final String? address;
  final String? query;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  const PlaceCard({
    super.key,
    required this.name,
    required this.category,
    required this.description,
    this.rating,
    this.priceRange,
    this.address,
    this.query,
    this.onTap,
    this.onBook,
  });

  factory PlaceCard.fromJson(Map<String, dynamic> json, {VoidCallback? onTap, VoidCallback? onBook}) {
    return PlaceCard(
      name: json['name'] as String,
      category: (json['category'] as String?) ?? 'place',
      description: (json['description'] as String?) ?? '',
      rating: json['rating'] as String?,
      priceRange: json['priceRange'] as String?,
      address: json['address'] as String?,
      query: json['query'] as String?,
      onTap: onTap,
      onBook: onBook,
    );
  }

  IconData get _categoryIcon {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'beach':
        return Icons.beach_access_rounded;
      case 'temple':
        return Icons.temple_hindu_rounded;
      case 'cafe':
        return Icons.local_cafe_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      case 'museum':
        return Icons.museum_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'experience':
        return Icons.explore_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Color get _categoryColor {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return const Color(0xFFEF4444);
      case 'beach':
        return const Color(0xFF3B82F6);
      case 'temple':
        return const Color(0xFFF59E0B);
      case 'cafe':
        return const Color(0xFFA78BFA);
      case 'hotel':
        return const Color(0xFF10B981);
      case 'shopping':
        return const Color(0xFFEC4899);
      case 'museum':
        return const Color(0xFF60A5FA);
      default:
        return WandererColors.primary;
    }
  }

  String get _priceLabel {
    switch (priceRange?.toLowerCase()) {
      case 'budget':
        return '\u20B9';
      case 'mid':
        return '\u20B9\u20B9';
      case 'premium':
        return '\u20B9\u20B9\u20B9';
      case 'free':
        return 'Free';
      default:
        return '';
    }
  }

  void _openInMaps() {
    final target = (query ?? name).trim();
    if (target.isEmpty) return;
    MapsLauncher.openQuery(target);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _categoryColor;
    final card = Container(
      margin: const EdgeInsets.only(left: 16, right: 64, top: 4, bottom: 8),
      decoration: BoxDecoration(
        color: WandererColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WandererColors.surfaceLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? _openInMaps,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_categoryIcon, color: accent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                              color: WandererColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                _capitalize(category),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (rating != null) ...[
                                const SizedBox(width: 10),
                                Icon(Icons.star_rounded, size: 13, color: Colors.amber.shade400),
                                const SizedBox(width: 2),
                                Text(
                                  rating!,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: WandererColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              if (_priceLabel.isNotEmpty) ...[
                                const SizedBox(width: 10),
                                Text(
                                  _priceLabel,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: WandererColors.textMuted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: WandererColors.textSecondary,
                    height: 1.45,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 12, 12),
                child: Row(
                  children: [
                    if (address != null) ...[
                      Icon(Icons.location_on_outlined,
                          size: 13, color: WandererColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address!,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: WandererColors.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else
                      const Spacer(),
                    const SizedBox(width: 8),
                    _actionButton(
                      label: 'Open',
                      icon: Icons.map_outlined,
                      onTap: _openInMaps,
                      filled: false,
                    ),
                    if (onBook != null) ...[
                      const SizedBox(width: 8),
                      _actionButton(
                        label: 'Book',
                        icon: Icons.bookmark_added_outlined,
                        onTap: onBook!,
                        filled: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return card.animate().fadeIn(duration: 320.ms).slideY(
          begin: 0.12,
          end: 0,
          duration: 320.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return Material(
      color: filled ? WandererColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: filled ? WandererColors.primary : WandererColors.surfaceLight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: filled ? WandererColors.background : WandererColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: filled ? WandererColors.background : WandererColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
