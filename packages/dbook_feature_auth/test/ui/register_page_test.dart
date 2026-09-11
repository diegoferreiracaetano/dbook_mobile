import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  var registerCallCount = 0;
  var loginCallCount = 0;

  @override
  Future<User> register({
    required String email,
    required String password,
  }) async {
    registerCallCount++;
    return User(id: 1, email: email, role: Role.client);
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    loginCallCount++;
    return const AuthTokens(accessToken: 'access', refreshToken: 'refresh');
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) {
    throw UnimplementedError();
  }
}

class _FakeTokenStorage implements TokenStorage {
  @override
  Future<void> saveTokens(AuthTokens tokens) async {}

  @override
  Future<AuthTokens?> readTokens() async => null;

  @override
  Future<void> clear() async {}
}

Widget _wrap(Widget child, {required AuthRepository authRepository}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(authRepository),
      tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
    ],
    child: MaterialApp(theme: DbookTheme.light, home: child),
  );
}

void main() {
  testWidgets(
    'given terms not accepted when filled and submitted then nothing happens',
    (tester) async {
      final authRepository = _FakeAuthRepository();

      await tester.pumpWidget(
        _wrap(const RegisterPage(), authRepository: authRepository),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'),
        'diego@dbook.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'hunter2',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirmar senha'),
        'hunter2',
      );
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(authRepository.registerCallCount, 0);
    },
  );

  testWidgets('given matching passwords and accepted terms when submitted then '
      'registers then logs in automatically', (tester) async {
    var registered = false;
    final authRepository = _FakeAuthRepository();

    await tester.pumpWidget(
      _wrap(
        RegisterPage(onRegistered: () => registered = true),
        authRepository: authRepository,
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'diego@dbook.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'hunter2',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirmar senha'),
      'hunter2',
    );
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(authRepository.registerCallCount, 1);
    expect(authRepository.loginCallCount, 1);
    expect(registered, isTrue);
  });

  testWidgets(
    'given mismatched passwords when submitted then shows a validation error',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const RegisterPage(), authRepository: _FakeAuthRepository()),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'),
        'diego@dbook.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'hunter2',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirmar senha'),
        'somethingelse',
      );
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      expect(find.text('As senhas não coincidem'), findsOneWidget);
    },
  );
}
