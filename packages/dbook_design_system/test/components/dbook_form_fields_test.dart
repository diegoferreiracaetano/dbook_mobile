import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: DbookTheme.light,
  home: Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(child: Form(child: child)),
    ),
  ),
);

String? _required(String? v) => (v == null || v.isEmpty) ? 'Obrigatório' : null;

void main() {
  group('DbookTextField', () {
    testWidgets('given a validator when the user types and clears then the '
        'error shows in line, without submitting', (tester) async {
      await tester.pumpWidget(
        _host(const DbookTextField(label: 'Nome', validator: _required)),
      );

      expect(find.text('Obrigatório'), findsNothing);
      await tester.enterText(find.byType(TextFormField), 'a');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      expect(find.text('Obrigatório'), findsOneWidget);
    });

    testWidgets('given an error when read by a screen reader then it is a '
        'live region', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(const DbookTextField(label: 'Nome', validator: _required)),
      );

      await tester.enterText(find.byType(TextFormField), 'a');
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      final live = tester
          .widgetList<Semantics>(
            find.ancestor(
              of: find.text('Obrigatório'),
              matching: find.byType(Semantics),
            ),
          )
          .where((s) => s.properties.liveRegion == true);
      expect(live, isNotEmpty);
      handle.dispose();
    });

    testWidgets('given the label when built then the field is named by it', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DbookTextField(label: 'E-mail')));

      expect(find.bySemanticsLabel(RegExp('E-mail')), findsWidgets);
      handle.dispose();
    });

    testWidgets('given obscureText when built then it stays single line', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DbookTextField(label: 'Senha', obscureText: true, maxLines: 4),
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.maxLines, 1);
    });
  });

  group('DbookTextArea', () {
    testWidgets('given a max length when typing then the counter shows the '
        'used characters', (tester) async {
      await tester.pumpWidget(
        _host(const DbookTextArea(label: 'Nota interna', maxLength: 500)),
      );

      await tester.enterText(
        find.byType(TextFormField),
        'Cliente pediu retorno',
      );
      await tester.pump();

      expect(find.text('21/500'), findsOneWidget);
    });

    testWidgets('given a max length when typing past it then the extra text '
        'is not accepted', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _host(
          DbookTextArea(label: 'Nota', maxLength: 5, controller: controller),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '1234567');

      expect(controller.text, '12345');
    });
  });

  group('DbookSelect', () {
    testWidgets('given options when one is picked then reports its value', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(
        _host(
          DbookSelect<String>(
            label: 'Papel',
            options: const [
              DbookSelectOption(value: 'support', label: 'Suporte'),
              DbookSelectOption(value: 'catalog', label: 'Catálogo'),
            ],
            onChanged: (v) => picked = v,
          ),
        ),
      );

      await tester.tap(find.text('Papel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Catálogo').last);
      await tester.pumpAndSettle();

      expect(picked, 'catalog');
    });

    testWidgets('given a validator when an empty selection is validated '
        'then the error shows', (tester) async {
      final key = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: Scaffold(
            body: Form(
              key: key,
              child: DbookSelect<String>(
                label: 'Papel',
                options: const [DbookSelectOption(value: 'a', label: 'A')],
                onChanged: (_) {},
                validator: (v) => v == null ? 'Escolha um papel' : null,
              ),
            ),
          ),
        ),
      );

      key.currentState!.validate();
      await tester.pump();

      expect(find.text('Escolha um papel'), findsOneWidget);
    });
  });

  group('DbookDateRange', () {
    testWidgets('given a value when built then shows both dates', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DbookDateRange(
            label: 'Período',
            value: DateTimeRange(
              start: DateTime(2026, 10, 1),
              end: DateTime(2026, 10, 7),
            ),
            onChanged: (_) {},
            firstDate: DateTime(2026),
            lastDate: DateTime(2026, 12, 31),
          ),
        ),
      );

      expect(find.text('01/10/2026 – 07/10/2026'), findsOneWidget);
    });

    testWidgets('given the field when tapped then the range picker opens', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DbookDateRange(
            label: 'Período',
            onChanged: (_) {},
            firstDate: DateTime(2026),
            lastDate: DateTime(2026, 12, 31),
          ),
        ),
      );

      await tester.tap(find.text('Período'));
      await tester.pumpAndSettle();

      expect(find.byType(DateRangePickerDialog), findsOneWidget);
    });
  });
}
