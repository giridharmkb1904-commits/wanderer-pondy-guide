import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Wanderer',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: WandererColors.primary),
        ),
      ),
    );
  }
}
