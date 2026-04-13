import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class VoiceButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const VoiceButton({super.key, required this.isListening, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isListening ? WandererColors.primary : WandererColors.surfaceLight,
          border: Border.all(color: WandererColors.primary, width: 2),
          boxShadow: isListening
              ? [BoxShadow(color: WandererColors.primary.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 4)]
              : [],
        ),
        child: Icon(
          isListening ? Icons.stop_rounded : Icons.mic_rounded,
          color: isListening ? WandererColors.background : WandererColors.primary,
          size: 32,
        ),
      ),
    );
  }
}
