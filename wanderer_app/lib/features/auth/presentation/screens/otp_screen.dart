import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const int _len = 6;
  final List<TextEditingController> _controllers =
      List.generate(_len, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(_len, (_) => FocusNode());

  Timer? _resendTimer;
  int _secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _nodes.first.requestFocus());
  }

  void _startResendTimer() {
    _secondsLeft = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
        if (mounted) setState(() {});
        return;
      }
      if (mounted) setState(() => _secondsLeft--);
    });
  }

  String get _code => _controllers.map((c) => c.text).join();
  bool get _complete => _code.length == _len;

  void _onDigit(int i, String v) {
    if (v.length > 1) {
      final chars = v.replaceAll(RegExp(r'\D'), '').split('');
      for (var j = 0; j < _len; j++) {
        _controllers[j].text = j < chars.length ? chars[j] : '';
      }
      final last = (chars.length - 1).clamp(0, _len - 1);
      _nodes[last].requestFocus();
      setState(() {});
      if (_complete) _verify();
      return;
    }
    if (v.isNotEmpty && i < _len - 1) {
      _nodes[i + 1].requestFocus();
    }
    setState(() {});
    if (_complete) _verify();
  }

  KeyEventResult _onKey(int i, FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[i].text.isEmpty &&
        i > 0) {
      _controllers[i - 1].clear();
      _nodes[i - 1].requestFocus();
      setState(() {});
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _verify() async {
    if (!_complete) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.selectionClick();
    final success = await ref
        .read(authProvider.notifier)
        .verifyOtp(widget.phoneNumber, _code);
    if (!mounted) return;
    if (success) {
      HapticFeedback.mediumImpact();
      context.pushReplacement('/plans');
    } else {
      HapticFeedback.heavyImpact();
      for (final c in _controllers) {
        c.clear();
      }
      _nodes.first.requestFocus();
      setState(() {});
    }
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0) return;
    HapticFeedback.selectionClick();
    await ref.read(authProvider.notifier).sendOtp(widget.phoneNumber);
    _startResendTimer();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: WandererColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: WandererColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Check your messages',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: WandererColors.textPrimary,
                  letterSpacing: -0.8,
                ),
              ).animate().fadeIn(duration: 360.ms).slideY(
                  begin: 0.15, end: 0, duration: 360.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: WandererColors.textSecondary,
                    fontSize: 15,
                    height: 1.45,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to '),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(
                        color: WandererColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 120.ms, duration: 360.ms),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_len, (i) {
                  return _OtpBox(
                    controller: _controllers[i],
                    focusNode: _nodes[i],
                    onChanged: (v) => _onDigit(i, v),
                    onKey: (node, e) => _onKey(i, node, e),
                  )
                      .animate()
                      .fadeIn(delay: (200 + i * 55).ms, duration: 320.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: (200 + i * 55).ms,
                        duration: 320.ms,
                        curve: Curves.easeOutCubic,
                      );
                }),
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 20),
                _ErrorLine(message: _friendly(auth.error!)),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: (auth.isLoading || !_complete) ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WandererColors.primary,
                    disabledBackgroundColor:
                        WandererColors.primary.withValues(alpha: 0.35),
                    foregroundColor: WandererColors.background,
                    disabledForegroundColor:
                        WandererColors.background.withValues(alpha: 0.65),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: WandererColors.background, strokeWidth: 2.5),
                        )
                      : const Text('Verify',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ).animate().fadeIn(delay: 520.ms, duration: 360.ms),
              const SizedBox(height: 20),
              Center(
                child: _secondsLeft > 0
                    ? RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: WandererColors.textMuted,
                            fontSize: 13,
                          ),
                          children: [
                            const TextSpan(text: "Didn't get the code?  "),
                            TextSpan(
                              text: 'Resend in ${_secondsLeft}s',
                              style: const TextStyle(
                                color: WandererColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Didn't get the code?  ",
                            style: TextStyle(
                              color: WandererColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: _resend,
                            child: const Text(
                              'Resend',
                              style: TextStyle(
                                color: WandererColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
              ).animate().fadeIn(delay: 620.ms, duration: 360.ms),
            ],
          ),
        ),
      ),
    );
  }

  String _friendly(String raw) =>
      raw.replaceFirst(RegExp(r'^Exception:\s*'), '');
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final KeyEventResult Function(FocusNode, KeyEvent) onKey;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKey,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocus);
  }

  void _onFocus() {
    if (!mounted) return;
    if (widget.focusNode.hasFocus != _focused) {
      setState(() => _focused = widget.focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filled = widget.controller.text.isNotEmpty;
    final Color border = _focused
        ? WandererColors.primary
        : filled
            ? WandererColors.primary.withValues(alpha: 0.35)
            : WandererColors.surfaceLight;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48,
      height: 58,
      decoration: BoxDecoration(
        color: WandererColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: _focused ? 1.8 : 1.2),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: WandererColors.primary.withValues(alpha: 0.18),
                  blurRadius: 14,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Focus(
        onKeyEvent: widget.onKey,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          cursorColor: WandererColors.primary,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: widget.onChanged,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: WandererColors.textPrimary,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
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
          const Icon(Icons.error_outline_rounded,
              size: 16, color: WandererColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: WandererColors.error,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
