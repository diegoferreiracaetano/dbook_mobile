import 'package:dbook_domain/dbook_domain.dart';
import 'package:test/test.dart';

class _FakeAuthRepository implements AuthRepository {
  String? capturedEmail;
  String? capturedPassword;
  String? capturedName;
  String? capturedRefreshToken;

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    capturedEmail = email;
    capturedPassword = password;
    capturedName = name;
    return User(id: 1, email: email, name: name, role: Role.client);
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    capturedEmail = email;
    capturedPassword = password;
    return const AuthTokens(accessToken: 'access', refreshToken: 'refresh');
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    capturedRefreshToken = refreshToken;
    return const AuthTokens(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
    );
  }

  @override
  Future<User> getMe() async => User(
    id: 1,
    email: capturedEmail ?? '',
    name: capturedName ?? '',
    role: Role.client,
  );

  @override
  Future<User> updateName(String name) async {
    capturedName = name;
    return User(
      id: 1,
      email: capturedEmail ?? '',
      name: name,
      role: Role.client,
    );
  }
}

void main() {
  test('given credentials when registering then forwards them and returns the '
      'created user', () async {
    final repository = _FakeAuthRepository();
    final useCase = RegisterUseCase(repository);

    final user = await useCase(
      email: 'diego@dbook.com',
      password: 'hunter2',
      name: 'Diego',
    );

    expect(repository.capturedEmail, 'diego@dbook.com');
    expect(repository.capturedPassword, 'hunter2');
    expect(repository.capturedName, 'Diego');
    expect(user.email, 'diego@dbook.com');
  });

  test(
    'given credentials when logging in then forwards them and returns tokens',
    () async {
      final repository = _FakeAuthRepository();
      final useCase = LoginUseCase(repository);

      final tokens = await useCase(
        email: 'diego@dbook.com',
        password: 'hunter2',
      );

      expect(repository.capturedEmail, 'diego@dbook.com');
      expect(tokens.accessToken, 'access');
    },
  );

  test('given a refresh token when refreshing then forwards it and returns a '
      'new pair', () async {
    final repository = _FakeAuthRepository();
    final useCase = RefreshSessionUseCase(repository);

    final tokens = await useCase('old-refresh');

    expect(repository.capturedRefreshToken, 'old-refresh');
    expect(tokens.accessToken, 'new-access');
    expect(tokens.refreshToken, 'new-refresh');
  });
}
