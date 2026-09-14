import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBookingRepository implements BookingRepository {
  _FakeBookingRepository({List<MyBooking> initial = const [], this.cancelError})
    : _bookings = {for (final booking in initial) booking.id: booking};

  final DbookNetworkException? cancelError;
  final Map<int, MyBooking> _bookings;
  var listMineCallCount = 0;
  var cancelCallCount = 0;

  @override
  Future<Booking> create({required int bookableId, required int seatId}) {
    throw UnimplementedError();
  }

  @override
  Future<Booking> cancel(int bookingId) async {
    cancelCallCount++;
    if (cancelError != null) throw cancelError!;
    final current = _bookings[bookingId]!;
    _bookings[bookingId] = current.copyWith(status: BookingStatus.cancelled);
    return Booking(
      id: bookingId,
      bookableId: current.flight.id,
      seatId: current.seat.id,
      customerId: 7,
      status: BookingStatus.cancelled,
    );
  }

  @override
  Future<List<MyBooking>> listMine() async {
    listMineCallCount++;
    return _bookings.values.toList();
  }
}

const _seat = Seat(
  id: 1,
  bookableId: 1,
  label: '3A',
  status: SeatStatus.available,
);

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

MyBooking _myBooking({
  int id = 99,
  BookingStatus status = BookingStatus.pending,
}) => MyBooking(id: id, status: status, flight: _flight(), seat: _seat);

void main() {
  test(
    'given no bookings on the backend when built then starts empty',
    () async {
      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(_FakeBookingRepository()),
        ],
      );
      addTearDown(container.dispose);

      final bookings = await container.read(myBookingsNotifierProvider.future);

      expect(bookings, isEmpty);
    },
  );

  test('given bookings on the backend when built then lists them', () async {
    final repository = _FakeBookingRepository(initial: [_myBooking()]);
    final container = ProviderContainer(
      overrides: [bookingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final bookings = await container.read(myBookingsNotifierProvider.future);

    expect(bookings, [_myBooking()]);
    expect(repository.listMineCallCount, 1);
  });

  test('given a pending booking when cancelled then the refetched list shows '
      'it cancelled', () async {
    final repository = _FakeBookingRepository(initial: [_myBooking()]);
    final container = ProviderContainer(
      overrides: [bookingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await container.read(myBookingsNotifierProvider.future);

    await container.read(myBookingsNotifierProvider.notifier).cancel(99);

    expect(repository.cancelCallCount, 1);
    expect(repository.listMineCallCount, 2);
    final bookings = container.read(myBookingsNotifierProvider).requireValue;
    expect(bookings.single.status, BookingStatus.cancelled);
  });

  test('given the backend rejects the cancellation then the exception '
      'propagates and the list stays unchanged', () async {
    final repository = _FakeBookingRepository(
      initial: [_myBooking()],
      cancelError: const DbookForbiddenException('Not your booking'),
    );
    final container = ProviderContainer(
      overrides: [bookingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await container.read(myBookingsNotifierProvider.future);

    await expectLater(
      container.read(myBookingsNotifierProvider.notifier).cancel(99),
      throwsA(isA<DbookForbiddenException>()),
    );

    expect(repository.listMineCallCount, 1);
    final bookings = container.read(myBookingsNotifierProvider).requireValue;
    expect(bookings.single.status, BookingStatus.pending);
  });
}
