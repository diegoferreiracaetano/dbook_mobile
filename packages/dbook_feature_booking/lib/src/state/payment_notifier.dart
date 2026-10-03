import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';
import 'payment_state.dart';

/// Uma tentativa de pagamento: o pedido e a chave de idempotência que o
/// identifica no backend.
class _PaymentAttempt {
  const _PaymentAttempt({
    required this.key,
    required this.bookingIds,
    required this.cardLast4,
    required this.cardholderName,
  });

  final String key;
  final List<int> bookingIds;
  final String cardLast4;
  final String cardholderName;

  bool isFor({
    required List<int> bookingIds,
    required String cardLast4,
    required String cardholderName,
  }) =>
      listEquals(this.bookingIds, bookingIds) &&
      this.cardLast4 == cardLast4 &&
      this.cardholderName == cardholderName;
}

class PaymentNotifier extends Notifier<PaymentState> {
  _PaymentAttempt? _attempt;

  @override
  PaymentState build() => const PaymentState.idle();

  Future<void> pay({
    required List<int> bookingIds,
    required String cardLast4,
    required String cardholderName,
  }) async {
    final attempt = _attemptFor(
      bookingIds: bookingIds,
      cardLast4: cardLast4,
      cardholderName: cardholderName,
    );
    state = const PaymentState.submitting();
    try {
      final payment = await ref
          .read(paymentRepositoryProvider)
          .pay(
            bookingIds: bookingIds,
            cardLast4: cardLast4,
            cardholderName: cardholderName,
            idempotencyKey: attempt.key,
          );

      _attempt = null;
      // As reservas pagas passam de PENDING pra CONFIRMED no backend —
      // invalida "Minhas Viagens" pra refletir isso na próxima leitura.
      ref.invalidate(myBookingsNotifierProvider);
      state = PaymentState.paid(payment);
    } on DbookNetworkException catch (error) {
      state = PaymentState.error(error.message);
    }
  }

  _PaymentAttempt _attemptFor({
    required List<int> bookingIds,
    required String cardLast4,
    required String cardholderName,
  }) {
    final current = _attempt;
    if (current != null &&
        current.isFor(
          bookingIds: bookingIds,
          cardLast4: cardLast4,
          cardholderName: cardholderName,
        )) {
      return current;
    }
    final fresh = _PaymentAttempt(
      key: ref.read(idempotencyKeyGeneratorProvider)(),
      bookingIds: List.of(bookingIds),
      cardLast4: cardLast4,
      cardholderName: cardholderName,
    );
    _attempt = fresh;
    return fresh;
  }
}
