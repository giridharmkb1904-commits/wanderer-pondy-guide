import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';

class PlanSelectionScreen extends ConsumerStatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  ConsumerState<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _Tier {
  final String id;
  final String name;
  final String tagline;
  final int price;
  final IconData icon;
  final Color accent;
  final String? badge;
  final List<String> features;
  const _Tier({
    required this.id,
    required this.name,
    required this.tagline,
    required this.price,
    required this.icon,
    required this.accent,
    required this.features,
    this.badge,
  });
}

class _PlanSelectionScreenState extends ConsumerState<PlanSelectionScreen> {
  int _selectedDays = 2;
  String _selectedTier = 'guide';

  static const List<_Tier> _tiers = [
    _Tier(
      id: 'explorer',
      name: 'Explorer',
      tagline: 'Perfect for a quick day out',
      price: 49,
      icon: Icons.backpack_outlined,
      accent: Color(0xFF9CA3AF),
      features: [
        'Chat with your AI guide',
        'Personalized picks',
        'Basic itinerary builder',
        'Offline cache for saved spots',
      ],
    ),
    _Tier(
      id: 'guide',
      name: 'Guide',
      tagline: 'Our most loved pass',
      price: 199,
      icon: Icons.auto_awesome,
      accent: WandererColors.primary,
      badge: 'MOST POPULAR',
      features: [
        'Everything in Explorer',
        'Deep local context & stories',
        'Proactive suggestions as you move',
        'Navigation & transport help',
        'Budget tracking',
      ],
    ),
    _Tier(
      id: 'concierge',
      name: 'Concierge',
      tagline: 'The full luxury experience',
      price: 349,
      icon: Icons.diamond_outlined,
      accent: WandererColors.secondary,
      badge: 'BEST VALUE',
      features: [
        'Everything in Guide',
        'AI concierge booking',
        'Trip memories & journal',
        'Group sync',
        'Camera AI scene recognition',
        'Document vault',
      ],
    ),
  ];

  _Tier get _tier => _tiers.firstWhere((t) => t.id == _selectedTier);
  int get _total => _tier.price * _selectedDays;

  void _setDays(int delta) {
    final next = (_selectedDays + delta).clamp(1, 30);
    if (next == _selectedDays) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedDays = next);
  }

  void _selectTier(String id) {
    if (_selectedTier == id) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedTier = id);
  }

  void _continue() {
    HapticFeedback.mediumImpact();
    // TODO(razorpay): wire razorpay_flutter checkout here using _tier + _selectedDays.
    context.pushReplacement('/chat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WandererColors.background,
      body: Stack(
        children: [
          const _AmbientGlow(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pick your pace',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: WandererColors.textPrimary,
                          letterSpacing: -0.7,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Longer trips unlock deeper local knowledge.',
                        style: TextStyle(
                          fontSize: 14,
                          color: WandererColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 180),
                    children: [
                      ...List.generate(_tiers.length, (i) {
                        final t = _tiers[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _TierCard(
                            tier: t,
                            selected: _selectedTier == t.id,
                            onTap: () => _selectTier(t.id),
                          ),
                        ).animate().fadeIn(delay: (200 + i * 90).ms, duration: 380.ms).slideY(
                              begin: 0.16,
                              end: 0,
                              delay: (200 + i * 90).ms,
                              duration: 380.ms,
                              curve: Curves.easeOutCubic,
                            );
                      }),
                      const SizedBox(height: 8),
                      _DaysSelector(
                        days: _selectedDays,
                        onDelta: _setDays,
                      ).animate().fadeIn(delay: 560.ms, duration: 380.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomBar(
              tierName: _tier.name,
              days: _selectedDays,
              total: _total,
              onContinue: _continue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/onboarding');
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: WandererColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: WandererColors.surfaceLight),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: WandererColors.textPrimary, size: 16),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: WandererColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: WandererColors.primary.withValues(alpha: 0.28)),
            ),
            child: const Text(
              'Pondicherry',
              style: TextStyle(
                fontSize: 11,
                color: WandererColors.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final _Tier tier;
  final bool selected;
  final VoidCallback onTap;

  const _TierCard({required this.tier, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = tier.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(
                  accent.withValues(alpha: 0.06),
                  WandererColors.surface,
                )
              : WandererColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accent : WandererColors.surfaceLight,
            width: selected ? 1.6 : 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.22),
                    blurRadius: 28,
                    spreadRadius: -6,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(tier.icon, color: accent, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tier.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: selected ? accent : WandererColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (tier.badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tier.badge!,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tier.tagline,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: WandererColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\u20B9',
                          style: TextStyle(
                            fontSize: 14,
                            color: selected ? accent : WandererColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 1),
                        Text(
                          '${tier.price}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: selected ? accent : WandererColors.textPrimary,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '/ day',
                      style: TextStyle(
                        fontSize: 11,
                        color: WandererColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 260),
              crossFadeState:
                  selected ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  Container(
                    height: 1,
                    color: WandererColors.surfaceLight,
                  ),
                  const SizedBox(height: 12),
                  ...tier.features.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.only(top: 1),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.16),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check_rounded,
                                  size: 12, color: accent),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                f,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: WandererColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaysSelector extends StatelessWidget {
  final int days;
  final ValueChanged<int> onDelta;

  const _DaysSelector({required this.days, required this.onDelta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: WandererColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WandererColors.surfaceLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trip duration',
                  style: TextStyle(
                    fontSize: 13,
                    color: WandererColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'How many days will you explore?',
                  style: TextStyle(
                    fontSize: 12,
                    color: WandererColors.textMuted.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          _StepBtn(icon: Icons.remove_rounded, onTap: () => onDelta(-1), enabled: days > 1),
          const SizedBox(width: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              '$days',
              key: ValueKey(days),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: WandererColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          _StepBtn(icon: Icons.add_rounded, onTap: () => onDelta(1), enabled: days < 30),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  const _StepBtn({required this.icon, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? WandererColors.primary.withValues(alpha: 0.12)
              : WandererColors.surfaceLight,
          border: Border.all(
            color: enabled
                ? WandererColors.primary.withValues(alpha: 0.6)
                : WandererColors.surfaceLight,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? WandererColors.primary : WandererColors.textMuted,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String tierName;
  final int days;
  final int total;
  final VoidCallback onContinue;

  const _BottomBar({
    required this.tierName,
    required this.days,
    required this.total,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: WandererColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(
          top: BorderSide(color: WandererColors.surfaceLight.withValues(alpha: 0.6)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$tierName · $days ${days == 1 ? 'day' : 'days'}',
                    style: const TextStyle(
                      color: WandererColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      '\u20B9$total',
                      key: ValueKey(total),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: WandererColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WandererColors.primary,
                    foregroundColor: WandererColors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Start exploring',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 12, color: WandererColors.textMuted.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Text(
                'Cancel anytime · Secure payment by Razorpay',
                style: TextStyle(
                  fontSize: 11,
                  color: WandererColors.textMuted.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    WandererColors.primary.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    WandererColors.secondary.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
