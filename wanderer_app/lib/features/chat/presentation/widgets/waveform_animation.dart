import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class WaveformAnimation extends StatefulWidget {
  final bool isActive;
  const WaveformAnimation({super.key, this.isActive = false});

  @override
  State<WaveformAnimation> createState() => _WaveformAnimationState();
}

class _WaveformAnimationState extends State<WaveformAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 60),
          painter: _WaveformPainter(progress: _controller.value, isActive: widget.isActive),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final bool isActive;

  _WaveformPainter({required this.progress, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? WandererColors.primary : WandererColors.primary.withValues(alpha: 0.3)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const barCount = 20;
    final barWidth = size.width / (barCount * 2);

    for (var i = 0; i < barCount; i++) {
      final x = (i * 2 + 1) * barWidth;
      final amplitude = isActive ? 0.8 : 0.2;
      final height = (sin((i / barCount * 2 * pi) + (progress * 2 * pi)) * amplitude + 1) * size.height / 3;
      canvas.drawLine(
        Offset(x, size.height / 2 - height / 2),
        Offset(x, size.height / 2 + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) => old.progress != progress || old.isActive != isActive;
}
