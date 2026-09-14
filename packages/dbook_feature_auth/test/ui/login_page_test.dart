import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.loginError});

  final DbookNetworkException? loginError;
  var loginCallCount = 0;
  String? capturedEmail;
  String? capturedPassword;

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    loginCallCount++;
    capturedEmail = email;
    capturedPassword = password;
    if (loginError != null) throw loginError!;
    return const AuthTokens(accessToken: 'access', refreshToken: 'refresh');
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) {
    throw UnimplementedError();
  }

  @override
  Future<User> getMe() async => User(
    id: 1,
    email: capturedEmail ?? '',
    name: 'Test User',
    role: Role.client,
  );

  @override
  Future<User> updateName(String name) {
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
    'given empty fields when submitting then shows validation errors',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const LoginPage(), authRepository: _FakeAuthRepository()),
      );

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Digite seu e-mail'), findsOneWidget);
      expect(find.text('Digite sua senha'), findsOneWidget);
    },
  );

  testWidgets(
    'given valid credentials when submitted then calls login and reaches '
    'loggedIn',
    (tester) async {
      var loggedIn = false;
      final authRepository = _FakeAuthRepository();

      await tester.pumpWidget(
        _wrap(
          LoginPage(onLoggedIn: () => loggedIn = true),
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
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(authRepository.loginCallCount, 1);
      expect(authRepository.capturedEmail, 'diego@dbook.com');
      expect(loggedIn, isTrue);
    },
  );

  testWidgets('given the backend rejects login then shows the error banner', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const LoginPage(),
        authRepository: _FakeAuthRepository(
          loginError: const DbookUnauthorizedException('Invalid credentials'),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'diego@dbook.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'wrongpass',
    );
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid credentials'), findsOneWidget);
  });
}
