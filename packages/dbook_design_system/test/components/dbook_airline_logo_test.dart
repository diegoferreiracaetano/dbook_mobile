import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: DbookTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('given no logo url when built then shows the IATA badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const DbookAirlineLogo(iataCode: 'LA', color: Colors.red)),
    );

    expect(find.text('LA'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('given a logo url when built then asks for the image', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DbookAirlineLogo(
          iataCode: 'LA',
          color: Colors.red,
          logoUrl: 'https://example.invalid/LA.png',
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });
}
