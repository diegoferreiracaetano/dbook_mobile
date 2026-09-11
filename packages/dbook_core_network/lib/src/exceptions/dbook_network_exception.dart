import 'package:dio/dio.dart';

/// Erros de rede/API do DBook — um por faixa de status HTTP que o backend
/// de fato usa (`ApiExceptionHandler`, `SecurityResponses`,
/// `AiRateLimitInterceptor`). [message] vem do corpo `{"error": "..."}`
/// quando presente.
sealed class DbookNetworkException implements Exception {
  const DbookNetworkException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// 400 — corpo/parâmetros inválidos.
class DbookValidationException extends DbookNetworkException {
  const DbookValidationException(super.message);
}

/// 401 — credenciais ou token inválido/expirado.
class DbookUnauthorizedException extends DbookNetworkException {
  const DbookUnauthorizedException(super.message);
}

/// 403 — autenticado, mas sem permissão (ex.: cancelar reserva de outro
/// usuário).
class DbookForbiddenException extends DbookNetworkException {
  const DbookForbiddenException(super.message);
}

/// 404 — recurso não encontrado.
class DbookNotFoundException extends DbookNetworkException {
  const DbookNotFoundException(super.message);
}

/// 409 — conflito (assento perdeu a corrida, transição de reserva
/// inválida, e-mail já cadastrado).
class DbookConflictException extends DbookNetworkException {
  const DbookConflictException(super.message);
}

/// 429 — rate limit da IA (5 chamadas/min por usuário).
class DbookRateLimitException extends DbookNetworkException {
  const DbookRateLimitException(super.message);
}

/// 502 — resposta do modelo de IA não pôde ser interpretada.
class DbookBadGatewayException extends DbookNetworkException {
  const DbookBadGatewayException(super.message);
}

/// 503 — serviço de IA (Bedrock) fora do ar.
class DbookServiceUnavailableException extends DbookNetworkException {
  const DbookServiceUnavailableException(super.message);
}

/// Timeout, sem conexão, ou qualquer status HTTP que o backend não deveria
/// devolver.
class DbookUnknownNetworkException extends DbookNetworkException {
  const DbookUnknownNetworkException(super.message);
}

/// Traduz um [DioException] pra exception do DBook, lendo `{"error": "..."}`
/// do corpo quando existir.
DbookNetworkException mapDioException(DioException error) {
  final statusCode = error.response?.statusCode;
  final message =
      _extractErrorMessage(error) ?? error.message ?? 'Unknown error';

  return switch (statusCode) {
    400 => DbookValidationException(message),
    401 => DbookUnauthorizedException(message),
    403 => DbookForbiddenException(message),
    404 => DbookNotFoundException(message),
    409 => DbookConflictException(message),
    429 => DbookRateLimitException(message),
    502 => DbookBadGatewayException(message),
    503 => DbookServiceUnavailableException(message),
    _ => DbookUnknownNetworkException(message),
  };
}

String? _extractErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is Map && data['error'] is String) {
    return data['error'] as String;
  }
  return null;
}
