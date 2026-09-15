import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_state.freezed.dart';

@freezed
sealed class PaymentState with _$PaymentState {
  const factory PaymentState.idle() = PaymentIdle;
  const factory PaymentState.submitting() = PaymentSubmitting;
  const factory PaymentState.error(String message) = PaymentError;
  const factory PaymentState.paid(Payment payment) = PaymentPaid;
}
