import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';

/// Pagamento — espelha `PaymentResponse` do backend. Cobre uma ou mais
/// reservas de uma vez (ex. ida + volta de uma Round Trip, num único
/// pagamento) — [bookingIds] é a lista de reservas confirmadas por ele.
@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    required int id,
    required double amount,
    required String cardLast4,
    required List<int> bookingIds,
    required String status,
  }) = _Payment;
}
