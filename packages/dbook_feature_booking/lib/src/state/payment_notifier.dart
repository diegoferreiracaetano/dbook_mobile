import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';
import 'payment_state.dart';

class PaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() => const PaymentState.idle();

  Future<void> pay({
    required List<int> bookingIds,
    required String cardLast4,
    required String cardholderName,
  }) async {
    state = const PaymentState.submitting();
    try {
      final payment = await ref
          .read(paymentRepositoryProvider)
          .pay(
            bookingIds: bookingIds,
            cardLast4: cardLast4,
            cardholderName: cardholderName,
          );
      // As reservas pagas passam de PENDING pra CONFIRMED no backend —
      // invalida "Minhas Viagens" pra refletir isso na próxima leitura.
      ref.invalidate(myBookingsNotifierProvider);
      state = PaymentState.paid(payment);
    } on DbookNetworkException catch (error) {
      state = PaymentState.error(error.message);
    }
  }
}
