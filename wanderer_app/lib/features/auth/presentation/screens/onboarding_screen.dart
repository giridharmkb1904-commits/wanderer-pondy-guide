import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  final _phoneFocus = FocusNode();
  String _countryCode = '+91';
  bool _phoneFocused = false;

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(() {
      if (mounted) setState(() => _phoneFocused = _phoneFocus.hasFocus);
    });
  }

  void _sendOtp() async {
    final raw = _phoneController.text.trim();
    if (raw.isEmpty) return;
    HapticFeedback.selectionClick();
    final phone = '$_countryCode$raw';
    final success = await ref.read(authProvider.notifier).sendOtp(phone);
    if (success && mounted) context.push('/otp', extra: phone);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: WandererColors.background,
      body: Stack(
        children: [
          const _AmbientGlow(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 56),
                  const _GlowOrb()
                      .animate()
                      .fadeIn(duration: 520.ms)
                      .scale(begin: const Offset(0.88, 0.88), end: const Offset(1, 1), duration: 520.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 28),
                  ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [WandererColors.primary, WandererColors.primaryMuted],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(rect),
                    child: const Text(
                      'Wanderer',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -1.4,
                        height: 1,
                      ),
                    ),
                  ).animate().fadeIn(delay: 160.ms, duration: 420.ms).slideY(
                      begin: 0.12, end: 0, delay: 160.ms, duration: 420.ms, curve: Curves.easeOutCubic),
                  const SizedBox(height: 10),
                  const Text(
                    'Your guide to Pondicherry.',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: WandererColors.textPrimary,
                      height: 1.3,
                      letterSpacing: -0.4,
                    ),
                  ).animate().fadeIn(delay: 260.ms, duration: 420.ms),
                  const SizedBox(height: 6),
                  const Text(
                    'Local secrets, French-quarter cafés, quiet beaches. Ask anything.',
                    style: TextStyle(
                      fontSize: 15,
                      color: WandererColors.textSecondary,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 310.ms, duration: 420.ms),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_pills.length, (i) {
                      return _featurePill(_pills[i].$1, _pills[i].$2)
                          .animate()
                          .fadeIn(delay: (380 + i * 60).ms, duration: 340.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            delay: (380 + i * 60).ms,
                            duration: 340.ms,
                            curve: Curves.easeOutCubic,
                          );
                    }),
                  ),
                  const SizedBox(height: 40),
                  _phoneInput()
                      .animate()
                      .fadeIn(delay: 760.ms, duration: 380.ms)
                      .slideY(begin: 0.1, end: 0, delay: 760.ms, duration: 380.ms, curve: Curves.easeOutCubic),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WandererColors.primary,
                        disabledBackgroundColor:
                            WandererColors.primary.withValues(alpha: 0.45),
                        foregroundColor: WandererColors.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: WandererColors.background, strokeWidth: 2.5),
                            )
                          : const Text('Continue',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    ),
                  ).animate().fadeIn(delay: 860.ms, duration: 380.ms),
                  if (auth.error != null) ...[
                    const SizedBox(height: 14),
                    _ErrorLine(message: auth.error!.replaceFirst(RegExp(r'^Exception:\s*'), '')),
                  ],
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      'By continuing, you agree to our Terms & Privacy Policy',
                      style: TextStyle(
                        fontSize: 11,
                        color: WandererColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(delay: 960.ms, duration: 380.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const List<(IconData, String)> _pills = [
    (Icons.chat_bubble_outline_rounded, 'Chat Guide'),
    (Icons.restaurant_menu_rounded, 'AI Booking'),
    (Icons.map_outlined, 'Smart Routes'),
    (Icons.translate_rounded, '4 Languages'),
    (Icons.camera_alt_outlined, 'Camera AI'),
    (Icons.shield_outlined, 'SOS Safety'),
  ];

  Widget _phoneInput() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _phoneFocused
            ? [
                BoxShadow(
                  color: WandererColors.primary.withValues(alpha: 0.18),
                  blurRadius: 18,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: WandererColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: WandererColors.surfaceLight),
            ),
            child: DropdownButton<String>(
              value: _countryCode,
              dropdownColor: WandererColors.surface,
              style: const TextStyle(
                color: WandererColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: WandererColors.textSecondary, size: 18),
              items: const [
                DropdownMenuItem(value: '+91', child: Text('\u{1F1EE}\u{1F1F3}  +91')),
                DropdownMenuItem(value: '+1', child: Text('\u{1F1FA}\u{1F1F8}  +1')),
                DropdownMenuItem(value: '+33', child: Text('\u{1F1EB}\u{1F1F7}  +33')),
                DropdownMenuItem(value: '+44', child: Text('\u{1F1EC}\u{1F1E7}  +44')),
              ],
              onChanged: (v) => setState(() => _countryCode = v!),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: WandererColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _phoneFocused
                      ? WandererColors.primary
                      : WandererColors.surfaceLight,
                  width: _phoneFocused ? 1.6 : 1.2,
                ),
              ),
              child: TextField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                cursorColor: WandererColors.primary,
                style: const TextStyle(
                  color: WandererColors.textPrimary,
                  fontSize: 16,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: 'Your phone number',
                  hintStyle: TextStyle(color: WandererColors.textMuted),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
                onSubmitted: (_) => _sendOtp(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featurePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: WandererColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: WandererColors.surfaceLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: WandererColors.primary),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: WandererColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }
}

class _GlowOrb extends StatefulWidget {
  const _GlowOrb();

  @override
  State<_GlowOrb> createState() => _GlowOrbState();
}

class _GlowOrbState extends State<_GlowOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = Curves.easeInOut.transform(_c.value);
        return Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [WandererColors.primary, WandererColors.primaryMuted],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: WandererColors.primary.withValues(alpha: 0.32 + 0.14 * t),
                blurRadius: 26 + 12 * t,
                spreadRadius: 3 + 2 * t,
              ),
              BoxShadow(
                color: WandererColors.primaryMuted.withValues(alpha: 0.18 + 0.1 * t),
                blurRadius: 50 + 14 * t,
                spreadRadius: 6,
              ),
            ],
          ),
          child: const Icon(Icons.explore, color: Colors.white, size: 32),
        );
      },
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
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    WandererColors.primary.withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    WandererColors.primaryMuted.withValues(alpha: 0.10),
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

class _ErrorLine extends StatelessWidget {
  final String message;
  const _ErrorLine({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: WandererColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WandererColors.error.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 16, color: WandererColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: WandererColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
