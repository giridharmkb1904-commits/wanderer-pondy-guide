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
              const Text('Choose Your Plan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: WandererColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Pay only for the days you explore', style: TextStyle(color: WandererColors.textSecondary)),
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
                      color: isSelected ? WandererColors.primary.withValues(alpha: 0.1) : WandererColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? WandererColors.primary : WandererColors.surfaceLight,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(entry.value['icon'] as IconData, color: isSelected ? WandererColors.primary : WandererColors.textMuted, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            entry.value['name'] as String,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isSelected ? WandererColors.primary : WandererColors.textPrimary),
                          ),
                        ),
                        Text(
                          '\u20B9$price/day',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? WandererColors.primary : WandererColors.textSecondary),
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
                    onPressed: _selectedDays > 1 ? () => setState(() => _selectedDays--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: WandererColors.primary,
                  ),
                  Text(
                    '$_selectedDays ${_selectedDays == 1 ? 'day' : 'days'}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: WandererColors.textPrimary),
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
                decoration: BoxDecoration(color: WandererColors.surface, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total', style: TextStyle(color: WandererColors.textMuted)),
                        Text(
                          '\u20B9${(_tiers[_selectedTier]!['price'] as int) * _selectedDays}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: WandererColors.textPrimary),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => context.go('/chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WandererColors.primary,
                        foregroundColor: WandererColors.background,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Start Exploring', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
