import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:dbook_feature_booking/src/state/booking_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFlightRepository implements FlightRepository {
  _FakeFlightRepository({this.seats = const [], this.error});

  final List<Seat> seats;
  final DbookNetworkException? error;

  @override
  Future<List<Flight>> search({
    required String originIataCode,
    required String destinationIataCode,
    required DateTime date,
  }) async => [];

  @override
  Future<List<Seat>> getSeats(int bookableId) async {
    if (error != null) throw error!;
    return seats;
  }
}

class _FakeBookingRepository implements BookingRepository {
  _FakeBookingRepository({this.error});

  final DbookNetworkException? error;
  var createCallCount = 0;
  int? capturedBookableId;
  int? capturedSeatId;

  @override
  Future<Booking> create({required int bookableId, required int seatId}) async {
    createCallCount++;
    capturedBookableId = bookableId;
    capturedSeatId = seatId;
    if (error != null) throw error!;
    return const Booking(
      id: 99,
      bookableId: 1,
      seatId: 1,
      customerId: 7,
      status: BookingStatus.pending,
    );
  }

  @override
  Future<Booking> cancel(int bookingId) async {
    throw UnimplementedError();
  }

  var listMineCallCount = 0;

  @override
  Future<List<MyBooking>> listMine() async {
    listMineCallCount++;
    return const [];
  }
}

Flight _flight() => Flight(
  id: 1,
  flightNumber: 'IB 6821',
  airlineIataCode: 'IB',
  airlineName: 'Iberia',
  originIataCode: 'GRU',
  destinationIataCode: 'MAD',
  departureTime: DateTime(2026, 1, 13, 10, 30),
  arrivalTime: DateTime(2026, 1, 14, 6, 45),
  seatClass: SeatClass.economy,
  price: 450,
  availableCapacity: 12,
  aircraftType: 'Airbus A320',
  seatLayout: const [3, 3],
);

const _seat = Seat(
  id: 1,
  bookableId: 1,
  label: '3A',
  status: SeatStatus.available,
);

ProviderContainer _buildContainer({
  required FlightRepository flightRepository,
  required BookingRepository bookingRepository,
}) {
  final container = ProviderContainer(
    overrides: [
      flightRepositoryProvider.overrideWithValue(flightRepository),
      bookingRepositoryProvider.overrideWithValue(bookingRepository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('given fresh state when built then starts idle', () {
    final container = _buildContainer(
      flightRepository: _FakeFlightRepository(),
      bookingRepository: _FakeBookingRepository(),
    );

    expect(
      container.read(seatSelectionNotifierProvider),
      const SeatSelectionState.idle(),
    );
  });

  test('given seats when loading then ends up ready with them', () async {
    final container = _buildContainer(
      flightRepository: _FakeFlightRepository(seats: const [_seat]),
      bookingRepository: _FakeBookingRepository(),
    );

    await container
        .read(seatSelectionNotifierProvider.notifier)
        .loadSeats(_flight());

    final state = container.read(seatSelectionNotifierProvider);
    expect(state, isA<SeatSelectionReady>());
    expect((state as SeatSelectionReady).seats, [_seat]);
    expect(state.selected, isNull);
  });

  test(
    'given the backend rejects loading seats then ends up in seatsError',
    () async {
      final container = _buildContainer(
        flightRepository: _FakeFlightRepository(
          error: const DbookNotFoundException('Flight not found'),
        ),
        bookingRepository: _FakeBookingRepository(),
      );

      await container
          .read(seatSelectionNotifierProvider.notifier)
          .loadSeats(_flight());

      final state = container.read(seatSelectionNotifierProvider);
      expect(state, isA<SeatSelectionSeatsError>());
      expect((state as SeatSelectionSeatsError).message, 'Flight not found');
    },
  );

  test(
    'given seats ready when a seat is selected then it is reflected',
    () async {
      final container = _buildContainer(
        flightRepository: _FakeFlightRepository(seats: const [_seat]),
        bookingRepository: _FakeBookingRepository(),
      );
      final notifier = container.read(seatSelectionNotifierProvider.notifier);
      await notifier.loadSeats(_flight());

      notifier.selectSeat(_seat);

      final state = container.read(seatSelectionNotifierProvider);
      expect((state as SeatSelectionReady).selected, _seat);
    },
  );

  test('given a selected seat when confirming then books, ends up in booked '
      'and invalidates the bookings list', () async {
    final bookingRepository = _FakeBookingRepository();
    final container = _buildContainer(
      flightRepository: _FakeFlightRepository(seats: const [_seat]),
      bookingRepository: bookingRepository,
    );
    // Primeira leitura, popula o cache — pra provar depois que o
    // confirmBooking() de fato invalida (não só reaproveita o cache).
    await container.read(myBookingsNotifierProvider.future);
    expect(bookingRepository.listMineCallCount, 1);

    final notifier = container.read(seatSelectionNotifierProvider.notifier);
    final flight = _flight();
    await notifier.loadSeats(flight);
    notifier.selectSeat(_seat);

    await notifier.confirmBooking(flight);

    expect(bookingRepository.createCallCount, 1);
    expect(bookingRepository.capturedBookableId, flight.id);
    expect(bookingRepository.capturedSeatId, _seat.id);
    final state = container.read(seatSelectionNotifierProvider);
    expect(state, isA<SeatSelectionBooked>());
    final booked = state as SeatSelectionBooked;
    expect(booked.seat, _seat);
    expect(booked.flight, flight);
    expect(booked.booking.id, 99);

    await container.read(myBookingsNotifierProvider.future);
    expect(bookingRepository.listMineCallCount, 2);
  });

  test('given no seat selected when confirming then does nothing', () async {
    final bookingRepository = _FakeBookingRepository();
    final container = _buildContainer(
      flightRepository: _FakeFlightRepository(seats: const [_seat]),
      bookingRepository: bookingRepository,
    );
    final notifier = container.read(seatSelectionNotifierProvider.notifier);
    final flight = _flight();
    await notifier.loadSeats(flight);

    await notifier.confirmBooking(flight);

    expect(bookingRepository.createCallCount, 0);
  });

  test('given the backend rejects the booking then keeps the seat map and '
      'surfaces the error', () async {
    final bookingRepository = _FakeBookingRepository(
      error: const DbookConflictException('Seat no longer available'),
    );
    final container = _buildContainer(
      flightRepository: _FakeFlightRepository(seats: const [_seat]),
      bookingRepository: bookingRepository,
    );
    final notifier = container.read(seatSelectionNotifierProvider.notifier);
    final flight = _flight();
    await notifier.loadSeats(flight);
    notifier.selectSeat(_seat);

    await notifier.confirmBooking(flight);

    final state = container.read(seatSelectionNotifierProvider);
    expect(state, isA<SeatSelectionReady>());
    final ready = state as SeatSelectionReady;
    expect(ready.seats, [_seat]);
    expect(ready.selected, _seat);
    expect(ready.isBooking, isFalse);
    expect(ready.bookingError, 'Seat no longer available');
    expect(
      bookingRepository.listMineCallCount,
      0,
      reason: 'a falha não deve invalidar/re-buscar a lista de reservas',
    );
  });
}
