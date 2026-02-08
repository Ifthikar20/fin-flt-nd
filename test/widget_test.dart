import 'package:flutter_test/flutter_test.dart';
import 'package:fynda_app/main.dart';
import 'package:fynda_app/services/api_client.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      FyndaApp(apiClient: ApiClient()),
    );

    expect(find.text('Fynda'), findsOneWidget);
    expect(find.text('Snap. Search. Save.'), findsOneWidget);
  });
}
