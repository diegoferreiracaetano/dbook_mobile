import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given a label when built then renders the label text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: const Scaffold(
          body: DbookLegendItem(label: 'Ocupado', color: Colors.grey),
        ),
      ),
    );

    expect(find.text('Ocupado'), findsOneWidget);
  });
}
