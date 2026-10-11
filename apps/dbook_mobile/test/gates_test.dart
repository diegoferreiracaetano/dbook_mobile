import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_mobile/account_blocked_gate.dart';
import 'package:dbook_mobile/app_update_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

Widget _app({required Widget gate, List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: DbookTheme.light, home: gate),
    );

Override _update(UpdateInfo info) =>
    appUpdateProvider.overrideWith((ref) async => info);

void main() {
  group('AppUpdateGate', () {
    testWidgets('given an up to date app when it opens then shows the app', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          gate: const AppUpdateGate(child: Scaffold(body: Text('app'))),
          overrides: [_update(UpdateInfo.none)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('app'), findsOneWidget);
      expect(find.text('Atualize o app para continuar'), findsNothing);
    });

    testWidgets('given a version below the minimum when it opens then shows '
        'only the update screen', (tester) async {
      await tester.pumpWidget(
        _app(
          gate: const AppUpdateGate(child: Scaffold(body: Text('app'))),
          overrides: [
            _update(
              const UpdateInfo(
                status: UpdateStatus.required,
                storeUrl: 'https://store.example/dbook',
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Atualize o app para continuar'), findsOneWidget);
      expect(find.text('app'), findsNothing);
    });

    testWidgets('given a newer version available when it opens then shows '
        'the app with a dismissible notice', (tester) async {
      await tester.pumpWidget(
        _app(
          gate: const AppUpdateGate(child: Scaffold(body: Text('app'))),
          overrides: [
            _update(
              const UpdateInfo(
                status: UpdateStatus.available,
                storeUrl: 'https://store.example/dbook',
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('app'), findsOneWidget);
      expect(find.text('Há uma versão nova do app.'), findsOneWidget);

      await tester.tap(find.byTooltip('Dispensar'));
      await tester.pumpAndSettle();

      expect(find.text('Há uma versão nova do app.'), findsNothing);
      expect(find.text('app'), findsOneWidget);
    });

    testWidgets('given the config call fails when it opens then never '
        'blocks the app', (tester) async {
      await tester.pumpWidget(
        _app(
          gate: const AppUpdateGate(child: Scaffold(body: Text('app'))),
          overrides: [
            appUpdateProvider.overrideWith((ref) async => UpdateInfo.none),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('app'), findsOneWidget);
    });
  });

  group('AccountBlockedGate', () {
    testWidgets('given a normal account when built then shows the app', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          gate: const AccountBlockedGate(child: Scaffold(body: Text('app'))),
        ),
      );

      expect(find.text('app'), findsOneWidget);
    });

    testWidgets('given a blocked account when built then shows only the '
        'blocked screen', (tester) async {
      late WidgetRef captured;
      await tester.pumpWidget(
        _app(
          gate: Consumer(
            builder: (context, ref, _) {
              captured = ref;
              return const AccountBlockedGate(
                child: Scaffold(body: Text('app')),
              );
            },
          ),
        ),
      );

      captured.read(accountBlockedProvider.notifier).block();
      await tester.pumpAndSettle();

      expect(find.text('Conta bloqueada'), findsOneWidget);
      expect(find.text('app'), findsNothing);
    });
  });
}
