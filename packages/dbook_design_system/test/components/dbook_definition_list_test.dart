import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(double width, Widget child) => MaterialApp(
  theme: DbookTheme.light,
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

const _items = [
  DbookDefinition(label: 'E-mail', value: 'diego@dbook.com'),
  DbookDefinition(label: 'Telefone'),
  DbookDefinition(
    label: 'Status',
    child: DbookStatusBadge(status: DbookStatus.confirmed, label: 'Ativo'),
  ),
];

void main() {
  testWidgets('given a missing value when built then shows a dash', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(600, const DbookDefinitionList(items: _items)),
    );

    expect(find.text('—'), findsOneWidget);
    expect(find.text('diego@dbook.com'), findsOneWidget);
    expect(find.byType(DbookStatusBadge), findsOneWidget);
  });

  testWidgets('given a wide area when built then label and value share a row', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(600, const DbookDefinitionList(items: _items)),
    );

    final label = tester.getTopLeft(find.text('E-mail'));
    final value = tester.getTopLeft(find.text('diego@dbook.com'));
    expect(value.dy, label.dy);
    expect(value.dx, greaterThan(label.dx));
  });

  testWidgets('given a narrow area when built then the value goes below the '
      'label', (tester) async {
    await tester.pumpWidget(
      _host(320, const DbookDefinitionList(items: _items)),
    );

    final label = tester.getTopLeft(find.text('E-mail'));
    final value = tester.getTopLeft(find.text('diego@dbook.com'));
    expect(value.dy, greaterThan(label.dy));
    expect(value.dx, label.dx);
  });

  testWidgets('given a text value when built then it is selectable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(600, const DbookDefinitionList(items: _items)),
    );

    expect(find.byType(SelectableText), findsWidgets);
  });
}
