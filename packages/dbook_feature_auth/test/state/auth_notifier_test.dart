import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.loginError, this.refreshShouldFail = false});

  final DbookNetworkException? loginError;
  final bool refreshShouldFail;
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
    if (loginError != null) throw loginError!;
    return const AuthTokens(accessToken: 'access', refreshToken: 'refresh');
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    if (refreshShouldFail) {
      throw const DbookUnauthorizedException('Refresh token expired');
    }
    return const AuthTokens(
      accessToken: 'refreshed-access',
      refreshToken: 'refreshed-refresh',
    );
  }
}

class _FakeTokenStorage implements TokenStorage {
  _FakeTokenStorage([this._tokens]);

  AuthTokens? _tokens;

  @override
  Future<void> saveTokens(AuthTokens tokens) async => _tokens = tokens;

  @override
  Future<AuthTokens?> readTokens() async => _tokens;

  @override
  Future<void> clear() async => _tokens = null;
}

ProviderContainer _buildContainer({
  required AuthRepository authRepository,
  required TokenStorage tokenStorage,
}) {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(authRepository),
      tokenStorageProvider.overrideWithValue(tokenStorage),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('given fresh state when built then starts loggedOut', () {
    final container = _buildContainer(
      authRepository: _FakeAuthRepository(),
      tokenStorage: _FakeTokenStorage(),
    );

    expect(container.read(authNotifierProvider), const AuthState.loggedOut());
  });

  test(
    'given valid credentials when logging in then ends up loggedIn',
    () async {
      final container = _buildContainer(
        authRepository: _FakeAuthRepository(),
        tokenStorage: _FakeTokenStorage(),
      );

      await container
          .read(authNotifierProvider.notifier)
          .login(email: 'diego@dbook.com', password: 'hunter2');

      final state = container.read(authNotifierProvider);
      expect(state, isA<AuthLoggedIn>());
      expect((state as AuthLoggedIn).tokens.accessToken, 'access');
    },
  );

  test('given invalid credentials when logging in then ends up in error with '
      'the backend message', () async {
    final container = _buildContainer(
      authRepository: _FakeAuthRepository(
        loginError: const DbookUnauthorizedException('Invalid credentials'),
      ),
      tokenStorage: _FakeTokenStorage(),
    );

    await container
        .read(authNotifierProvider.notifier)
        .login(email: 'diego@dbook.com', password: 'wrong');

    final state = container.read(authNotifierProvider);
    expect(state, isA<AuthError>());
    expect((state as AuthError).message, 'Invalid credentials');
  });

  test('given a new account when registering then registers then logs in '
      'automatically', () async {
    final authRepository = _FakeAuthRepository();
    final container = _buildContainer(
      authRepository: authRepository,
      tokenStorage: _FakeTokenStorage(),
    );

    await container
        .read(authNotifierProvider.notifier)
        .register(email: 'diego@dbook.com', password: 'hunter2');

    expect(authRepository.registerCallCount, 1);
    expect(authRepository.loginCallCount, 1);
    expect(container.read(authNotifierProvider), isA<AuthLoggedIn>());
  });

  test('given a saved session when bootstrapping then refreshes and ends up '
      'loggedIn', () async {
    final storage = _FakeTokenStorage(
      const AuthTokens(accessToken: 'old', refreshToken: 'old-refresh'),
    );
    final container = _buildContainer(
      authRepository: _FakeAuthRepository(),
      tokenStorage: storage,
    );

    await container.read(authNotifierProvider.notifier).bootstrap();

    final state = container.read(authNotifierProvider);
    expect(state, isA<AuthLoggedIn>());
    expect((state as AuthLoggedIn).tokens.accessToken, 'refreshed-access');
  });

  test(
    'given no saved session when bootstrapping then ends up loggedOut',
    () async {
      final container = _buildContainer(
        authRepository: _FakeAuthRepository(),
        tokenStorage: _FakeTokenStorage(),
      );

      await container.read(authNotifierProvider.notifier).bootstrap();

      expect(container.read(authNotifierProvider), const AuthState.loggedOut());
    },
  );

  test('given an expired refresh token when bootstrapping then clears storage '
      'and ends up loggedOut', () async {
    final storage = _FakeTokenStorage(
      const AuthTokens(accessToken: 'old', refreshToken: 'expired'),
    );
    final container = _buildContainer(
      authRepository: _FakeAuthRepository(refreshShouldFail: true),
      tokenStorage: storage,
    );

    await container.read(authNotifierProvider.notifier).bootstrap();

    expect(container.read(authNotifierProvider), const AuthState.loggedOut());
    expect(await storage.readTokens(), isNull);
  });

  test('given a loggedIn session when logging out then clears storage and '
      'ends up loggedOut', () async {
    final storage = _FakeTokenStorage(
      const AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
    );
    final container = _buildContainer(
      authRepository: _FakeAuthRepository(),
      tokenStorage: storage,
    );

    await container.read(authNotifierProvider.notifier).logout();

    expect(container.read(authNotifierProvider), const AuthState.loggedOut());
    expect(await storage.readTokens(), isNull);
  });
}
