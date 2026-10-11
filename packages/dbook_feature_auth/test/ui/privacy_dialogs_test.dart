import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePrivacy implements PrivacyRepository {
  Object? deleteError;
  String? deletedWith;

  @override
  Future<Map<String, dynamic>> exportMyData() async => {
    'profile': {'name': 'Marina Alves', 'email': 'cliente@dbook.test'},
    'bookings': <Object>[],
  };

  @override
  Future<void> deleteMyAccount({required String password}) async {
    deletedWith = password;
    if (deleteError != null) throw deleteError!;
  }
}

Widget _host(_FakePrivacy fake, void Function(BuildContext) open) {
  return ProviderScope(
    overrides: [privacyRepositoryProvider.overrideWithValue(fake)],
    child: MaterialApp(
      theme: DbookTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => open(context),
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('given the export dialog when opened then shows the user data '
      'returned by the server', (tester) async {
    await tester.pumpWidget(
      _host(_FakePrivacy(), (c) => showExportMyDataDialog(c)),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Exportar meus dados'), findsOneWidget);
    expect(
      find.text('Estes são os dados que guardamos sobre você:'),
      findsOneWidget,
    );
    expect(find.text('Copiar tudo (JSON)'), findsOneWidget);
  });

  testWidgets('given the delete dialog when the password is empty then the '
      'confirm button is disabled', (tester) async {
    await tester.pumpWidget(
      _host(
        _FakePrivacy(),
        (c) => showDeleteAccountDialog(c, onDeleted: () {}),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    final confirm = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Excluir minha conta'),
    );
    expect(confirm.onPressed, isNull);
  });

  testWidgets('given the delete dialog when the password is typed and '
      'confirmed then deletes and reports it', (tester) async {
    final fake = _FakePrivacy();
    var deleted = false;
    await tester.pumpWidget(
      _host(
        fake,
        (c) => showDeleteAccountDialog(c, onDeleted: () => deleted = true),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Cliente-2026!');
    await tester.pump();
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Excluir minha conta'),
    );
    await tester.pumpAndSettle();

    expect(fake.deletedWith, 'Cliente-2026!');
    expect(deleted, isTrue);
  });

  testWidgets('given a wrong password when confirming then shows the error '
      'and does not report deletion', (tester) async {
    final fake = _FakePrivacy()
      ..deleteError = const DbookUnauthorizedException('Senha incorreta');
    var deleted = false;
    await tester.pumpWidget(
      _host(
        fake,
        (c) => showDeleteAccountDialog(c, onDeleted: () => deleted = true),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'errada');
    await tester.pump();
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Excluir minha conta'),
    );
    await tester.pumpAndSettle();

    expect(deleted, isFalse);
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
