import 'package:freezed_annotation/freezed_annotation.dart';

import 'seat_status.dart';

part 'seat.freezed.dart';

/// Assento de um voo (`bookable`) — espelha `Seat` do backend.
@freezed
abstract class Seat with _$Seat {
  const factory Seat({
    required int id,
    required int bookableId,
    required String label,
    required SeatStatus status,
  }) = _Seat;
}
