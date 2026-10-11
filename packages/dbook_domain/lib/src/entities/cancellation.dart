/// O que o cliente pode fazer com a própria reserva agora
/// (`GET /v1/bookings/{id}/cancellation-policy`).
enum CancellationAction {
  /// Reserva não paga: é só cancelar, não há o que devolver.
  cancel,

  /// Paga e dentro do prazo: pode pedir o reembolso.
  refundRequest,

  /// Nada a fazer (veja [CancellationBlock]).
  none,
}

/// Por que não dá para cancelar ou reembolsar.
enum CancellationBlock {
  windowClosed,
  refundInProgress,
  alreadyRefunded,
  alreadyCancelled,
  unknown,
}

class CancellationPolicy {
  const CancellationPolicy({
    required this.bookingId,
    required this.action,
    this.refundAmount,
    this.refundableUntil,
    this.blockedBy,
  });

  final int bookingId;
  final CancellationAction action;

  /// O que foi **de fato pago** (depois de qualquer desconto); só vem quando
  /// há reembolso possível.
  final double? refundAmount;

  /// Até quando o reembolso é possível (24 h antes da partida).
  final DateTime? refundableUntil;
  final CancellationBlock? blockedBy;
}

/// Como está o pedido de reembolso.
enum RefundProgress { requested, completed, failed, unknown }

/// A resposta de `POST /v1/bookings/{id}/refund-request`.
class RefundRequestResult {
  const RefundRequestResult({
    required this.bookingId,
    required this.amount,
    required this.status,
  });

  final int bookingId;
  final double amount;
  final RefundProgress status;
}
