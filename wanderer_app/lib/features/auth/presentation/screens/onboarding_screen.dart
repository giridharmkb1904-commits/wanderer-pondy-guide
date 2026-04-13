import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  String _countryCode = '+91';
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.2, 0.8, curve: Curves.easeOut)),
    );
    _animController.forward();
  }

  void _sendOtp() async {
    final phone = '$_countryCode${_phoneController.text.trim()}';
    final success = await ref.read(authProvider.notifier).sendOtp(phone);
    if (success && mounted) {
      context.push('/otp', extra: phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: WandererColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Animated logo area
              FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Glowing orb
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [WandererColors.primary, WandererColors.primaryMuted],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(color: WandererColors.primary.withValues(alpha: 0.3), blurRadius: 24, spreadRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.explore, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 24),
                      const Text('Wanderer', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: WandererColors.primary, letterSpacing: -1)),
                      const SizedBox(height: 8),
                      const Text(
                        'Your AI tour guide.\nDiscover Pondicherry like a local.',
                        style: TextStyle(fontSize: 18, color: WandererColors.textSecondary, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Feature pills
              FadeTransition(
                opacity: _fadeIn,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _featurePill(Icons.mic, 'Voice Guide'),
                    _featurePill(Icons.restaurant, 'AI Booking'),
                    _featurePill(Icons.map, 'Smart Routes'),
                    _featurePill(Icons.translate, '4 Languages'),
                    _featurePill(Icons.camera_alt, 'Camera AI'),
                    _featurePill(Icons.shield, 'SOS Safety'),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Phone input
              FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            color: WandererColors.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: WandererColors.surfaceLight),
                          ),
                          child: DropdownButton<String>(
                            value: _countryCode,
                            dropdownColor: WandererColors.surface,
                            style: const TextStyle(color: WandererColors.textPrimary, fontSize: 16),
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: '+91', child: Text('+91 \u{1F1EE}\u{1F1F3}')),
                              DropdownMenuItem(value: '+1', child: Text('+1 \u{1F1FA}\u{1F1F8}')),
                              DropdownMenuItem(value: '+33', child: Text('+33 \u{1F1EB}\u{1F1F7}')),
                              DropdownMenuItem(value: '+44', child: Text('+44 \u{1F1EC}\u{1F1E7}')),
                            ],
                            onChanged: (v) => setState(() => _countryCode = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: WandererColors.textPrimary, fontSize: 18, letterSpacing: 1),
                            decoration: InputDecoration(
                              hintText: 'Phone number',
                              filled: true,
                              fillColor: WandererColors.surfaceLight,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WandererColors.primary,
                          foregroundColor: WandererColors.background,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: auth.isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: WandererColors.background, strokeWidth: 2.5))
                            : const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    if (auth.error != null) ...[
                      const SizedBox(height: 12),
                      Text(auth.error!, style: const TextStyle(color: WandererColors.error, fontSize: 13)),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Text(
                  'By continuing, you agree to our Terms & Privacy Policy',
                  style: TextStyle(fontSize: 11, color: WandererColors.textMuted.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
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
          Icon(icon, size: 16, color: WandererColors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: WandererColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }
}
