import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/mock_network_image.dart';

class _FakeBookingRepository implements BookingRepository {
  _FakeBookingRepository({List<MyBooking> initial = const [], this.cancelError})
    : _bookings = {for (final booking in initial) booking.id: booking};

  final DbookNetworkException? cancelError;
  final Map<int, MyBooking> _bookings;

  @override
  Future<Booking> create({required int bookableId, required int seatId}) {
    throw UnimplementedError();
  }

  @override
  Future<Booking> cancel(int bookingId) async {
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
  Future<List<MyBooking>> listMine() async => _bookings.values.toList();
}

const _seat = Seat(
  id: 1,
  bookableId: 1,
  label: '3A',
  status: SeatStatus.available,
);

final _future = DateTime.now().add(const Duration(days: 30));
final _past = DateTime.now().subtract(const Duration(days: 30));

Flight _flight({DateTime? departureTime, String destinationIataCode = 'MAD'}) =>
    Flight(
      id: 1,
      flightNumber: 'IB 6821',
      airlineIataCode: 'IB',
      airlineName: 'Iberia',
      originIataCode: 'GRU',
      destinationIataCode: destinationIataCode,
      departureTime: departureTime ?? _future,
      arrivalTime: (departureTime ?? _future).add(const Duration(hours: 3)),
      seatClass: SeatClass.economy,
      price: 450,
      availableCapacity: 12,
      aircraftType: 'Airbus A320',
      seatLayout: const [3, 3],
    );

MyBooking _myBooking({
  int id = 99,
  BookingStatus status = BookingStatus.pending,
  DateTime? departureTime,
  String destinationIataCode = 'MAD',
}) => MyBooking(
  id: id,
  status: status,
  flight: _flight(
    departureTime: departureTime,
    destinationIataCode: destinationIataCode,
  ),
  seat: _seat,
);

Widget _wrap(
  BookingRepository bookingRepository, {
  List<Destination> destinations = const [],
}) {
  return ProviderScope(
    overrides: [bookingRepositoryProvider.overrideWithValue(bookingRepository)],
    child: MaterialApp(
      theme: DbookTheme.light,
      home: MyBookingsPage(destinations: destinations),
    ),
  );
}

void main() {
  testWidgetsWithMockImages(
    'given no bookings when built then shows the empty state',
    (tester) async {
      await tester.pumpWidget(_wrap(_FakeBookingRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma reserva ainda'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a pending upcoming booking when built then shows it under '
    'Próximas with a cancel action',
    (tester) async {
      await tester.pumpWidget(
        _wrap(_FakeBookingRepository(initial: [_myBooking()])),
      );
      await tester.pumpAndSettle();

      expect(find.text('GRU → MAD'), findsOneWidget);
      expect(find.text('Cancel Booking'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a confirmed booking when built then shows no cancel action',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeBookingRepository(
            initial: [_myBooking(status: BookingStatus.confirmed)],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancel Booking'), findsNothing);
    },
  );

  testWidgetsWithMockImages(
    'given a past booking when built then it only shows under Anteriores, '
    'not Próximas',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeBookingRepository(
            initial: [
              _myBooking(departureTime: _past, status: BookingStatus.confirmed),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma viagem futura'), findsOneWidget);
      expect(find.text('GRU → MAD'), findsNothing);

      await tester.tap(find.text('Anteriores'));
      await tester.pumpAndSettle();

      expect(find.text('GRU → MAD'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given cancel confirmed when tapped then re-fetches and shows it '
    'cancelled',
    (tester) async {
      await tester.pumpWidget(
        _wrap(_FakeBookingRepository(initial: [_myBooking()])),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel Booking'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel Booking').last);
      await tester.pumpAndSettle();

      expect(find.text('Cancelada'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given the backend rejects the cancellation then shows a snackbar and '
    'keeps the pending status',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeBookingRepository(
            initial: [_myBooking()],
            cancelError: const DbookForbiddenException('Not your booking'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel Booking'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel Booking').last);
      await tester.pumpAndSettle();

      expect(find.text('Not your booking'), findsOneWidget);
      expect(find.text('Pendente'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a destination in the catalog when built then shows its real '
    'photo instead of the fallback',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeBookingRepository(initial: [_myBooking()]),
          destinations: const [
            Destination(
              iataCode: 'MAD',
              city: 'Madrid',
              country: 'Espanha',
              photoUrl: 'https://example.com/madrid.jpg',
              region: 'Europa',
              isPopular: true,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    },
  );
}
