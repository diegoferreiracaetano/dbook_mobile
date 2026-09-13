import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBookingRepository implements BookingRepository {
  _FakeBookingRepository({this.error});

  final DbookNetworkException? error;
  var cancelCallCount = 0;

  @override
  Future<Booking> create({required int bookableId, required int seatId}) {
    throw UnimplementedError();
  }

  @override
  Future<Booking> cancel(int bookingId) async {
    cancelCallCount++;
    if (error != null) throw error!;
    return Booking(
      id: bookingId,
      bookableId: 1,
      seatId: 1,
      customerId: 7,
      status: BookingStatus.cancelled,
    );
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
);

BookingRecord _record({BookingStatus status = BookingStatus.pending}) =>
    BookingRecord(
      booking: Booking(
        id: 99,
        bookableId: 1,
        seatId: 1,
        customerId: 7,
        status: status,
      ),
      flight: _flight(),
      seat: _seat,
    );

void main() {
  test('given fresh state when built then starts empty', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(myBookingsNotifierProvider), isEmpty);
  });

  test('given a record when added then it shows up in the list', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final record = _record();

    container.read(myBookingsNotifierProvider.notifier).add(record);

    expect(container.read(myBookingsNotifierProvider), [record]);
  });

  test('given a pending booking when cancelled then its status updates in '
      'place', () async {
    final repository = _FakeBookingRepository();
    final container = ProviderContainer(
      overrides: [bookingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final record = _record();
    container.read(myBookingsNotifierProvider.notifier).add(record);

    await container.read(myBookingsNotifierProvider.notifier).cancel(record);

    expect(repository.cancelCallCount, 1);
    expect(
      container.read(myBookingsNotifierProvider).single.booking.status,
      BookingStatus.cancelled,
    );
  });

  test('given the backend rejects the cancellation then the exception '
      'propagates and the list stays unchanged', () async {
    final repository = _FakeBookingRepository(
      error: const DbookForbiddenException('Not your booking'),
    );
    final container = ProviderContainer(
      overrides: [bookingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final record = _record();
    container.read(myBookingsNotifierProvider.notifier).add(record);

    await expectLater(
      container.read(myBookingsNotifierProvider.notifier).cancel(record),
      throwsA(isA<DbookForbiddenException>()),
    );

    expect(
      container.read(myBookingsNotifierProvider).single.booking.status,
      BookingStatus.pending,
    );
  });
}
