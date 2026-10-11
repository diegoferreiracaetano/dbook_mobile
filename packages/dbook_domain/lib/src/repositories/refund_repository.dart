import '../entities/cancellation.dart';

/// Porta do cancelamento e do reembolso **pedidos pelo próprio cliente**.
abstract interface class RefundRepository {
  Future<CancellationPolicy> policy(int bookingId);

  /// `201` com o reembolso (`COMPLETED` ou `FAILED`). A [idempotencyKey] vale
  /// **por tentativa**: repetir a mesma devolve o mesmo reembolso (resposta
  /// perdida na rede); depois de um `FAILED` é preciso uma chave **nova**, ou
  /// o servidor repetiria o reembolso que falhou. `409 REFUND_WINDOW_CLOSED`
  /// dentro das últimas 24 h.
  Future<RefundRequestResult> request(
    int bookingId, {
    required String idempotencyKey,
  });
}
