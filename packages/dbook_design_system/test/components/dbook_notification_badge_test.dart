import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given a positive count when built then the badge renders', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: const Scaffold(
          body: DbookNotificationBadge(
            count: 3,
            child: Icon(Icons.notifications_outlined),
          ),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.byType(Badge), findsOneWidget);
  });

  testWidgets('given a zero count when built then no badge renders', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: const Scaffold(
          body: DbookNotificationBadge(
            count: 0,
            child: Icon(Icons.notifications_outlined),
          ),
        ),
      ),
    );

    expect(find.byType(Badge), findsNothing);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
  });
}
