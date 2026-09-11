import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const options = [
    DbookFareDateOption(dayLabel: 'Sun', dateLabel: '11', price: '\$529'),
    DbookFareDateOption(dayLabel: 'Mon', dateLabel: '12', price: '\$499'),
    DbookFareDateOption(dayLabel: 'Tue', dateLabel: '13', price: '\$450'),
  ];

  testWidgets('given options when built then every day and price renders', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: Scaffold(
          body: DbookFareDateStrip(
            options: options,
            selectedIndex: 2,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Sun 11'), findsOneWidget);
    expect(find.text('Tue 13'), findsOneWidget);
    expect(find.text('\$450'), findsOneWidget);
  });

  testWidgets('given a tap on another day then onSelected receives its index', (
    tester,
  ) async {
    int? tappedIndex;

    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: Scaffold(
          body: DbookFareDateStrip(
            options: options,
            selectedIndex: 2,
            onSelected: (index) => tappedIndex = index,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mon 12'));
    expect(tappedIndex, 1);
  });
}
