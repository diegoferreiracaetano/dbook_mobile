import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: DbookTheme.light,
  home: Scaffold(body: SizedBox(width: 200, height: 100, child: child)),
);

void main() {
  testWidgets('given no url when built then shows the neutral frame with the '
      'icon and no network image', (tester) async {
    await tester.pumpWidget(
      _host(const DbookPhoto(url: null, icon: Icons.hotel_outlined)),
    );

    expect(find.byIcon(Icons.hotel_outlined), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('given an empty url when built then falls back too', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const DbookPhoto(url: '')));

    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });

  testWidgets('given a url when built then asks for the network image', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const DbookPhoto(url: 'https://example.invalid/p.jpg')),
    );

    expect(find.byType(Image), findsOneWidget);
  });
}
