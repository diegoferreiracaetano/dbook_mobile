import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given a page count when built then that many dots render', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DbookPageIndicator(pageCount: 3, currentIndex: 1)),
      ),
    );

    expect(find.byType(AnimatedContainer), findsNWidgets(3));
  });
}
