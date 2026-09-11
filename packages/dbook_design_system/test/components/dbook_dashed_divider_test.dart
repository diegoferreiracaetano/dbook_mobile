import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given default sizing when built then it fills the width', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DbookDashedDivider())),
    );

    expect(find.byType(DbookDashedDivider), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
