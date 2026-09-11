import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given a custom size when built then renders at that size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DbookQrPlaceholder(size: 80))),
    );

    final size = tester.getSize(find.byType(DbookQrPlaceholder));
    expect(size, const Size(80, 80));
  });
}
