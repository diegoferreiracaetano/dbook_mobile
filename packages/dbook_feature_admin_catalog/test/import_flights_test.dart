import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_feature_admin_catalog/dbook_feature_admin_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/portal_harness.dart';

const _csv = 'flightNumber,origin\nDB1,GRU\nDB2,GIG\n';

Object _report({int errors = 0, bool dryRun = true}) => {
  'dryRun': dryRun,
  'totalRows': 2,
  'toCreate': errors == 0 ? 2 : 0,
  'alreadyExisting': 0,
  'created': dryRun ? 0 : 2,
  'errors': [
    for (var i = 0; i < errors; i++)
      {'line': i + 2, 'message': 'preço inválido'},
  ],
};

void main() {
  Future<RecordingDio> pump(
    WidgetTester tester, {
    required Object dry,
    Future<PickedTextFile?> Function()? picker,
  }) async {
    final recorder = RecordingDio(replies: {'POST /admin/flights/import': dry});
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: ImportFlightsPage(onBack: () {}, onDone: () {}),
      overrides: [
        if (picker != null) textFilePickerProvider.overrideWithValue(picker),
      ],
    );
    return recorder;
  }

  testWidgets('given no browser file picker when choosing then explains it '
      'only works in the browser', (tester) async {
    await pump(tester, dry: _report());

    await tester.tap(find.text('Escolher arquivo'));
    await tester.pumpAndSettle();

    expect(
      find.text('Escolher arquivo só funciona no navegador.'),
      findsOneWidget,
    );
  });

  Future<PickedTextFile?> chosen() async =>
      const PickedTextFile(name: 'voos.csv', content: _csv);

  testWidgets('given a valid csv when chosen then simulates first and '
      'only writes after confirming', (tester) async {
    final recorder = await pump(tester, dry: _report(), picker: chosen);

    await tester.tap(find.text('Escolher arquivo'));
    await tester.pumpAndSettle();

    expect(recorder.to('POST', '/admin/flights/import'), hasLength(1));
    expect(find.textContaining('O arquivo está certo.'), findsOneWidget);

    await tester.tap(find.text('Confirmar importação'));
    await tester.pumpAndSettle();

    final posts = recorder.to('POST', '/admin/flights/import').toList();
    expect(posts, hasLength(2));
    expect(find.textContaining('Importação concluída'), findsOneWidget);
  });

  testWidgets('given a csv with bad rows when checked then lists the lines '
      'and offers no confirmation', (tester) async {
    final recorder = await pump(
      tester,
      dry: _report(errors: 2),
      picker: chosen,
    );

    await tester.tap(find.text('Escolher arquivo'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Há linhas com erro. Nada foi gravado.'),
      findsOneWidget,
    );
    expect(find.text('Confirmar importação'), findsNothing);
    expect(recorder.to('POST', '/admin/flights/import'), hasLength(1));
  });
}
