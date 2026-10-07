import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _Customer {
  const _Customer(this.id, this.name, this.bookings);

  final int id;
  final String name;
  final int bookings;
}

const _rows = [
  _Customer(1, 'Ana Souza', 3),
  _Customer(2, 'Bruno Lima', 12),
  _Customer(3, 'Carla Dias', 0),
];

final _columns = <DbookColumn<_Customer>>[
  DbookColumn(
    id: 'name',
    label: 'Nome',
    sortable: true,
    cellBuilder: (c) => Text(c.name),
  ),
  DbookColumn(
    id: 'bookings',
    label: 'Reservas',
    numeric: true,
    width: 120,
    cellBuilder: (c) => Text('${c.bookings}'),
  ),
];

Widget _host(Widget table, {double width = 700, double height = 400}) =>
    MaterialApp(
      theme: DbookTheme.light,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, height: height, child: table),
        ),
      ),
    );

DbookDataTable<_Customer> _table({
  List<_Customer> rows = _rows,
  DbookSort? sort,
  ValueChanged<DbookSort?>? onSort,
  DbookPagination? pagination,
  Set<Object>? selected,
  ValueChanged<Set<Object>>? onSelection,
  Set<String> hidden = const {},
  ValueChanged<Set<String>>? onHidden,
  ValueChanged<_Customer>? onRowTap,
  bool isLoading = false,
  String? errorMessage,
  VoidCallback? onRetry,
}) => DbookDataTable<_Customer>(
  columns: _columns,
  rows: rows,
  rowKey: (c) => c.id,
  sort: sort,
  onSort: onSort,
  pagination: pagination,
  selectedKeys: selected,
  onSelectionChanged: onSelection,
  hiddenColumnIds: hidden,
  onHiddenColumnsChanged: onHidden,
  onRowTap: onRowTap,
  isLoading: isLoading,
  errorMessage: errorMessage,
  onRetry: onRetry,
);

