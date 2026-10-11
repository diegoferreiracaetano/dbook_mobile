import 'dart:math';

/// Uma chave de idempotência nova (UUID v4) para cada **tentativa** de uma
/// ação que mexe em dinheiro. Reaproveitá-la na repetição faz o servidor
/// devolver o resultado original em vez de agir duas vezes.
String newIdempotencyKey([Random? random]) {
  final r = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => r.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int from, int to) => bytes
      .sublist(from, to)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}

/// A tentativa em curso de uma ação idempotente: mantém a mesma chave enquanto
/// o pedido for o mesmo (repetição depois de erro ou resposta perdida) e troca
/// por uma nova quando o pedido muda ou a anterior terminou.
class IdempotentAttempt {
  String? _fingerprint;
  String? _key;

  String keyFor(String fingerprint) {
    if (_key == null || _fingerprint != fingerprint) {
      _fingerprint = fingerprint;
      _key = newIdempotencyKey();
    }
    return _key!;
  }

  /// A ação terminou (sucesso): a próxima é outra tentativa.
  void finish() {
    _fingerprint = null;
    _key = null;
  }
}
