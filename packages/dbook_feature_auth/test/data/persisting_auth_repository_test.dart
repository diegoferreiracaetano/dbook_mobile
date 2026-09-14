import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    return User(id: 1, email: email, name: name, role: Role.client);
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    return const AuthTokens(accessToken: 'access', refreshToken: 'refresh');
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    return const AuthTokens(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
    );
  }

  @override
  Future<User> getMe() async => const User(
    id: 1,
    email: 'diego@dbook.com',
    name: 'Diego',
    role: Role.client,
  );

  @override
  Future<User> updateName(String name) async =>
      User(id: 1, email: 'diego@dbook.com', name: name, role: Role.client);
}

/// Distinto de [_FakeAuthRepository] só pra provar, nos testes abaixo, que
/// `getMe()`/`updateName()` são roteados pro repositório autenticado — nunca
/// pro de rede "cru" usado em login/registro/refresh (que não tem token).
class _FakeAuthenticatedRepository implements AuthRepository {
  var getMeCallCount = 0;
  var updateNameCallCount = 0;

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) => throw UnimplementedError();

  @override
  Future<AuthTokens> login({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<AuthTokens> refresh(String refreshToken) => throw UnimplementedError();

  @override
  Future<User> getMe() async {
    getMeCallCount++;
    return const User(
      id: 1,
      email: 'diego@dbook.com',
      name: 'Diego Ferreira',
      role: Role.client,
    );
  }

  @override
  Future<User> updateName(String name) async {
    updateNameCallCount++;
    return User(id: 1, email: 'diego@dbook.com', name: name, role: Role.client);
  }
}

class _FakeTokenStorage implements TokenStorage {
  AuthTokens? saved;

  @override
  Future<void> saveTokens(AuthTokens tokens) async => saved = tokens;

  @override
  Future<AuthTokens?> readTokens() async => saved;

  @override
  Future<void> clear() async => saved = null;
}

void main() {
  test(
    'given a successful login when called then saves the returned tokens',
    () async {
      final storage = _FakeTokenStorage();
      final repository = PersistingAuthRepository(
        networkRepository: _FakeAuthRepository(),
        authenticatedRepository: _FakeAuthenticatedRepository(),
        tokenStorage: storage,
      );

      final tokens = await repository.login(
        email: 'diego@dbook.com',
        password: 'hunter2',
      );

      expect(storage.saved, tokens);
    },
  );

  test(
    'given a successful refresh when called then saves the new pair',
    () async {
      final storage = _FakeTokenStorage();
      final repository = PersistingAuthRepository(
        networkRepository: _FakeAuthRepository(),
        authenticatedRepository: _FakeAuthenticatedRepository(),
        tokenStorage: storage,
      );

      final tokens = await repository.refresh('old-refresh');

      expect(storage.saved, tokens);
      expect(tokens.accessToken, 'new-access');
    },
  );

  test('given a registration when called then nothing is saved (no tokens returned)', () async {
    final storage = _FakeTokenStorage();
    final repository = PersistingAuthRepository(
      networkRepository: _FakeAuthRepository(),
      authenticatedRepository: _FakeAuthenticatedRepository(),
      tokenStorage: storage,
    );

    await repository.register(
      email: 'diego@dbook.com',
      password: 'hunter2',
      name: 'Diego',
    );

    expect(storage.saved, isNull);
  });

  test(
    'given getMe when called then delegates to the authenticated repository',
    () async {
      final authenticatedRepository = _FakeAuthenticatedRepository();
      final repository = PersistingAuthRepository(
        networkRepository: _FakeAuthRepository(),
        authenticatedRepository: authenticatedRepository,
        tokenStorage: _FakeTokenStorage(),
      );

      final user = await repository.getMe();

      expect(authenticatedRepository.getMeCallCount, 1);
      expect(user.name, 'Diego Ferreira');
    },
  );

  test('given updateName when called then delegates to the authenticated repository', () async {
    final authenticatedRepository = _FakeAuthenticatedRepository();
    final repository = PersistingAuthRepository(
      networkRepository: _FakeAuthRepository(),
      authenticatedRepository: authenticatedRepository,
      tokenStorage: _FakeTokenStorage(),
    );

    final user = await repository.updateName('New Name');

    expect(authenticatedRepository.updateNameCallCount, 1);
    expect(user.name, 'New Name');
  });
}
