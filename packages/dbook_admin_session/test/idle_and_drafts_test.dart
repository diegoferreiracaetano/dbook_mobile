import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// Sessão falsa que só registra o que o `IdleGuard` pediu.
class _RecordingSession extends AdminSessionNotifier {
  final reasons = <SessionEndReason>[];
  var logouts = 0;

  @override
  AdminSessionState build() => const SessionSignedOut();

  @override
  void expire(SessionEndReason reason) => reasons.add(reason);

  @override
  Future<void> logout() async => logouts++;
}

Widget _app({required Widget child, List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );

void main() {
  group('IdleGuard', () {
    final created = <_RecordingSession>[];
    _RecordingSession session() => created.last;

    setUp(created.clear);

    Widget guarded() => _app(
      overrides: [
        adminSessionProvider.overrideWith(() {
          final notifier = _RecordingSession();
          created.add(notifier);
          return notifier;
        }),
        idleTimeoutProvider.overrideWithValue(const Duration(seconds: 10)),
        idleWarningProvider.overrideWithValue(const Duration(seconds: 3)),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          // cria o notifier falso para o teste poder consultá-lo
          ref.watch(adminSessionProvider);
          return const IdleGuard(child: Text('conteúdo'));
        },
      ),
    );

    testWidgets('given no activity when the warning time arrives then asks '
        'if the person is still there', (tester) async {
      await tester.pumpWidget(guarded());

      await tester.pump(const Duration(seconds: 7));

      expect(find.text('Você ainda está aí?'), findsOneWidget);
      expect(session().reasons, isEmpty);
    });

    testWidgets('given the warning when choosing to stay then the session '
        'goes on and the clock restarts', (tester) async {
      await tester.pumpWidget(guarded());
      await tester.pump(const Duration(seconds: 7));

      await tester.tap(find.text('Continuar conectado'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 6));

      expect(find.text('Você ainda está aí?'), findsNothing);
      expect(session().reasons, isEmpty);
    });

    testWidgets('given the warning when nobody answers then the session '
        'expires by idleness', (tester) async {
      await tester.pumpWidget(guarded());

      await tester.pump(const Duration(seconds: 7));
      await tester.pump(const Duration(seconds: 4));

      expect(session().reasons, [SessionEndReason.idle]);
    });

    testWidgets('given the warning when choosing to leave then logs out '
        'instead of marking idle', (tester) async {
      await tester.pumpWidget(guarded());
      await tester.pump(const Duration(seconds: 7));

      await tester.tap(find.text('Sair agora'));
      await tester.pump();

      expect(session().logouts, 1);
      expect(session().reasons, isEmpty);
    });

    testWidgets('given activity before the warning when time passes then '
        'the countdown restarts', (tester) async {
      await tester.pumpWidget(guarded());
      await tester.pump(const Duration(seconds: 5));

      final gesture = await tester.startGesture(const Offset(10, 10));
      await gesture.up();
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('Você ainda está aí?'), findsNothing);
    });
  });

  group('DraftStore', () {
    test('given text when written then it can be read and cleared', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final store = container.read(draftStoreProvider.notifier);

      store.write('note', 'ligar amanhã');
      expect(store.read('note'), 'ligar amanhã');

      store.clear('note');
      expect(store.read('note'), isNull);
    });

    test('given empty text when written then the draft is removed', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final store = container.read(draftStoreProvider.notifier)
        ..write('note', 'x');

      store.write('note', '');

      expect(store.read('note'), isNull);
    });
  });

  group('DraftGuard', () {
    testWidgets('given typing when the field changes then keeps a draft', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      late ProviderContainer container;

      await tester.pumpWidget(
        _app(
          child: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              return DraftGuard(
                draftKey: 'note:1',
                controller: controller,
                child: TextField(controller: controller),
              );
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'rascunho');

      expect(container.read(draftStoreProvider)['note:1'], 'rascunho');
    });

    testWidgets('given a saved draft and an empty field when built then '
        'offers to restore it', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _app(
          overrides: [draftStoreProvider.overrideWith(() => _SeededDrafts())],
          child: DraftGuard(
            draftKey: 'note:1',
            controller: controller,
            child: TextField(controller: controller),
          ),
        ),
      );

      expect(find.text('Recuperar'), findsOneWidget);
      await tester.tap(find.text('Recuperar'));
      await tester.pump();

      expect(controller.text, 'texto salvo');
    });
  });

  group('PermissionGate', () {
    testWidgets('given a profile without the permission when built then '
        'shows the fallback', (tester) async {
      await tester.pumpWidget(
        _app(
          overrides: [adminSessionProvider.overrideWith(() => _SignedIn({}))],
          child: const PermissionGate(
            permission: Permission.customerBlock,
            fallback: Text('sem acesso'),
            child: Text('bloquear'),
          ),
        ),
      );

      expect(find.text('bloquear'), findsNothing);
      expect(find.text('sem acesso'), findsOneWidget);
    });

    testWidgets('given a profile with the permission when built then shows '
        'the content', (tester) async {
      await tester.pumpWidget(
        _app(
          overrides: [
            adminSessionProvider.overrideWith(
              () => _SignedIn({Permission.customerBlock}),
            ),
          ],
          child: const PermissionGate(
            permission: Permission.customerBlock,
            child: Text('bloquear'),
          ),
        ),
      );

      expect(find.text('bloquear'), findsOneWidget);
    });
  });
}

class _SeededDrafts extends DraftStore {
  @override
  Map<String, String> build() => {'note:1': 'texto salvo'};
}

class _SignedIn extends AdminSessionNotifier {
  _SignedIn(this.permissions);

  final Set<Permission> permissions;

  @override
  AdminSessionState build() => SessionSignedIn(
    StaffProfile(
      id: 1,
      name: 'Ana',
      email: 'ana@dbook.test',
      role: Role.support,
      permissions: permissions,
    ),
  );
}
