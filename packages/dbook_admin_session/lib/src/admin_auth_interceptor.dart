import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dio/dio.dart';

import 'token_manager.dart';

/// Anexa o token em toda chamada e, num `401`, renova a sessão (uma só vez,
/// compartilhada) e repete a chamada. Se a renovação falha, a sessão acabou:
/// avisa por [onSessionLost] e deixa o `401` original seguir.
class AdminAuthInterceptor extends Interceptor {
  AdminAuthInterceptor({
    required this.tokens,
    required this.dio,
    required this.onSessionLost,
  });

  static const _retriedKey = 'sessionRetried';

  final SessionTokenManager tokens;
  final Dio dio;
  final void Function() onSessionLost;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokens.accessToken;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final alreadyRetried = options.extra[_retriedKey] == true;
    if (err.response?.statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    try {
      // Se o token mudou desde que esta chamada saiu, outra já renovou: basta
      // repetir com o atual. Renovar de novo gastaria o refresh token (de uso
      // único) e derrubaria a sessão sem motivo.
      final current = tokens.accessToken;
      final sentWith = options.headers['Authorization'];
      final fresh = current != null && sentWith != 'Bearer $current'
          ? current
          : await tokens.refresh();
      options
        ..extra[_retriedKey] = true
        ..headers['Authorization'] = 'Bearer $fresh';
      handler.resolve(await dio.fetch<dynamic>(options));
    } on DbookUnauthorizedException {
      _lose(err, handler);
    } on DbookForbiddenException {
      _lose(err, handler);
    } on DioException catch (retryError) {
      // A chamada repetida falhou. Com 401 mesmo com o token novo, a sessão
      // não vale mais; qualquer outro erro é da chamada, não da sessão.
      if (retryError.response?.statusCode == 401) onSessionLost();
      handler.next(retryError);
    } on Object {
      // A renovação falhou por outro motivo (API fora do ar, rede): a sessão
      // continua de pé, o erro original segue para quem chamou.
      handler.next(err);
    }
  }

  void _lose(DioException err, ErrorInterceptorHandler handler) {
    tokens.clear();
    onSessionLost();
    handler.next(err);
  }
}
