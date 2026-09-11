import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given text and icon when built then uppercased text and icon render',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DbookSectionLabel(
              text: 'sugestões pra você',
              icon: Icons.star_outline,
            ),
          ),
        ),
      );

      expect(find.text('SUGESTÕES PRA VOCÊ'), findsOneWidget);
      expect(find.byIcon(Icons.star_outline), findsOneWidget);
    },
  );
}
