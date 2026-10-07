import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: DbookTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('given a trail when a parent is tapped then its callback fires', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _host(
        DbookBreadcrumbs(
          items: [
            DbookBreadcrumbItem(label: 'Clientes', onTap: () => tapped = true),
            const DbookBreadcrumbItem(label: 'Diego Ferreira'),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Clientes'));

    expect(tapped, isTrue);
  });

  testWidgets('given a trail when read by a screen reader then the last '
      'step is announced as the current page', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        DbookBreadcrumbs(
          items: [
            DbookBreadcrumbItem(label: 'Clientes', onTap: () {}),
            const DbookBreadcrumbItem(label: 'Diego Ferreira'),
          ],
        ),
      ),
    );

    expect(
      find.bySemanticsLabel('Página atual: Diego Ferreira'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('given a trail when focused with Tab and activated with Enter '
      'then the parent step fires', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _host(
        DbookBreadcrumbs(
          items: [
            DbookBreadcrumbItem(label: 'Clientes', onTap: () => tapped = true),
            const DbookBreadcrumbItem(label: 'Diego Ferreira'),
          ],
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);

    expect(tapped, isTrue);
  });
}
