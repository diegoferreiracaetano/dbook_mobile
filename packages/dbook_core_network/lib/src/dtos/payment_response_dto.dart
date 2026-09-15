import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_response_dto.freezed.dart';
part 'payment_response_dto.g.dart';

/// Resposta de `POST /payments`.
@freezed
abstract class PaymentResponseDto with _$PaymentResponseDto {
  const PaymentResponseDto._();

  const factory PaymentResponseDto({
    required int id,
    required double amount,
    required String cardLast4,
    required List<int> bookingIds,
    required String status,
  }) = _PaymentResponseDto;

  factory PaymentResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentResponseDtoFromJson(json);

  Payment toDomain() => Payment(
    id: id,
    amount: amount,
    cardLast4: cardLast4,
    bookingIds: bookingIds,
    status: status,
  );
}
