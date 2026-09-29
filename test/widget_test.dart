import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brutal_wallz/main.dart';

/// Top-level smoke test verifying the [MyApp] widget tree instantiates
/// properly with mocked [SharedPreferences].
void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Provide empty in-memory mock initial values for SharedPreferences
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();

    // Pump root application widget
    await tester.pumpWidget(const MyApp());

    // Verify root widget exists in tree
    expect(find.byType(MyApp), findsOneWidget);
  });
}
