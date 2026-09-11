import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given title and message when built then both render, with no optional '
    'content',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DbookSuccessScreen(
              title: 'Booking Confirmed!',
              message: 'Your flight to Madrid is all set.',
            ),
          ),
        ),
      );

      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(find.text('Your flight to Madrid is all set.'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
    },
  );

  testWidgets(
    'given a reference and both actions when built then everything renders '
    'and taps fire',
    (tester) async {
      var copyCount = 0;
      var primaryCount = 0;
      var secondaryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DbookSuccessScreen(
              title: 'Booking Confirmed!',
              message: 'Your flight to Madrid is all set.',
              referenceLabel: 'Booking Reference',
              referenceValue: 'HF123456',
              onCopyReference: () => copyCount++,
              primaryActionLabel: 'View My Trip',
              onPrimaryAction: () => primaryCount++,
              secondaryActionLabel: 'Back to Home',
              onSecondaryAction: () => secondaryCount++,
            ),
          ),
        ),
      );

      expect(find.text('HF123456'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.copy));
      expect(copyCount, 1);

      await tester.tap(find.text('View My Trip'));
      expect(primaryCount, 1);

      await tester.tap(find.text('Back to Home'));
      expect(secondaryCount, 1);
    },
  );
}
