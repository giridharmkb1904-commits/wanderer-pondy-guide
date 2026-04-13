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
  int _selectedDays = 2;
  String _selectedTier = 'guide';

  static const _tiers = [
    {
      'id': 'explorer',
      'name': 'Explorer',
      'price': 49,
      'icon': Icons.backpack_outlined,
      'color': 0xFF9CA3AF,
      'features': ['Text chat with AI guide', 'Personalized recommendations', 'Itinerary building', 'Offline cache'],
    },
    {
      'id': 'guide',
      'name': 'Guide',
      'price': 199,
      'icon': Icons.record_voice_over_outlined,
      'color': 0xFF3ECFB4,
      'badge': 'POPULAR',
      'features': ['Everything in Explorer', 'Voice conversation', 'Proactive alerts', 'Navigation & transport', 'Budget tracking'],
    },
    {
      'id': 'concierge',
      'name': 'Concierge',
      'price': 349,
      'icon': Icons.auto_awesome,
      'color': 0xFFF59E0B,
      'features': ['Everything in Guide', 'AI concierge booking', 'Premium ElevenLabs voice', 'Trip memories & journal', 'Group sync', 'Camera AI', 'Document vault'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WandererColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Choose Your Plan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: WandererColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Pay only for the days you explore. No subscriptions.', style: TextStyle(color: WandererColors.textMuted, fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tier cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _tiers.length,
                itemBuilder: (context, index) {
                  final tier = _tiers[index];
                  final id = tier['id'] as String;
                  final isSelected = _selectedTier == id;
                  final color = Color(tier['color'] as int);
                  final features = tier['features'] as List<String>;
                  final badge = tier['badge'] as String?;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedTier = id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withValues(alpha: 0.08) : WandererColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : WandererColors.surfaceLight,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 4))]
                            : [],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(tier['icon'] as IconData, color: color, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(tier['name'] as String, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isSelected ? color : WandererColors.textPrimary)),
                                        if (badge != null) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                                            child: Text(badge, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: WandererColors.background)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text('\u20B9${tier['price']}/day', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isSelected ? color : WandererColors.textSecondary)),
                            ],
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 16),
                            const Divider(color: WandererColors.surfaceLight, height: 1),
                            const SizedBox(height: 12),
                            ...features.map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, size: 16, color: color),
                                  const SizedBox(width: 8),
                                  Text(f, style: const TextStyle(fontSize: 13, color: WandererColors.textSecondary)),
                                ],
                              ),
                            )),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom bar — days + total + pay
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: WandererColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: WandererColors.surfaceLight.withValues(alpha: 0.5))),
              ),
              child: Column(
                children: [
                  // Days selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _dayButton(-1),
                      const SizedBox(width: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          '$_selectedDays ${_selectedDays == 1 ? 'day' : 'days'}',
                          key: ValueKey(_selectedDays),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: WandererColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _dayButton(1),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Total + CTA
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total', style: TextStyle(color: WandererColors.textMuted, fontSize: 12)),
                          Text(
                            '\u20B9$_totalPrice',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: WandererColors.textPrimary),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => context.go('/chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WandererColors.primary,
                            foregroundColor: WandererColors.background,
                            padding: const EdgeInsets.symmetric(horizontal: 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: const Row(
                            children: [
                              Text('Start Exploring', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get _totalPrice {
    final tier = _tiers.firstWhere((t) => t['id'] == _selectedTier);
    return (tier['price'] as int) * _selectedDays;
  }

  Widget _dayButton(int delta) {
    final canDecrease = delta < 0 && _selectedDays > 1;
    final canIncrease = delta > 0;
    final enabled = delta < 0 ? canDecrease : canIncrease;

    return GestureDetector(
      onTap: enabled ? () => setState(() => _selectedDays += delta) : null,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? WandererColors.primary.withValues(alpha: 0.1) : WandererColors.surfaceLight,
          border: Border.all(color: enabled ? WandererColors.primary : WandererColors.surfaceLight),
        ),
        child: Icon(
          delta < 0 ? Icons.remove : Icons.add,
          color: enabled ? WandererColors.primary : WandererColors.textMuted,
          size: 20,
        ),
      ),
    );
  }
}
