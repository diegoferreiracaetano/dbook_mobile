import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../wire_enums.dart';

part 'seat_response_dto.freezed.dart';
part 'seat_response_dto.g.dart';

/// Item de `GET /bookables/{id}/seats`.
@freezed
abstract class SeatResponseDto with _$SeatResponseDto {
  const SeatResponseDto._();

  const factory SeatResponseDto({
    required int id,
    required String label,
    required String status,
  }) = _SeatResponseDto;

  factory SeatResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SeatResponseDtoFromJson(json);

  /// O endpoint não devolve `bookableId` no item (já está implícito na URL
  /// que o chamou), então quem faz a chamada passa de volta aqui.
  Seat toDomain(int bookableId) {
    return Seat(
      id: id,
      bookableId: bookableId,
      label: label,
      status: seatStatusFromWire(status),
    );
  }
}
