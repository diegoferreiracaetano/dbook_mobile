import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const labels = ['Todos', 'América do Sul', 'Europa'];

  testWidgets('given labels when built then every one renders', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: Scaffold(
          body: DbookChipRow(
            labels: labels,
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('América do Sul'), findsOneWidget);
    expect(find.text('Europa'), findsOneWidget);
  });

  testWidgets('given a tap on another chip then onSelected receives its index', (
    tester,
  ) async {
    int? tappedIndex;

    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: Scaffold(
          body: DbookChipRow(
            labels: labels,
            selectedIndex: 0,
            onSelected: (index) => tappedIndex = index,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Europa'));
    expect(tappedIndex, 2);
  });
}
