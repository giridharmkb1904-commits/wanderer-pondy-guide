import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/payments/presentation/screens/plan_selection_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/otp', builder: (context, state) {
        final phone = state.extra as String;
        return OtpScreen(phoneNumber: phone);
      }),
      GoRoute(path: '/plans', builder: (context, state) => const PlanSelectionScreen()),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
    ],
  );
});
