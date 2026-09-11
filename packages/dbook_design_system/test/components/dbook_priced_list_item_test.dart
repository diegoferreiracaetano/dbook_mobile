import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given title, subtitle and price when built then all render and tap fires',
    (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: Scaffold(
            body: DbookPricedListItem(
              icon: Icons.event_seat_outlined,
              title: 'Seat Selection',
              subtitle: 'Choose your seat',
              price: '\$15',
              onTap: () => tapCount++,
            ),
          ),
        ),
      );

      expect(find.text('Seat Selection'), findsOneWidget);
      expect(find.text('Choose your seat'), findsOneWidget);
      expect(find.text('\$15'), findsOneWidget);

      await tester.tap(find.byType(DbookPricedListItem));
      expect(tapCount, 1);
    },
  );
}
