import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _frame(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: DbookTheme.light,
  home: Scaffold(
    body: RepaintBoundary(
      key: const ValueKey('golden'),
      child: ColoredBox(
        color: DbookColorScheme.light.surface,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  ),
);

class _Row {
  const _Row(this.name, this.bookings);

  final String name;
  final int bookings;
}

final _columns = <DbookColumn<_Row>>[
  DbookColumn(
    id: 'name',
    label: 'Nome',
    sortable: true,
    cellBuilder: (r) => Text(r.name),
  ),
  DbookColumn(
    id: 'bookings',
    label: 'Reservas',
    numeric: true,
    width: 120,
    cellBuilder: (r) => Text('${r.bookings}'),
  ),
];

Widget _table({
  List<_Row> rows = const [_Row('Ana Souza', 3), _Row('Bruno Lima', 12)],
  bool loading = false,
  String? error,
  Set<Object>? selected,
  DbookSort? sort,
}) => SizedBox(
  width: 420,
  height: 150,
  child: DbookDataTable<_Row>(
    columns: _columns,
    rows: rows,
    rowKey: (r) => r.name,
    isLoading: loading,
    errorMessage: error,
    onRetry: () {},
    selectedKeys: selected,
    onSelectionChanged: selected == null ? null : (_) {},
    sort: sort,
    onSort: (_) {},
  ),
);

Future<void> _golden(
  WidgetTester tester,
  Widget child,
  Size size,
  String file,
) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_frame(child));
  await tester.pump();
  await expectLater(
    find.byKey(const ValueKey('golden')),
    matchesGoldenFile('goldens/$file'),
  );
}

void main() {
  testWidgets('given the KPI card in each state when drawn then they match '
      'the golden', (tester) async {
    await _golden(
      tester,
      const Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 200,
            child: DbookKpiCard(
              label: 'Receita',
              value: 'R\$ 12.480',
              delta: '+12,5%',
              trend: DbookTrend.up,
              trendIsGood: true,
            ),
          ),
          SizedBox(
            width: 200,
            child: DbookKpiCard(
              label: 'Cancelamentos',
              value: '42',
              delta: '+8%',
              trend: DbookTrend.up,
              trendIsGood: false,
            ),
          ),
          SizedBox(
            width: 200,
            child: DbookKpiCard(label: 'Reservas', isLoading: true),
          ),
          SizedBox(
            width: 200,
            child: DbookKpiCard(
              label: 'Ticket médio',
              errorMessage: 'Indisponível.',
            ),
          ),
        ],
      ),
      const Size(460, 330),
      'kpi_cards.png',
    );
  });

  testWidgets('given the data table in each state when drawn then they '
      'match the golden', (tester) async {
    await _golden(
      tester,
      Column(
        spacing: 12,
        children: [
          _table(
            selected: const {'Bruno Lima'},
            sort: const DbookSort('name', DbookSortDirection.ascending),
          ),
          _table(loading: true),
          _table(rows: const []),
          _table(error: 'Falha ao carregar.'),
        ],
      ),
      const Size(452, 668),
      'data_table_states.png',
    );
  });

  testWidgets('given the status badge with icons when drawn then they match '
      'the golden', (tester) async {
    await _golden(
      tester,
      const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          DbookStatusBadge(
            status: DbookStatus.confirmed,
            label: 'Confirmada',
            showIcon: true,
          ),
          DbookStatusBadge(
            status: DbookStatus.pending,
            label: 'Pendente',
            showIcon: true,
          ),
          DbookStatusBadge(
            status: DbookStatus.cancelled,
            label: 'Cancelada',
            showIcon: true,
          ),
          DbookStatusBadge(
            status: DbookStatus.unknown,
            label: 'Desconhecido',
            showIcon: true,
          ),
        ],
      ),
      const Size(420, 70),
      'status_badges.png',
    );
  });
}
