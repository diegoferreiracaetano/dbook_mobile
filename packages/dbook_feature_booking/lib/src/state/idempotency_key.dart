import 'dart:math';

final _random = Random.secure();

/// Chave de idempotência do pagamento: um UUID v4 (aleatório). Gerado aqui,
/// sem pacote novo, porque são 10 linhas e o projeto não adiciona dependência
/// sem pedido explícito.
String generateIdempotencyKey() {
  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // versão 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variante RFC 4122
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
