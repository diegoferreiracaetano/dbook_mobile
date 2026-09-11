import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTokenStorage implements TokenStorage {
  _FakeTokenStorage(this._tokens);

  AuthTokens? _tokens;

  @override
  Future<void> saveTokens(AuthTokens tokens) async => _tokens = tokens;

  @override
  Future<AuthTokens?> readTokens() async => _tokens;

  @override
  Future<void> clear() async => _tokens = null;
}

class _FakeAuthRepository implements AuthRepository {
  var refreshCallCount = 0;

  @override
  Future<User> register({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<AuthTokens> login({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    refreshCallCount++;
    // Simula latência de verdade, pra dar tempo de duas chamadas se
    // sobreporem no teste de dedup.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return const AuthTokens(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
    );
  }
}

/// Curto-circuita a requisição: rejeita com 401 nas primeiras
/// [failuresBeforeSuccess] chamadas por path, depois resolve com 200.
class _ScriptedInterceptor extends Interceptor {
  _ScriptedInterceptor({this.failuresBeforeSuccess = 1});

  final int failuresBeforeSuccess;
  final Map<String, int> _callsByPath = {};
  final List<String?> capturedAuthHeaders = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    capturedAuthHeaders.add(options.headers['Authorization'] as String?);
    final count = (_callsByPath[options.path] ?? 0) + 1;
    _callsByPath[options.path] = count;

    if (count <= failuresBeforeSuccess) {
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 401),
        ),
        // A real dispatch failure always reaches error interceptors (Dio's
        // own `_dispatchRequest` rejects with `true`); mimic that here so
        // this fake stands in for the real HTTP layer.
        true,
      );
      return;
    }

    handler.resolve(
      Response(requestOptions: options, statusCode: 200, data: {'ok': true}),
    );
  }
}

void main() {
  test('given a stored session when a request is made then attaches the access token', () async {
    final storage = _FakeTokenStorage(
      const AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
    );
    final scripted = _ScriptedInterceptor(failuresBeforeSuccess: 0);
    final dio = Dio();
    dio.interceptors.add(
      DbookAuthInterceptor(
        tokenStorage: storage,
        authRepository: _FakeAuthRepository(),
        dio: dio,
      ),
    );
    dio.interceptors.add(scripted);

    await dio.get<void>('/bookings');

    expect(scripted.capturedAuthHeaders.single, 'Bearer access');
  });

  test('given a 401 when a request is made then refreshes and retries with the '
      'new token', () async {
    final storage = _FakeTokenStorage(
      const AuthTokens(accessToken: 'stale', refreshToken: 'refresh'),
    );
    final authRepository = _FakeAuthRepository();
    final scripted = _ScriptedInterceptor(failuresBeforeSuccess: 1);
    final dio = Dio();
    dio.interceptors.add(
      DbookAuthInterceptor(
        tokenStorage: storage,
        authRepository: authRepository,
        dio: dio,
      ),
    );
    dio.interceptors.add(scripted);

    final response = await dio.get<Map<String, dynamic>>('/bookings');

    expect(response.statusCode, 200);
    expect(authRepository.refreshCallCount, 1);
    expect(scripted.capturedAuthHeaders, ['Bearer stale', 'Bearer new-access']);
    expect((await storage.readTokens())?.accessToken, 'new-access');
  });

  test(
    'given two concurrent 401s when both retry then only refreshes once',
    () async {
      final storage = _FakeTokenStorage(
        const AuthTokens(accessToken: 'stale', refreshToken: 'refresh'),
      );
      final authRepository = _FakeAuthRepository();
      final scripted = _ScriptedInterceptor(failuresBeforeSuccess: 1);
      final dio = Dio();
      dio.interceptors.add(
        DbookAuthInterceptor(
          tokenStorage: storage,
          authRepository: authRepository,
          dio: dio,
        ),
      );
      dio.interceptors.add(scripted);

      await Future.wait([
        dio.get<void>('/bookings'),
        dio.get<void>('/flights/search'),
      ]);

      expect(authRepository.refreshCallCount, 1);
    },
  );
}
