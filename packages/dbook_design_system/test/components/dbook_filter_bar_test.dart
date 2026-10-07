import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _today = DateTime(2026, 10, 7);

Widget _host(Widget bar) => MaterialApp(
  theme: DbookTheme.light,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: bar),
  ),
);

DbookFilterBar _bar({
  String text = '',
  ValueChanged<String>? onSearch,
  VoidCallback? onClear,
  DateTimeRange? period,
  ValueChanged<DateTimeRange?>? onPeriod,
  List<DbookActiveFilter> filters = const [],
}) => DbookFilterBar(
  searchText: text,
  onSearchChanged: onSearch ?? (_) {},
  onClearAll: onClear ?? () {},
  period: period,
  onPeriodChanged: onPeriod,
  activeFilters: filters,
  today: () => _today,
);

void main() {
  group('search debounce', () {
    testWidgets('given typing when 300ms pass then reports once, with the '
        'last text', (tester) async {
      final reported = <String>[];
      await tester.pumpWidget(_host(_bar(onSearch: reported.add)));

      await tester.enterText(find.byType(TextField), 'di');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'diego');
      await tester.pump(const Duration(milliseconds: 299));
      expect(reported, isEmpty);

      await tester.pump(const Duration(milliseconds: 1));
      expect(reported, ['diego']);
    });

    testWidgets('given a pending search when Enter is pressed then reports '
        'now and does not report again', (tester) async {
      final reported = <String>[];
      await tester.pumpWidget(_host(_bar(onSearch: reported.add)));

      await tester.enterText(find.byType(TextField), 'ana');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump(const Duration(seconds: 1));

      expect(reported, ['ana']);
    });

    testWidgets('given the bar is removed while a search is pending then '
        'nothing is reported afterwards', (tester) async {
      final reported = <String>[];
      await tester.pumpWidget(_host(_bar(onSearch: reported.add)));

      await tester.enterText(find.byType(TextField), 'ana');
      await tester.pumpWidget(_host(const SizedBox()));
      await tester.pump(const Duration(seconds: 1));

      expect(reported, isEmpty);
    });

    testWidgets('given text typed when the clear button is tapped then '
        'reports empty immediately', (tester) async {
      final reported = <String>[];
      await tester.pumpWidget(_host(_bar(onSearch: reported.add)));

      await tester.enterText(find.byType(TextField), 'ana');
      await tester.pump();
      await tester.tap(find.byTooltip('Limpar busca'));
      await tester.pump(const Duration(seconds: 1));

      expect(reported, ['']);
    });

    testWidgets('given the parent changes the text (URL restored) when '
        'rebuilt then the field shows it', (tester) async {
      await tester.pumpWidget(_host(_bar(text: 'a')));
      await tester.pumpWidget(_host(_bar(text: 'restaurado')));

      expect(find.text('restaurado'), findsOneWidget);
    });
  });

  group('active filters and clear all', () {
    testWidgets('given active filters when a chip is removed then its '
        'callback fires', (tester) async {
      var removed = false;
      await tester.pumpWidget(
        _host(
          _bar(
            filters: [
              DbookActiveFilter(
                id: 'status',
                label: 'Status: Ativo',
                onRemove: () => removed = true,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byTooltip('Remover filtro Status: Ativo'));

      expect(removed, isTrue);
    });

    testWidgets('given no filter when built then there is no "Limpar tudo"', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_bar()));

      expect(find.text('Limpar tudo'), findsNothing);
    });

    testWidgets('given a filter when "Limpar tudo" is tapped then clears '
        'the field and reports', (tester) async {
      var cleared = false;
      await tester.pumpWidget(
        _host(_bar(text: 'ana', onClear: () => cleared = true)),
      );

      await tester.tap(find.text('Limpar tudo'));
      await tester.pump();

      expect(cleared, isTrue);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    });
  });

  group('period', () {
    testWidgets('given no onPeriodChanged when built then there is no period '
        'selector', (tester) async {
      await tester.pumpWidget(_host(_bar()));

      expect(find.text('Qualquer período'), findsNothing);
    });

    testWidgets('given the 7 days preset when picked then reports today and '
        'the 6 days before it', (tester) async {
      DateTimeRange? picked;
      await tester.pumpWidget(_host(_bar(onPeriod: (r) => picked = r)));

      await tester.tap(find.text('Qualquer período'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Últimos 7 dias'));
      await tester.pumpAndSettle();

      expect(picked?.end, _today);
      expect(picked?.start, DateTime(2026, 10, 1));
    });

    testWidgets('given a period when built then the label shows both dates '
        'and "Qualquer período" clears it', (tester) async {
      DateTimeRange? picked = DateTimeRange(
        start: DateTime(2026, 10, 1),
        end: _today,
      );
      var cleared = false;
      await tester.pumpWidget(
        _host(
          _bar(
            period: picked,
            onPeriod: (r) {
              picked = r;
              cleared = r == null;
            },
          ),
        ),
      );

      expect(find.text('01/10/2026 – 07/10/2026'), findsOneWidget);
      await tester.tap(find.text('01/10/2026 – 07/10/2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Qualquer período'));
      await tester.pumpAndSettle();

      expect(cleared, isTrue);
    });
  });
}
