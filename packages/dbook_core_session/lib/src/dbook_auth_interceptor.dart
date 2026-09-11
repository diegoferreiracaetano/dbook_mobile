import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

/// Anexa o access token em toda requisição e, num 401, tenta um refresh
/// automático e repete a requisição original. [authRepository] aqui é o
/// repositório de rede puro (não o `PersistingAuthRepository` da feature de
/// auth) — este interceptor já salva o par novo sozinho, salvar duas vezes
/// seria redundante.
///
/// Refreshes concorrentes são deduplicados num único voo: o refresh token é
/// de uso único no backend, então dois 401 simultâneos tentando refrescar
/// ao mesmo tempo invalidariam um ao outro. Por isso [DbookAuthInterceptor]
/// vive aqui, num pacote compartilhado, em vez de dentro da feature de auth
/// — toda feature usa o mesmo `dioProvider`/interceptor (M4 em diante), e
/// duas instâncias de interceptor deduplicariam refresh cada uma sozinha,
/// reabrindo a race condition.
class DbookAuthInterceptor extends Interceptor {
  DbookAuthInterceptor({
    required this.tokenStorage,
    required this.authRepository,
    required this.dio,
  });

  final TokenStorage tokenStorage;
  final AuthRepository authRepository;
  final Dio dio;

  Future<AuthTokens>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokens = await tokenStorage.readTokens();
    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    try {
      final refreshed = await _refreshTokens();
      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer ${refreshed.accessToken}';
      final response = await dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } catch (_) {
      await tokenStorage.clear();
      handler.next(err);
    }
  }

  Future<AuthTokens> _refreshTokens() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<AuthTokens> _doRefresh() async {
    final stored = await tokenStorage.readTokens();
    if (stored == null) {
      throw StateError('No stored session to refresh');
    }

    final refreshed = await authRepository.refresh(stored.refreshToken);
    await tokenStorage.saveTokens(refreshed);
    return refreshed;
  }
}
