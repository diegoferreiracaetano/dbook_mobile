import 'package:dio/dio.dart';

/// Erros de rede/API do DBook — um por faixa de status HTTP que o backend
/// de fato usa (`ApiExceptionHandler`, `SecurityResponses`,
/// `AiRateLimitInterceptor`). [message] vem do corpo `{"error": "..."}`
/// quando presente.
sealed class DbookNetworkException implements Exception {
  const DbookNetworkException(this.message, {this.code, this.retryAfter});

  final String message;

  /// O `code` do corpo (`INVALID_CREDENTIALS`, `STALE_VERSION`...). O portal
  /// decide o que mostrar por ele; a [message] pode mudar no backend.
  final String? code;

  /// Segundos do cabeçalho `Retry-After` (429), quando o servidor manda.
  final int? retryAfter;

  @override
  String toString() => '$runtimeType: $message';
}

/// 400 — corpo/parâmetros inválidos.
class DbookValidationException extends DbookNetworkException {
  const DbookValidationException(super.message, {super.code, super.retryAfter});
}

/// 401 — credenciais ou token inválido/expirado.
class DbookUnauthorizedException extends DbookNetworkException {
  const DbookUnauthorizedException(
    super.message, {
    super.code,
    super.retryAfter,
  });
}

/// 403 — autenticado, mas sem permissão (ex.: cancelar reserva de outro
/// usuário).
class DbookForbiddenException extends DbookNetworkException {
  const DbookForbiddenException(super.message, {super.code, super.retryAfter});
}

/// 404 — recurso não encontrado.
class DbookNotFoundException extends DbookNetworkException {
  const DbookNotFoundException(super.message, {super.code, super.retryAfter});
}

/// 409 — conflito (assento perdeu a corrida, transição de reserva
/// inválida, e-mail já cadastrado).
class DbookConflictException extends DbookNetworkException {
  const DbookConflictException(super.message, {super.code, super.retryAfter});
}

/// 422 — pedido bem formado, mas recusado pela regra (chave de idempotência
/// reaproveitada, código promocional rejeitado, importação com erros).
class DbookUnprocessableException extends DbookNetworkException {
  const DbookUnprocessableException(
    super.message, {
    super.code,
    super.retryAfter,
  });
}

/// 429 — rate limit da IA (5 chamadas/min por usuário).
class DbookRateLimitException extends DbookNetworkException {
  const DbookRateLimitException(super.message, {super.code, super.retryAfter});
}

/// 502 — resposta do modelo de IA não pôde ser interpretada.
class DbookBadGatewayException extends DbookNetworkException {
  const DbookBadGatewayException(super.message, {super.code, super.retryAfter});
}

/// 503 — serviço de IA (Bedrock) fora do ar.
class DbookServiceUnavailableException extends DbookNetworkException {
  const DbookServiceUnavailableException(
    super.message, {
    super.code,
    super.retryAfter,
  });
}

/// Timeout, sem conexão, ou qualquer status HTTP que o backend não deveria
/// devolver.
class DbookUnknownNetworkException extends DbookNetworkException {
  const DbookUnknownNetworkException(
    super.message, {
    super.code,
    super.retryAfter,
  });
}

/// Traduz um [DioException] pra exception do DBook, lendo `{"error": "..."}`
/// do corpo quando existir.
DbookNetworkException mapDioException(DioException error) {
  final statusCode = error.response?.statusCode;
  final message =
      _extractErrorMessage(error) ?? error.message ?? 'Unknown error';
  final code = _extractErrorCode(error);
  final retryAfter = _extractRetryAfter(error);

  return switch (statusCode) {
    400 => DbookValidationException(message, code: code),
    401 => DbookUnauthorizedException(message, code: code),
    403 => DbookForbiddenException(message, code: code),
    404 => DbookNotFoundException(message, code: code),
    409 => DbookConflictException(message, code: code),
    422 => DbookUnprocessableException(message, code: code),
    429 => DbookRateLimitException(message, code: code, retryAfter: retryAfter),
    502 => DbookBadGatewayException(message, code: code),
    503 => DbookServiceUnavailableException(message, code: code),
    _ => DbookUnknownNetworkException(message, code: code),
  };
}

String? _extractErrorCode(DioException error) {
  final data = error.response?.data;
  if (data is Map && data['code'] is String) return data['code'] as String;
  return null;
}

int? _extractRetryAfter(DioException error) {
  final raw = error.response?.headers.value('retry-after');
  return raw == null ? null : int.tryParse(raw.trim());
}

String? _extractErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is Map && data['error'] is String) {
    return data['error'] as String;
  }
  return null;
}
