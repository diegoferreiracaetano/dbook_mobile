import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_payment_request_dto.freezed.dart';
part 'register_payment_request_dto.g.dart';

/// Corpo de `POST /payments` — só os 4 últimos dígitos do cartão e o nome
/// do titular, nunca o número completo ou o CVV.
@freezed
abstract class RegisterPaymentRequestDto with _$RegisterPaymentRequestDto {
  const factory RegisterPaymentRequestDto({
    required List<int> bookingIds,
    required String cardLast4,
    required String cardholderName,
  }) = _RegisterPaymentRequestDto;

  factory RegisterPaymentRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterPaymentRequestDtoFromJson(json);
}
