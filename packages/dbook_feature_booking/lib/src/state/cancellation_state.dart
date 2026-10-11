import 'package:dbook_domain/dbook_domain.dart';

/// O fluxo de cancelar ou pedir reembolso de uma reserva.
sealed class CancellationState {
  const CancellationState();
}

class CancellationLoading extends CancellationState {
  const CancellationLoading();
}

class CancellationLoadFailed extends CancellationState {
  const CancellationLoadFailed(this.message);

  final String message;
}

/// A política que o servidor aplica **agora**: o que acontece, quanto volta e
/// até quando. A pessoa vê isto **antes** de confirmar.
class CancellationReady extends CancellationState {
  const CancellationReady(this.policy, {this.error});

  final CancellationPolicy policy;

  /// Falha da última tentativa (a pessoa pode repetir).
  final String? error;
}

class CancellationSubmitting extends CancellationState {
  const CancellationSubmitting(this.policy);

  final CancellationPolicy policy;
}

/// A reserva não paga foi cancelada.
class CancellationDone extends CancellationState {
  const CancellationDone();
}

/// O pedido de reembolso terminou (concluído) ou ficou registrado (falhou /
/// pedido): os três estados são visíveis.
class RefundFinished extends CancellationState {
  const RefundFinished(this.result, this.policy);

  final RefundRequestResult result;
  final CancellationPolicy policy;
}
