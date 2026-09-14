import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given available seat when tapped then onTap fires', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: Scaffold(
          body: DbookSeatCell(
            state: DbookSeatState.available,
            onTap: () => tapCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DbookSeatCell));
    expect(tapCount, 1);
  });

  testWidgets('given occupied seat when tapped then onTap does not fire', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: Scaffold(
          body: DbookSeatCell(
            state: DbookSeatState.occupied,
            onTap: () => tapCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DbookSeatCell));
    expect(tapCount, 0);
  });

  testWidgets('given a label when built then it is visible in the cell', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: const Scaffold(
          body: DbookSeatCell(state: DbookSeatState.available, label: '12A'),
        ),
      ),
    );

    expect(find.text('12A'), findsOneWidget);
  });

  testWidgets('given no label when built then the cell renders with no text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: const Scaffold(
          body: DbookSeatCell(state: DbookSeatState.selected),
        ),
      ),
    );

    expect(find.byType(Text), findsNothing);
  });
}
