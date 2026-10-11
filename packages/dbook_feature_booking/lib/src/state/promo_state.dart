import 'package:dbook_domain/dbook_domain.dart';

/// O código promocional na tela de pagamento.
sealed class PromoState {
  const PromoState();
}

/// Nenhum código aplicado.
class PromoNone extends PromoState {
  const PromoNone();
}

class PromoValidating extends PromoState {
  const PromoValidating(this.code);

  final String code;
}

/// O servidor prevê este desconto. O dinheiro só é decidido ao pagar.
class PromoApplied extends PromoState {
  const PromoApplied(this.preview);

  final PromoPreview preview;
}

/// O código foi recusado. [reason] diz por que, em português, pelo `code` do
/// erro (não pelo texto cru do servidor).
class PromoRejected extends PromoState {
  const PromoRejected({required this.code, required this.reason});

  final String code;
  final String reason;
}
