import 'package:dio/dio.dart';

import 'app_client_info.dart';

/// Monta o `Dio` usado por toda chamada à API do DBook — base URL,
/// timeouts, a identificação do app ([appClient], mandada em toda
/// requisição) e log de requisição/resposta só em debug (via [logging]).
/// Interceptor de auth (anexar access token, refresh automático no 401)
/// entra em M3, junto com a sessão.
abstract final class DbookDioClient {
  static Dio create({
    required String baseUrl,
    bool logging = false,
    AppClientInfo appClient = AppClientInfo.unknown,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: appClient.headers,
      ),
    );

    if (logging) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}
