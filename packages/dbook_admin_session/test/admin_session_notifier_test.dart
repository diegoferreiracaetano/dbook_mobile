import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/container.dart';
import 'support/fakes.dart';

void main() {
  late FakeAdminAuthApi api;
  late ProviderContainer container;

  AdminSessionNotifier notifier() =>
      container.read(adminSessionProvider.notifier);
  AdminSessionState state() => container.read(adminSessionProvider);

  /// Cria o container já com a restauração inicial resolvida (sem cookie).
  Future<void> startSignedOut() async {
    api.refreshError = const DbookUnauthorizedException('sem cookie');
    container = sessionContainer(api)..listen(adminSessionProvider, (_, _) {});
    container.read(adminSessionProvider);
    await pumpEventQueue();
  }

  setUp(() => api = FakeAdminAuthApi());
  tearDown(() => container.dispose());

  group('restoring the session (page load)', () {
    test('given a valid cookie when the page opens then the session is '
        'restored with the profile', () async {
      container = sessionContainer(api)
        ..listen(adminSessionProvider, (_, _) {});
      expect(container.read(adminSessionProvider), isA<SessionRestoring>());

      await pumpEventQueue();

      final current = state();
      expect(current, isA<SessionSignedIn>());
      expect((current as SessionSignedIn).profile.email, 'diego@dbook.com');
    });

    test('given a lost cookie when the page opens then the user is signed '
        'out, with no error', () async {
      await startSignedOut();

      expect(state(), isA<SessionSignedOut>());
      expect((state() as SessionSignedOut).reason, SessionEndReason.none);
    });
  });

  group('login', () {
    test(
      'given the right password when logging in then the profile loads',
      () async {
        await startSignedOut();

        await notifier().login(email: 'a@b.c', password: 'x');

        expect(state(), isA<SessionSignedIn>());
        expect(
          container.read(sessionTokenManagerProvider).accessToken,
          'token-1',
        );
      },
    );

    test('given a wrong password when logging in then the error reaches the '
        'caller and the user stays out', () async {
      await startSignedOut();
      api.loginError = const DbookUnauthorizedException(
        'x',
        code: 'INVALID_CREDENTIALS',
      );

      await expectLater(
        notifier().login(email: 'a@b.c', password: 'x'),
        throwsA(isA<DbookUnauthorizedException>()),
      );

      expect(state(), isA<SessionSignedOut>());
    });

    test('given an account that needs 2FA when logging in then it waits for '
        'the code', () async {
      await startSignedOut();
      api.loginOutcome = const LoginNeedsSecondFactor(
        challengeToken: 'chal',
        enrollmentRequired: false,
      );

      await notifier().login(email: 'a@b.c', password: 'x');

      final current = state() as SessionChallenge;
      expect(current.enrollmentRequired, isFalse);
    });

    test(
      'given the right code when verified then the session starts',
      () async {
        await startSignedOut();
        api.loginOutcome = const LoginNeedsSecondFactor(
          challengeToken: 'chal',
          enrollmentRequired: false,
        );
        await notifier().login(email: 'a@b.c', password: 'x');

        await notifier().verifyTwoFactor('123456');

        expect(api.lastVerifyCode, '123456');
        expect(state(), isA<SessionSignedIn>());
      },
    );

    test('given a wrong code when verified then it throws and the challenge '
        'stays open for another try', () async {
      await startSignedOut();
      api.loginOutcome = const LoginNeedsSecondFactor(
        challengeToken: 'chal',
        enrollmentRequired: false,
      );
      await notifier().login(email: 'a@b.c', password: 'x');
      api.verifyError = const DbookValidationException(
        'x',
        code: 'INVALID_TWO_FACTOR_CODE',
      );

      await expectLater(
        notifier().verifyTwoFactor('000000'),
        throwsA(isA<DbookValidationException>()),
      );

      expect(state(), isA<SessionChallenge>());
    });

    test('given an account without an authenticator when enrolling then the '
        'recovery codes show before the session starts', () async {
      await startSignedOut();
      api.loginOutcome = const LoginNeedsSecondFactor(
        challengeToken: 'chal',
        enrollmentRequired: true,
      );
      await notifier().login(email: 'a@b.c', password: 'x');

      final enrollment = await notifier().startEnrollment();
      await notifier().confirmEnrollment('123456');

      expect(enrollment.manualEntryKey, 'ABCD');
      expect((state() as SessionRecoveryCodes).codes, [
        'aaaa-bbbb',
        'cccc-dddd',
      ]);

      await notifier().acknowledgeRecoveryCodes();

      expect(state(), isA<SessionSignedIn>());
    });

    test(
      'given a challenge when cancelled then it returns to the login',
      () async {
        await startSignedOut();
        api.loginOutcome = const LoginNeedsSecondFactor(
          challengeToken: 'chal',
          enrollmentRequired: false,
        );
        await notifier().login(email: 'a@b.c', password: 'x');

        notifier().cancelChallenge();

        expect(state(), isA<SessionSignedOut>());
      },
    );

    test(
      'given no challenge when verifying then it is a programming error',
      () async {
        await startSignedOut();

        await expectLater(notifier().verifyTwoFactor('1'), throwsStateError);
      },
    );
  });

  group('ending the session', () {
    Future<void> signIn() async {
      await startSignedOut();
      await notifier().login(email: 'a@b.c', password: 'x');
    }

    test('given a session when logging out then the server is told and the '
        'token is gone', () async {
      await signIn();

      await notifier().logout();

      expect(api.logoutCalls, 1);
      expect((state() as SessionSignedOut).reason, SessionEndReason.loggedOut);
      expect(container.read(sessionTokenManagerProvider).hasToken, isFalse);
    });

    test(
      'given the API down when logging out then the user still leaves',
      () async {
        await signIn();
        api.refreshError = null;

        await notifier().logout();

        expect(state(), isA<SessionSignedOut>());
      },
    );

    test(
      'given idleness when the session expires then the reason is idle',
      () async {
        await signIn();

        notifier().expire(SessionEndReason.idle);

        expect((state() as SessionSignedOut).reason, SessionEndReason.idle);
        expect(container.read(sessionTokenManagerProvider).hasToken, isFalse);
      },
    );

    test(
      'given a password change when it works then every session ends',
      () async {
        await signIn();

        await notifier().changePassword(currentPassword: 'a', newPassword: 'b');

        expect(api.passwordChanged, isTrue);
        expect(state(), isA<SessionSignedOut>());
      },
    );
  });

  group('silent renewal', () {
    test('given a token that expires in 5 minutes when 4 minutes pass then it '
        'renews by itself and schedules the next one', () {
      fakeAsync((async) {
        final now = DateTime(2026, 10, 7, 12);
        api.refreshError = const DbookUnauthorizedException('sem cookie');
        api.loginOutcome = LoginSucceeded(
          fakeJwt(expiresAt: now.add(const Duration(minutes: 5))),
        );
        container = sessionContainer(api, clock: () => now)
          ..listen(adminSessionProvider, (_, _) {});
        container.read(adminSessionProvider);
        async.flushMicrotasks();

        api.refreshError = null;
        api.refreshToken = fakeJwt(
          expiresAt: now.add(const Duration(minutes: 20)),
        );
        notifier().login(email: 'a@b.c', password: 'x');
        async.flushMicrotasks();
        final before = api.refreshCalls;

        async.elapse(const Duration(minutes: 4));
        async.flushMicrotasks();

        expect(api.refreshCalls, before + 1);
        expect(state(), isA<SessionSignedIn>());
      });
    });

    test('given the renewal is refused when the time comes then the session '
        'expires', () {
      fakeAsync((async) {
        final now = DateTime(2026, 10, 7, 12);
        api.refreshError = const DbookUnauthorizedException('sem cookie');
        api.loginOutcome = LoginSucceeded(
          fakeJwt(expiresAt: now.add(const Duration(minutes: 5))),
        );
        container = sessionContainer(api, clock: () => now)
          ..listen(adminSessionProvider, (_, _) {});
        container.read(adminSessionProvider);
        async.flushMicrotasks();
        notifier().login(email: 'a@b.c', password: 'x');
        async.flushMicrotasks();

        async.elapse(const Duration(minutes: 4));
        async.flushMicrotasks();

        expect((state() as SessionSignedOut).reason, SessionEndReason.expired);
      });
    });
  });

  group('permissions', () {
    test(
      'given a profile when asked then canProvider answers by permission',
      () async {
        container = sessionContainer(api)
          ..listen(adminSessionProvider, (_, _) {});
        await pumpEventQueue();

        expect(container.read(canProvider(Permission.customerRead)), isTrue);
        expect(container.read(canProvider(Permission.flightWrite)), isFalse);
      },
    );

    test('given no session when asked then nothing is allowed', () async {
      await startSignedOut();

      expect(container.read(canProvider(Permission.customerRead)), isFalse);
      expect(container.read(staffProfileProvider), isNull);
    });
  });
}
