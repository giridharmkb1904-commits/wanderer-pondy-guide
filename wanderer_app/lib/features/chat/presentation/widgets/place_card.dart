import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class PlaceCard extends StatelessWidget {
  final String name;
  final String category;
  final String description;
  final String? rating;
  final String? priceRange;
  final String? address;
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
    this.onTap,
    this.onBook,
  });

  IconData get _categoryIcon {
    switch (category.toLowerCase()) {
      case 'restaurant': return Icons.restaurant;
      case 'beach': return Icons.beach_access;
      case 'temple': return Icons.temple_hindu;
      case 'cafe': return Icons.coffee;
      case 'hotel': return Icons.hotel;
      case 'museum': return Icons.museum;
      case 'shopping': return Icons.shopping_bag;
      case 'experience': return Icons.surfing;
      default: return Icons.place;
    }
  }

  Color get _categoryColor {
    switch (category.toLowerCase()) {
      case 'restaurant': return const Color(0xFFEF4444);
      case 'beach': return const Color(0xFF3B82F6);
      case 'temple': return const Color(0xFFF59E0B);
      case 'cafe': return const Color(0xFF8B5CF6);
      case 'hotel': return const Color(0xFF10B981);
      default: return WandererColors.primary;
    }
  }

  String get _priceLabel {
    switch (priceRange?.toLowerCase()) {
      case 'budget': return '\u20B9';
      case 'mid': return '\u20B9\u20B9';
      case 'premium': return '\u20B9\u20B9\u20B9';
      case 'free': return 'Free';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 64, top: 4, bottom: 8),
        decoration: BoxDecoration(
          color: WandererColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WandererColors.surfaceLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_categoryColor.withValues(alpha: 0.15), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _categoryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_categoryIcon, color: _categoryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: WandererColors.textPrimary)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(category[0].toUpperCase() + category.substring(1),
                                style: TextStyle(fontSize: 12, color: _categoryColor)),
                            if (rating != null) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade400),
                              const SizedBox(width: 2),
                              Text(rating!, style: const TextStyle(fontSize: 12, color: WandererColors.textSecondary)),
                            ],
                            if (_priceLabel.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(_priceLabel, style: TextStyle(fontSize: 12, color: WandererColors.textMuted, fontWeight: FontWeight.w600)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(description,
                  style: const TextStyle(fontSize: 13, color: WandererColors.textSecondary, height: 1.4),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            // Address + Book button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  if (address != null) ...[
                    const Icon(Icons.location_on_outlined, size: 14, color: WandererColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(address!, style: const TextStyle(fontSize: 11, color: WandererColors.textMuted),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ] else
                    const Spacer(),
                  if (onBook != null)
                    GestureDetector(
                      onTap: onBook,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: WandererColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Book', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WandererColors.background)),
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
}
