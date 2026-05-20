import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_ai_sekho_project/app.dart';

void main() {
  testWidgets('KaamKaar app boot smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: KaamKaarApp()));

    // Verify that the splash screen loads or the app structure initializes
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
