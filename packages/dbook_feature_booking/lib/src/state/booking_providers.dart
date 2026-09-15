import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'my_bookings_notifier.dart';
import 'payment_notifier.dart';
import 'payment_state.dart';
import 'seat_selection_notifier.dart';
import 'seat_selection_state.dart';

/// Só usado internamente pra buscar o mapa de assentos (`GetSeatsUseCase`
/// mora no `FlightRepository`, não no `BookingRepository`) — não exportado
/// pelo barrel (veja `dbook_feature_booking.dart`): `dbook_feature_flights`
/// já tem o seu próprio, e features não devem importar features umas das
/// outras, então cada uma monta sua própria fiação fina em cima do mesmo
/// `dioProvider` compartilhado. Não é privado (`_`) porque
/// `seat_selection_notifier.dart`, noutro arquivo, precisa enxergá-lo.
final flightRepositoryProvider = Provider<FlightRepository>(
  (ref) => FlightRepositoryImpl(ref.watch(dioProvider)),
);

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepositoryImpl(ref.watch(dioProvider)),
);

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepositoryImpl(ref.watch(dioProvider)),
);

final myBookingsNotifierProvider =
    AsyncNotifierProvider<MyBookingsNotifier, List<MyBooking>>(
      MyBookingsNotifier.new,
    );

final seatSelectionNotifierProvider =
    NotifierProvider<SeatSelectionNotifier, SeatSelectionState>(
      SeatSelectionNotifier.new,
    );

final paymentNotifierProvider = NotifierProvider<PaymentNotifier, PaymentState>(
  PaymentNotifier.new,
);
