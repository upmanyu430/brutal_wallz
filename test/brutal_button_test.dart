import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brutal_wallz/components/brutal_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BrutalButton triggers HapticFeedback.mediumImpact on tap down',
      (WidgetTester tester) async {
    final List<MethodCall> log = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BrutalButton(
            color: Colors.yellow,
            shadowOffset: 4.0,
            onTap: () {
              tapped = true;
            },
            child: const Text('Tap Me'),
          ),
        ),
      ),
    );

    // Tap down on the button
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(BrutalButton)));
    await tester.pump();

    // Verify haptic feedback was called on tap down
    expect(
      log.any(
        (call) =>
            call.method == 'HapticFeedback.vibrate' &&
            call.arguments == 'HapticFeedbackType.mediumImpact',
      ),
      isTrue,
    );

    // Complete tap
    await gesture.up();
    await tester.pump();
    expect(tapped, isTrue);
  });
}
