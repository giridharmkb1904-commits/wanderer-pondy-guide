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

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _phoneController = TextEditingController();
  String _countryCode = '+91';

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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              const Text('Wanderer', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: WandererColors.primary)),
              const SizedBox(height: 8),
              const Text(
                'Your AI tour guide.\nDiscover Pondicherry like a local.',
                style: TextStyle(fontSize: 18, color: WandererColors.textSecondary, height: 1.4),
              ),
              const Spacer(flex: 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(color: WandererColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
                    child: DropdownButton<String>(
                      value: _countryCode,
                      dropdownColor: WandererColors.surface,
                      style: const TextStyle(color: WandererColors.textPrimary),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: '+91', child: Text('+91')),
                        DropdownMenuItem(value: '+1', child: Text('+1')),
                        DropdownMenuItem(value: '+33', child: Text('+33')),
                        DropdownMenuItem(value: '+44', child: Text('+44')),
                      ],
                      onChanged: (v) => setState(() => _countryCode = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: WandererColors.textPrimary, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        filled: true,
                        fillColor: WandererColors.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WandererColors.primary,
                    foregroundColor: WandererColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: WandererColors.background)
                      : const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Text(auth.error!, style: const TextStyle(color: WandererColors.error)),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
