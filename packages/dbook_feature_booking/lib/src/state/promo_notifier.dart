import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';
import 'promo_state.dart';

/// Valida o código ao sair do campo e guarda o desconto previsto. **Não
/// calcula nada**: subtotal, desconto e total vêm do servidor
/// (`/promo-codes/validate`), a mesma conta que o pagamento fará.
class PromoNotifier extends Notifier<PromoState> {
  @override
  PromoState build() => const PromoNone();

  Future<void> validate(String code, List<int> bookingIds) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      state = const PromoNone();
      return;
    }
    state = PromoValidating(trimmed);
    try {
      final preview = await ref
          .read(promoRepositoryProvider)
          .validate(code: trimmed, bookingIds: bookingIds);
      state = PromoApplied(preview);
    } on DbookNetworkException catch (error) {
      state = PromoRejected(
        code: trimmed,
        reason: promoRejectionMessage(error),
      );
    }
  }

  void remove() => state = const PromoNone();
}

/// A mensagem para o cliente, pelo tipo de falha. O servidor devolve só
/// `PROMO_REJECTED` (com o motivo no texto), então o texto do motivo é a
/// única pista para distinguir expirado, esgotado e mínimo; mapeamos as
/// palavras conhecidas e, no resto, uma frase geral.
String promoRejectionMessage(DbookNetworkException error) {
  if (error is DbookNotFoundException) {
    return 'Esse código não existe. Confira a digitação.';
  }
  if (error is! DbookUnprocessableException && error.code != 'PROMO_REJECTED') {
    return 'Não deu para conferir o código agora. Tente de novo.';
  }
  final text = error.message.toLowerCase();
  if (text.contains('expir') || text.contains('valid')) {
    return 'Esse código já venceu ou ainda não começou.';
  }
  if (text.contains('minimum') ||
      text.contains('mínimo') ||
      text.contains('at least')) {
    return 'O total desta compra está abaixo do mínimo para este código.';
  }
  if (text.contains('exhaust') ||
      text.contains('esgot') ||
      text.contains('limit')) {
    return 'Esse código esgotou ou você já usou o limite dele.';
  }
  return 'Esse código não pode ser usado nesta compra.';
}

final promoNotifierProvider =
    NotifierProvider.autoDispose<PromoNotifier, PromoState>(PromoNotifier.new);
