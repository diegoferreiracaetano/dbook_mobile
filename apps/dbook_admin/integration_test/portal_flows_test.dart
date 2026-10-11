import 'package:dbook_admin/main.dart' as app;
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'e2e_api.dart';

/// Fluxos de ponta a ponta do portal **contra o backend real** (nada é
/// falso). Rodam num Chrome de verdade (`flutter drive`); veja
/// `.github/workflows/e2e-portal.yml` e `docs/portal.md`.
///
/// Variáveis (`--dart-define`): `API_BASE_URL`, `E2E_ADMIN_EMAIL` e
/// `E2E_ADMIN_PASSWORD` (um `SUPER_ADMIN`, o mesmo do `bootstrap-admin`).
const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080/v1',
);
const _adminEmail = String.fromEnvironment('E2E_ADMIN_EMAIL');
const _adminPassword = String.fromEnvironment('E2E_ADMIN_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations t;
  late E2eApi api;
  late String adminToken;

  setUpAll(() async {
    expect(_adminEmail, isNotEmpty, reason: 'defina E2E_ADMIN_EMAIL');
    t = await AppLocalizations.delegate.load(const Locale('pt'));
    api = E2eApi(baseUrl: _baseUrl);
    adminToken = await api.adminToken(_adminEmail, _adminPassword);
  });

  Future<void> settle(WidgetTester tester, [int seconds = 2]) async {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      Duration(seconds: seconds + 20),
    );
  }

  Future<void> signIn(WidgetTester tester) async {
    app.main();
    await settle(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, t.loginEmail),
      _adminEmail,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, t.loginPassword),
      _adminPassword,
    );
    await tester.tap(find.text(t.loginSubmit));
    await settle(tester);
  }

  void go(WidgetTester tester, String path) {
    final context = tester.element(find.byType(Scaffold).first);
    GoRouter.of(context).go(path);
  }

  testWidgets('login, buscar cliente, bloquear e ver na auditoria', (
    tester,
  ) async {
    final customer = await api.registerCustomer();

    await signIn(tester);
    expect(find.textContaining('Olá'), findsWidgets);

    go(tester, '/customers');
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, customer.email);
    await tester.pump(const Duration(milliseconds: 400)); // debounce de 300 ms
    await settle(tester);
    await tester.tap(find.text(customer.email).first);
    await settle(tester);

    await tester.tap(find.text(t.customerBlock));
    await settle(tester);
    await tester.enterText(
      find.byType(TextField).last,
      'Bloqueio de teste de ponta a ponta',
    );
    await tester.pump();
    await tester.tap(
      find.widgetWithText(ElevatedButton, t.customerBlockSubmit),
    );
    await settle(tester);
    expect(find.textContaining(t.customerStatusBlocked), findsWidgets);

    go(tester, '/audit?action=CUSTOMER_BLOCKED');
    await settle(tester);
    expect(find.text(t.auditActionCustomerBlocked), findsWidgets);
  });

  testWidgets('convidar uma pessoa para a equipe', (tester) async {
    await signIn(tester);
    go(tester, '/team');
    await settle(tester);

    await tester.tap(find.text(t.teamInvite));
    await settle(tester);
    final email = 'convite${api.uniqueSuffix()}@dbook.test';
    await tester.enterText(
      find.widgetWithText(TextFormField, t.inviteEmail),
      email,
    );
    await tester.tap(find.text(t.inviteSubmit));
    await settle(tester);

    await tester.tap(find.text(t.teamTabInvitations));
    await settle(tester);
    expect(find.text(email), findsOneWidget);
  });

  testWidgets('reembolsar uma reserva paga', (tester) async {
    final customer = await api.registerCustomer();
    final flightId = await api.createFlight(adminToken);
    final bookingId = await api.paidBooking(
      customerToken: customer.token,
      flightId: flightId,
    );

    await signIn(tester);
    go(tester, '/bookings/$bookingId');
    await settle(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, t.bookingRefund));
    await settle(tester);
    expect(find.text(t.refundSubmit), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, t.refundSubmit));
    await settle(tester, 5);

    expect(find.text(t.bookingStatusRefunded), findsWidgets);
  });

  testWidgets('edição concorrente de voo mostra o conflito', (tester) async {
    final flightId = await api.createFlight(adminToken);

    await signIn(tester);
    go(tester, '/flights/$flightId');
    await settle(tester);

    // outra pessoa salva o voo depois que esta tela o leu
    await api.bumpFlightPrice(adminToken, flightId);

    await tester.tap(find.widgetWithText(ElevatedButton, t.flightFormSave));
    await settle(tester);

    expect(find.text(t.conflictTitle), findsOneWidget);
  });
}
