import 'package:flutter_test/flutter_test.dart';
import 'package:wanderer_app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: WandererApp()),
    );
    expect(find.text('Wanderer'), findsOneWidget);
  });
}
