import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart' show Permission, Role;
import 'package:dbook_feature_admin_auth/dbook_feature_admin_auth.dart';
import 'package:dbook_feature_admin_auth/src/password_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/portal_harness.dart';

/// A sessão de verdade (login, 2FA), só que já começa deslogada em vez de
/// tentar restaurar pelo cookie.
class _StartsSignedOut extends AdminSessionNotifier {
  @override
  AdminSessionState build() => const SessionSignedOut();
}

class _SignedOut extends AdminSessionNotifier {
  _SignedOut([this.initial = const SessionSignedOut()]);

  final AdminSessionState initial;
  final logins = <(String, String)>[];

  @override
  AdminSessionState build() => initial;

  @override
  Future<void> login({required String email, required String password}) async {
    logins.add((email, password));
  }
}

void main() {
  accountFlows();

  testWidgets('given the login page when submitting then hands the '
      'credentials to the session', (tester) async {
    final session = _SignedOut();
    await pumpPortal(
      tester,
      dio: RecordingDio().dio,
      overrides: [adminSessionProvider.overrideWith(() => session)],
      child: const LoginPage(),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'ana@dbook.test',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'segredo-longo-123',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(session.logins, [('ana@dbook.test', 'segredo-longo-123')]);
  });

  testWidgets('given an empty form when submitting then does not call the '
      'session', (tester) async {
    final session = _SignedOut();
    await pumpPortal(
      tester,
      dio: RecordingDio().dio,
      overrides: [adminSessionProvider.overrideWith(() => session)],
      child: const LoginPage(),
    );

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(session.logins, isEmpty);
  });

  testWidgets('given a pending second factor when the page builds then '
      'asks for the code', (tester) async {
    await pumpPortal(
      tester,
      dio: RecordingDio().dio,
      overrides: [
        adminSessionProvider.overrideWith(
          () => _SignedOut(
            const SessionChallenge(
              challengeToken: 'ch',
              enrollmentRequired: false,
            ),
          ),
        ),
      ],
      child: const LoginPage(),
    );

    expect(find.text('Verificação em duas etapas'), findsOneWidget);
  });

  testWidgets('given recovery codes when shown then lists every code', (
    tester,
  ) async {
    await pumpPortal(
      tester,
      dio: RecordingDio().dio,
      overrides: [
        adminSessionProvider.overrideWith(
          () => _SignedOut(
            const SessionRecoveryCodes(['aaaa-1111', 'bbbb-2222']),
          ),
        ),
      ],
      child: const LoginPage(),
    );

    expect(find.text('aaaa-1111'), findsOneWidget);
    expect(find.text('bbbb-2222'), findsOneWidget);
  });

  testWidgets('given a token when accepting the invite then posts name and '
      'password', (tester) async {
    final recorder = RecordingDio(
      replies: {
        'POST /admin/invitations/accept': {
          'id': 3,
          'name': 'Ana',
          'email': 'ana@dbook.test',
          'role': 'SUPPORT',
        },
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      overrides: [adminBareDioProvider.overrideWithValue(recorder.dio)],
      child: AcceptInvitePage(token: 'tk-123', onGoToLogin: () {}),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Seu nome'),
      'Ana Souza',
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), 'Segredo-Longo-2026');
    await tester.enterText(fields.at(2), 'Segredo-Longo-2026');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    final posts = recorder.to('POST', '/admin/invitations/accept').toList();
    expect(posts, hasLength(1));
    expect((posts.single.data as Map)['token'], 'tk-123');
  });

  testWidgets('given a missing token when the invite page builds then says '
      'the link is incomplete', (tester) async {
    await pumpPortal(
      tester,
      dio: RecordingDio().dio,
      child: AcceptInvitePage(token: '', onGoToLogin: () {}),
    );

    expect(find.text('Ir para o login'), findsOneWidget);
  });

  testWidgets('given the forced change when the passwords differ then does '
      'not post', (tester) async {
    final recorder = RecordingDio();
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: const ChangePasswordPage(forced: true),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'senha-atual-123');
    await tester.enterText(fields.at(1), 'Nova-Senha-Forte-2026');
    await tester.enterText(fields.at(2), 'diferente');
    await tester.tap(find.text('Trocar senha'));
    await tester.pumpAndSettle();

    expect(recorder.to('POST', '/admin/auth/change-password'), isEmpty);
  });

  testWidgets('given the requirement list when the password is weak then '
      'shows it as weak and unmet', (tester) async {
    await pumpPortal(
      tester,
      dio: RecordingDio().dio,
      child: const PasswordRequirements(
        password: 'curta',
        email: 'ana@dbook.test',
      ),
    );

    expect(find.byType(PasswordRequirements), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void accountFlows() {
  testWidgets('given 2FA off when enabling then enrolls, confirms with the '
      'six digits and shows the recovery codes', (tester) async {
    final recorder = RecordingDio(
      replies: {
        'POST /admin/2fa/enroll': {
          'otpauthUri': 'otpauth://totp/DBook:ana?secret=ABC',
          'manualEntryKey': 'ABCD EFGH',
        },
        'POST /admin/2fa/confirm': {
          'recoveryCodes': ['rec-1111', 'rec-2222'],
        },
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: AccountPage(onChangePassword: () {}),
    );

    await tester.tap(find.text('Ativar'));
    await tester.pumpAndSettle();
    expect(find.text('Ative a verificação em duas etapas'), findsOneWidget);
    expect(recorder.to('POST', '/admin/2fa/enroll'), hasLength(1));

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pumpAndSettle();

    final confirms = recorder.to('POST', '/admin/2fa/confirm').toList();
    expect(confirms, hasLength(1));
    expect((confirms.single.data as Map)['code'], '123456');
    expect(find.text('rec-1111'), findsOneWidget);
  });

  testWidgets('given 2FA on when disabling with password and code then '
      'posts both', (tester) async {
    final recorder = RecordingDio();
    await pumpPortal(
      tester,
      dio: recorder.dio,
      profile: StaffProfile(
        id: 1,
        name: 'Ana',
        email: 'ana@dbook.test',
        role: Role.support,
        permissions: const {Permission.adminPortalAccess},
        twoFactorEnabled: true,
      ),
      child: AccountPage(onChangePassword: () {}),
    );

    await tester.tap(find.text('Desligar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Sua senha'),
      'segredo-longo-123',
    );
    await tester.enterText(find.byType(TextField).at(1), '654321');
    await tester.pumpAndSettle();

    final posts = recorder.to('POST', '/admin/2fa/disable').toList();
    expect(posts, hasLength(1));
    expect((posts.single.data as Map)['code'], '654321');
  });

  Future<RecordingDio> challenge(
    WidgetTester tester, {
    required bool enrollmentRequired,
    Map<String, Object> extra = const {},
  }) async {
    final recorder = RecordingDio(
      replies: {
        'POST /admin/auth/login': {
          'challengeToken': 'ch-1',
          'enrollmentRequired': enrollmentRequired,
        },
        'GET /admin/auth/me': {
          'id': 1,
          'name': 'Ana',
          'email': 'ana@dbook.test',
          'role': 'SUPPORT',
          'permissions': ['ADMIN_PORTAL_ACCESS'],
        },
        ...extra,
      },
      statuses: {'POST /admin/auth/login': 202},
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      overrides: [
        adminBareDioProvider.overrideWithValue(recorder.dio),
        adminSessionProvider.overrideWith(_StartsSignedOut.new),
      ],
      child: const LoginPage(),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'ana@dbook.test',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'segredo-longo-123',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    return recorder;
  }

  testWidgets('given the 2FA challenge when the code is typed then verifies '
      'it with the challenge token', (tester) async {
    final recorder = await challenge(
      tester,
      enrollmentRequired: false,
      extra: {
        'POST /admin/auth/2fa/verify': {'accessToken': 'jwt-1'},
      },
    );

    expect(find.text('Verificação em duas etapas'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pumpAndSettle();

    final verifies = recorder.to('POST', '/admin/auth/2fa/verify').toList();
    expect(verifies, hasLength(1));
    expect((verifies.single.data as Map)['challengeToken'], 'ch-1');
    expect((verifies.single.data as Map)['code'], '123456');
  });

  testWidgets('given a wrong 2FA code when verifying then stays on the '
      'challenge', (tester) async {
    final recorder = RecordingDio(
      replies: {
        'POST /admin/auth/login': {
          'challengeToken': 'ch-1',
          'enrollmentRequired': false,
        },
      },
      statuses: {'POST /admin/auth/login': 202},
      failures: {
        'POST /admin/auth/2fa/verify': (
          status: 401,
          body: {'error': 'x', 'code': 'INVALID_TWO_FACTOR_CODE'},
        ),
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      overrides: [
        adminBareDioProvider.overrideWithValue(recorder.dio),
        adminSessionProvider.overrideWith(_StartsSignedOut.new),
      ],
      child: const LoginPage(),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'ana@dbook.test',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'segredo-longo-123',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '000000');
    await tester.pumpAndSettle();

    expect(find.text('Verificação em duas etapas'), findsOneWidget);
  });

  testWidgets('given enrollment required when logging in then loads the QR '
      'and shows the manual key', (tester) async {
    final recorder = await challenge(
      tester,
      enrollmentRequired: true,
      extra: {
        'POST /admin/auth/2fa/enroll': {
          'otpauthUri': 'otpauth://totp/DBook:ana?secret=ABCDEFGH',
          'manualEntryKey': 'ABCD EFGH',
        },
      },
    );

    expect(find.text('Ative a verificação em duas etapas'), findsOneWidget);
    expect(recorder.to('POST', '/admin/auth/2fa/enroll'), hasLength(1));
    expect(find.textContaining('ABCD EFGH'), findsOneWidget);
  });

  for (final reason in [
    SessionEndReason.idle,
    SessionEndReason.expired,
    SessionEndReason.loggedOut,
    SessionEndReason.passwordChanged,
  ]) {
    testWidgets('given the session ended by $reason when the login opens '
        'then explains why', (tester) async {
      await pumpPortal(
        tester,
        dio: RecordingDio().dio,
        overrides: [
          adminSessionProvider.overrideWith(
            () => _SignedOut(SessionSignedOut(reason)),
          ),
        ],
        child: const LoginPage(),
      );

      expect(find.byType(DbookInlineStatusBanner), findsOneWidget);
    });
  }
}
