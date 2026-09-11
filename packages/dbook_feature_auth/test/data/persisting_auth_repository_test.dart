import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<User> register({
    required String email,
    required String password,
  }) async {
    return User(id: 1, email: email, role: Role.client);
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
      tokenStorage: storage,
    );

    await repository.register(email: 'diego@dbook.com', password: 'hunter2');

    expect(storage.saved, isNull);
  });
}
