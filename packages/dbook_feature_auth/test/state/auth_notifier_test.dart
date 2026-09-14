import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.loginError,
    this.refreshShouldFail = false,
    this.getMeShouldFail = false,
  });

  final DbookNetworkException? loginError;
  final bool refreshShouldFail;
  final bool getMeShouldFail;
  var registerCallCount = 0;
  var loginCallCount = 0;
  var getMeCallCount = 0;
  var updateNameCallCount = 0;

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    registerCallCount++;
    return User(id: 1, email: email, name: name, role: Role.client);
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

  @override
  Future<User> getMe() async {
    getMeCallCount++;
    if (getMeShouldFail) {
      throw const DbookUnknownNetworkException('Network error');
    }
    return const User(
      id: 1,
      email: 'server@dbook.com',
      name: 'Server Name',
      role: Role.client,
    );
  }

  @override
  Future<User> updateName(String name) async {
    updateNameCallCount++;
    return User(
      id: 1,
      email: 'server@dbook.com',
      name: name,
      role: Role.client,
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

  test('given a successful login when it completes then the real profile '
      'from getMe() overrides what was typed', () async {
    final container = _buildContainer(
      authRepository: _FakeAuthRepository(),
      tokenStorage: _FakeTokenStorage(),
    );

    await container
        .read(authNotifierProvider.notifier)
        .login(email: 'diego@dbook.com', password: 'hunter2');

    final state = container.read(authNotifierProvider) as AuthLoggedIn;
    expect(state.email, 'server@dbook.com');
    expect(state.name, 'Server Name');
  });

  test('given getMe() failing after login then the session stays loggedIn '
      'with what was already known', () async {
    final container = _buildContainer(
      authRepository: _FakeAuthRepository(getMeShouldFail: true),
      tokenStorage: _FakeTokenStorage(),
    );

    await container
        .read(authNotifierProvider.notifier)
        .login(email: 'diego@dbook.com', password: 'hunter2');

    final state = container.read(authNotifierProvider) as AuthLoggedIn;
    expect(state.email, 'diego@dbook.com');
    expect(state.name, isNull);
  });

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
        .register(email: 'diego@dbook.com', password: 'hunter2', name: 'Diego');

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
    // bootstrap() não recupera e-mail/nome sozinho (refresh não os devolve)
    // — é o getMe() disparado em seguida que preenche os dois.
    expect(state.email, 'server@dbook.com');
    expect(state.name, 'Server Name');
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

  test('given a loggedIn session when updating the name then the state '
      'reflects the new name', () async {
    final authRepository = _FakeAuthRepository();
    final container = _buildContainer(
      authRepository: authRepository,
      tokenStorage: _FakeTokenStorage(),
    );
    await container
        .read(authNotifierProvider.notifier)
        .login(email: 'diego@dbook.com', password: 'hunter2');

    await container.read(authNotifierProvider.notifier).updateName('New Name');

    expect(authRepository.updateNameCallCount, 1);
    final state = container.read(authNotifierProvider) as AuthLoggedIn;
    expect(state.name, 'New Name');
  });
}
