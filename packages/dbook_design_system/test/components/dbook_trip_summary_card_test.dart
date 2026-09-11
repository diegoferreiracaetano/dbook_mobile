import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given full mode when built then each field renders separately', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: const Scaffold(
          body: DbookTripSummaryCard(
            origin: 'São Paulo (GRU)',
            destination: 'Madrid (MAD)',
            dateRangeLabel: 'Jan 13 - Jan 30, 2026',
            passengersLabel: '1 Adult, Economy',
          ),
        ),
      ),
    );

    expect(find.text('São Paulo (GRU)'), findsOneWidget);
    expect(find.text('Madrid (MAD)'), findsOneWidget);
    expect(find.text('Jan 13 - Jan 30, 2026'), findsOneWidget);
    expect(find.text('1 Adult, Economy'), findsOneWidget);
    expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
  });

  testWidgets(
    'given full mode when From and To are tapped then each fires its own '
    'callback',
    (tester) async {
      var originTaps = 0;
      var destinationTaps = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: Scaffold(
            body: DbookTripSummaryCard(
              origin: 'São Paulo (GRU)',
              destination: 'Madrid (MAD)',
              dateRangeLabel: 'Jan 13 - Jan 30, 2026',
              passengersLabel: '1 Adult, Economy',
              onTapRoute: () => originTaps++,
              onTapDestination: () => destinationTaps++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('From'));
      await tester.tap(find.text('To'));

      expect(originTaps, 1);
      expect(destinationTaps, 1);
    },
  );

  testWidgets(
    'given compact mode when built then route and summary render on one '
    'line and tap fires',
    (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: Scaffold(
            body: DbookTripSummaryCard(
              origin: 'GRU',
              destination: 'MAD',
              dateRangeLabel: 'Jan 13 - Jan 30',
              passengersLabel: '1 Adult',
              compact: true,
              onTapRoute: () => tapCount++,
            ),
          ),
        ),
      );

      expect(find.text('GRU → MAD'), findsOneWidget);
      expect(find.text('Jan 13 - Jan 30 · 1 Adult'), findsOneWidget);

      await tester.tap(find.byType(DbookTripSummaryCard));
      expect(tapCount, 1);
    },
  );
}
