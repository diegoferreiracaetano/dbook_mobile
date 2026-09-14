import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';
import 'seat_selection_state.dart';

class SeatSelectionNotifier extends Notifier<SeatSelectionState> {
  @override
  SeatSelectionState build() => const SeatSelectionState.idle();

  Future<void> loadSeats(Flight flight) async {
    state = const SeatSelectionState.loadingSeats();
    try {
      final seats = await ref
          .read(flightRepositoryProvider)
          .getSeats(flight.id);
      state = SeatSelectionState.ready(seats: seats);
    } on DbookNetworkException catch (error) {
      state = SeatSelectionState.seatsError(error.message);
    }
  }

  void selectSeat(Seat seat) {
    final current = state;
    if (current is SeatSelectionReady) {
      state = current.copyWith(selected: seat, bookingError: null);
    }
  }

  Future<void> confirmBooking(Flight flight) async {
    final current = state;
    if (current is! SeatSelectionReady) return;
    final seat = current.selected;
    if (seat == null) return;

    state = current.copyWith(isBooking: true, bookingError: null);
    try {
      final booking = await ref
          .read(bookingRepositoryProvider)
          .create(bookableId: flight.id, seatId: seat.id);
      // "Minhas Viagens" agora vem sempre do backend (GET /bookings) —
      // invalida pra refletir a reserva nova na próxima vez que a lista for
      // lida, sem esperar por isso aqui (a tela de sucesso não depende
      // dela).
      ref.invalidate(myBookingsNotifierProvider);
      state = SeatSelectionState.booked(
        booking: booking,
        flight: flight,
        seat: seat,
      );
    } on DbookNetworkException catch (error) {
      state = current.copyWith(isBooking: false, bookingError: error.message);
    }
  }
}
