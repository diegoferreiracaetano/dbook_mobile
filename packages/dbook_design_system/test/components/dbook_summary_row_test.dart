import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given label and value when built then both render', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DbookSummaryRow(label: 'Flight (1 adult)', value: '\$450'),
        ),
      ),
    );

    expect(find.text('Flight (1 adult)'), findsOneWidget);
    expect(find.text('\$450'), findsOneWidget);
  });

  testWidgets(
    'given emphasize true when built then the value uses a bold style',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DbookSummaryRow(
              label: 'Total',
              value: '\$585',
              emphasize: true,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('\$585'));
      expect(text.style?.fontWeight, FontWeight.bold);
    },
  );
}