void main() {
  group('states', () {
    testWidgets('given rows when built then shows header and every row', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_table()));

      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Ana Souza'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('given loading when built then shows skeleton rows and no '
        'data', (tester) async {
      await tester.pumpWidget(_host(_table(isLoading: true)));

      expect(find.byType(DbookSkeleton), findsWidgets);
      expect(find.text('Ana Souza'), findsNothing);
    });

    testWidgets('given an error when retry is tapped then onRetry fires', (
      tester,
    ) async {
      var retried = 0;
      await tester.pumpWidget(
        _host(
          _table(errorMessage: 'Falha ao carregar.', onRetry: () => retried++),
        ),
      );

      expect(find.text('Falha ao carregar.'), findsOneWidget);
      await tester.tap(find.text('Tentar de novo'));
      expect(retried, 1);
    });

    testWidgets('given no rows when built then shows the empty state', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_table(rows: const [])));

      expect(find.text('Nenhum resultado'), findsOneWidget);
    });
  });

  group('sorting (controlled: the server sorts)', () {
    testWidgets('given an unsorted table when a sortable header is tapped '
        'then asks for ascending', (tester) async {
      DbookSort? asked;
      await tester.pumpWidget(_host(_table(onSort: (s) => asked = s)));

      await tester.tap(find.text('Nome'));

      expect(asked, const DbookSort('name', DbookSortDirection.ascending));
    });

    testWidgets('given ascending when tapped again then descending, then '
        'cleared', (tester) async {
      expect(
        DbookSort.next(
          const DbookSort('name', DbookSortDirection.ascending),
          'name',
        ),
        const DbookSort('name', DbookSortDirection.descending),
      );
      expect(
        DbookSort.next(
          const DbookSort('name', DbookSortDirection.descending),
          'name',
        ),
        isNull,
      );
    });

    testWidgets('given a non-sortable header when tapped then nothing is '
        'asked', (tester) async {
      var asked = false;
      await tester.pumpWidget(_host(_table(onSort: (_) => asked = true)));

      await tester.tap(find.text('Reservas'));

      expect(asked, isFalse);
    });

    testWidgets('given a sort when built then the arrow shows and the table '
        'does not reorder the rows itself', (tester) async {
      await tester.pumpWidget(
        _host(
          _table(
            sort: const DbookSort('name', DbookSortDirection.descending),
            onSort: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      final first = tester.getTopLeft(find.text('Ana Souza')).dy;
      final last = tester.getTopLeft(find.text('Carla Dias')).dy;
      expect(first, lessThan(last));
    });

    testWidgets('given a sorted header when read by a screen reader then it '
        'says the direction', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          _table(
            sort: const DbookSort('name', DbookSortDirection.ascending),
            onSort: (_) {},
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Nome, ordenado de forma crescente'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('pagination (server side)', () {
    DbookPagination pagination({
      int page = 0,
      required ValueChanged<int> onPage,
      ValueChanged<int>? onSize,
    }) => DbookPagination(
      page: page,
      pageSize: 25,
      total: 60,
      onPageChanged: onPage,
      onPageSizeChanged: onSize,
    );

    testWidgets('given page 0 of 60 when built then shows 1–25 de 60 and '
        'disables previous', (tester) async {
      await tester.pumpWidget(
        _host(_table(pagination: pagination(onPage: (_) {}))),
      );

      expect(find.text('1–25 de 60'), findsOneWidget);
      final previous = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left),
      );
      expect(previous.onPressed, isNull);
    });

    testWidgets('given the next button when tapped then asks for page 1', (
      tester,
    ) async {
      int? asked;
      await tester.pumpWidget(
        _host(_table(pagination: pagination(onPage: (p) => asked = p))),
      );

      await tester.tap(find.byTooltip('Próxima página'));

      expect(asked, 1);
    });

    testWidgets('given the last page when built then next is disabled and '
        'the range ends at the total', (tester) async {
      await tester.pumpWidget(
        _host(_table(pagination: pagination(page: 2, onPage: (_) {}))),
      );

      expect(find.text('51–60 de 60'), findsOneWidget);
      final next = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(next.onPressed, isNull);
    });

    testWidgets('given a page size change when picked then asks for it', (
      tester,
    ) async {
      int? size;
      await tester.pumpWidget(
        _host(
          _table(
            pagination: pagination(onPage: (_) {}, onSize: (s) => size = s),
          ),
        ),
      );

      await tester.tap(find.text('25'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('50').last);
      await tester.pumpAndSettle();

      expect(size, 50);
    });

    testWidgets('given no total when built then says 0 resultados', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          _table(
            rows: const [],
            pagination: DbookPagination(
              page: 0,
              pageSize: 25,
              total: 0,
              onPageChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('0 resultados'), findsOneWidget);
    });
  });

  group('selection', () {
    testWidgets('given a row checkbox when tapped then reports the new set', (
      tester,
    ) async {
      Set<Object>? reported;
      await tester.pumpWidget(
        _host(_table(selected: const {}, onSelection: (s) => reported = s)),
      );

      await tester.tap(find.byType(Checkbox).at(1));

      expect(reported, {1});
    });

    testWidgets('given the header checkbox when tapped then selects the '
        'whole page, and again clears it', (tester) async {
      var current = <Object>{};
      late StateSetter setState;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, set) {
              setState = set;
              return _table(
                selected: current,
                onSelection: (s) => setState(() => current = s),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();
      expect(current, {1, 2, 3});

      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();
      expect(current, isEmpty);
    });

    testWidgets('given selected rows when built then shows the count and '
        'the header is partially checked', (tester) async {
      await tester.pumpWidget(
        _host(_table(selected: const {2}, onSelection: (_) {})),
      );

      expect(find.text('1 selecionada'), findsOneWidget);
      final header = tester.widget<Checkbox>(find.byType(Checkbox).first);
      expect(header.value, isNull);
    });
  });

  group('column visibility', () {
    testWidgets('given a hidden column when built then it is not shown', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_table(hidden: const {'bookings'})));

      expect(find.text('Reservas'), findsNothing);
      expect(find.text('Nome'), findsOneWidget);
    });

    testWidgets('given the columns menu when a column is unchecked then '
        'reports it hidden', (tester) async {
      Set<String>? reported;
      await tester.pumpWidget(
        _host(_table(hidden: const {}, onHidden: (s) => reported = s)),
      );

      await tester.tap(find.byTooltip('Colunas visíveis'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reservas').last);
      await tester.pumpAndSettle();

      expect(reported, {'bookings'});
    });
  });

  group('layout', () {
    testWidgets('given a narrow area when built then the table scrolls '
        'horizontally instead of overflowing', (tester) async {
      await tester.pumpWidget(_host(_table(), width: 200));

      expect(tester.takeException(), isNull);
      final scroll = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView).first,
      );
      expect(scroll.scrollDirection, Axis.horizontal);
    });

    testWidgets('given a wide area when built then columns grow to fill it', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_table(), width: 780));

      final bookings = tester.getTopRight(find.text('12')).dx;
      expect(bookings, greaterThan(700));
    });
  });

  group('keyboard', () {
    testWidgets('given rows when Tab then ArrowDown then Enter then the '
        'second row opens', (tester) async {
      _Customer? opened;
      await tester.pumpWidget(_host(_table(onRowTap: (c) => opened = c)));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      expect(opened?.id, 2);
    });

    testWidgets('given a focused row when built then a focus ring is drawn', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_table(onRowTap: (_) {})));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final rings = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where(
            (box) =>
                box.position == DecorationPosition.foreground &&
                (box.decoration as BoxDecoration).border != null,
          );
      expect(rings, hasLength(1));
    });
  });
}
