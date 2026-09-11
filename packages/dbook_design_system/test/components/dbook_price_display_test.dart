import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given amount and caption when built then both render', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DbookPriceDisplay(amount: 'R\$ 612', caption: 'por pessoa'),
        ),
      ),
    );

    expect(find.text('R\$ 612'), findsOneWidget);
    expect(find.text('por pessoa'), findsOneWidget);
  });

  testWidgets('given no caption when built then only the amount renders', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DbookPriceDisplay(amount: 'R\$ 612')),
      ),
    );

    expect(find.text('R\$ 612'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });
}
