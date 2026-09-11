import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given text typed and submit button tapped then onSubmitted receives the text',
    (tester) async {
      final controller = TextEditingController();
      String? submitted;

      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: Scaffold(
            body: DbookSearchField(
              controller: controller,
              onSubmitted: (value) => submitted = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'voo pra Madri');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(submitted, 'voo pra Madri');
    },
  );
}
