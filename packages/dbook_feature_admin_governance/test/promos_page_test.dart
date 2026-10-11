import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_feature_admin_governance/dbook_feature_admin_governance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGovernanceApi implements GovernanceApi {
  @override
  Future<PageOf<Promo>> promos(PromoQuery query) async => const PageOf(
    items: [
      Promo(
        id: 1,
        code: 'BEMVINDO10',
        type: PromoType.percent,
        value: 10,
        minAmount: 200,
        maxPerUser: 1,
        redeemed: 3,
        active: true,
      ),
    ],
    page: 0,
    size: 20,
    totalElements: 1,
    totalPages: 1,
  );

  @override
  Future<PageOf<AdminReview>> reviews({
    required ReviewQueue queue,
    int page = 0,
    int size = 20,
  }) => throw UnimplementedError();

  @override
  Future<void> hideReview(int id, String reason) => throw UnimplementedError();

  @override
  Future<void> restoreReview(int id) => throw UnimplementedError();

  @override
  Future<void> dismissReports(int id) => throw UnimplementedError();

  @override
  Future<Promo> createPromo(PromoForm form) => throw UnimplementedError();

  @override
  Future<Promo> updatePromo(int id, PromoForm form) =>
      throw UnimplementedError();

  @override
  Future<Promo> setPromoActive(int id, {required bool active}) =>
      throw UnimplementedError();

  @override
  Future<List<PromoRedemption>> redemptions(int id) async => const [];
}

void main() {
  setUpAll(() async {
    await PortalFormats.init();
  });

  testWidgets('given promo codes from the server when built then lists them '
      'with their usage', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          governanceApiProvider.overrideWithValue(_FakeGovernanceApi()),
        ],
        child: MaterialApp(
          theme: DbookTheme.light,
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PromosPage(
              query: (active: null, page: 0, size: 20),
              onQueryChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BEMVINDO10'), findsOneWidget);
  });
}
