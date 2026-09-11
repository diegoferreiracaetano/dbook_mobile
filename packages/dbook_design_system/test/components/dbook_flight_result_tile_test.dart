import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given flight data when built then renders time, duration and price',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: const Scaffold(
            body: DbookFlightResultTile(
              timeRange: '12:30 – 13:45',
              durationLabel: 'Direto · 1h15m',
              price: 'R\$512',
            ),
          ),
        ),
      );

      expect(find.text('12:30 – 13:45'), findsOneWidget);
      expect(find.text('Direto · 1h15m'), findsOneWidget);
      expect(find.text('R\$512'), findsOneWidget);
    },
  );

  testWidgets(
    'given selected true when built then the card border uses the primary color',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: const Scaffold(
            body: DbookFlightResultTile(
              timeRange: '12:30 – 13:45',
              durationLabel: 'Direto · 1h15m',
              price: 'R\$512',
              selected: true,
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape! as RoundedRectangleBorder;
      expect(shape.side.color, DbookColorScheme.light.primary);
    },
  );
}
