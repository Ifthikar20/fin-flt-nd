import 'package:flutter_test/flutter_test.dart';
import 'package:fynda_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FyndaApp()),
    );

    // Fynda branding should appear on splash
    expect(find.text('Fynda'), findsOneWidget);
    expect(find.text('Snap. Search. Save.'), findsOneWidget);
  });
}
