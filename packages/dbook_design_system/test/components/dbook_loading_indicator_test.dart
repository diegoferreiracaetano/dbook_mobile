import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given a message when built then skeleton rows and message render',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DbookLoadingIndicator(message: 'Buscando voos...'),
          ),
        ),
      );

      expect(find.byType(DbookSkeleton), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Buscando voos...'), findsOneWidget);
    },
  );

  testWidgets('given no message when built then only skeletons render', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DbookLoadingIndicator())),
    );

    expect(find.byType(DbookSkeleton), findsWidgets);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('given a small slot when built then falls back to the spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(height: 80, child: DbookLoadingIndicator()),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(DbookSkeleton), findsNothing);
  });
}
