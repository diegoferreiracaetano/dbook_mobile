import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'booking_record.dart';

part 'seat_selection_state.freezed.dart';

@freezed
sealed class SeatSelectionState with _$SeatSelectionState {
  const factory SeatSelectionState.idle() = SeatSelectionIdle;
  const factory SeatSelectionState.loadingSeats() = SeatSelectionLoadingSeats;
  const factory SeatSelectionState.seatsError(String message) =
      SeatSelectionSeatsError;

  /// Estado "hub": mantém o mapa de assentos e a seleção mesmo se uma
  /// tentativa de reservar falhar (409 sem disponibilidade, por exemplo) —
  /// perder o mapa inteiro por causa de um erro de reserva seria pior UX
  /// do que só mostrar o erro e deixar tentar de novo.
  const factory SeatSelectionState.ready({
    required List<Seat> seats,
    Seat? selected,
    @Default(false) bool isBooking,
    String? bookingError,
  }) = SeatSelectionReady;

  const factory SeatSelectionState.booked(BookingRecord record) =
      SeatSelectionBooked;
}
