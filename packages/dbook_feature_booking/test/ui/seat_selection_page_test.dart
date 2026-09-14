import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:dbook_feature_booking/src/state/booking_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFlightRepository implements FlightRepository {
  _FakeFlightRepository({this.seats = const []});

  final List<Seat> seats;

  @override
  Future<List<Flight>> search({
    required String originIataCode,
    required String destinationIataCode,
    required DateTime date,
  }) async => [];

  @override
  Future<List<Seat>> getSeats(int bookableId) async => seats;
}

class _FakeBookingRepository implements BookingRepository {
  _FakeBookingRepository({this.error});

  final DbookNetworkException? error;

  @override
  Future<Booking> create({required int bookableId, required int seatId}) async {
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
  Future<Booking> cancel(int bookingId) async => throw UnimplementedError();

  @override
  Future<List<MyBooking>> listMine() async => [];
}

const _availableSeat = Seat(
  id: 1,
  bookableId: 1,
  label: '3A',
  status: SeatStatus.available,
);
const _reservedSeat = Seat(
  id: 2,
  bookableId: 1,
  label: '3B',
  status: SeatStatus.reserved,
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

List<Seat> _fullRow(int row, List<String> letters) => [
  for (final letter in letters)
    Seat(
      id: row * 100 + letters.indexOf(letter),
      bookableId: 1,
      label: '$row$letter',
      status: SeatStatus.available,
    ),
];

Widget _wrap(
  Widget child, {
  required FlightRepository flightRepository,
  required BookingRepository bookingRepository,
}) {
  return ProviderScope(
    overrides: [
      flightRepositoryProvider.overrideWithValue(flightRepository),
      bookingRepositoryProvider.overrideWithValue(bookingRepository),
    ],
    child: MaterialApp(theme: DbookTheme.light, home: child),
  );
}

void main() {
  testWidgets('given seats when the page settles then renders every cell', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SeatSelectionPage(flight: _flight()),
        flightRepository: _FakeFlightRepository(
          seats: const [_availableSeat, _reservedSeat],
        ),
        bookingRepository: _FakeBookingRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DbookSeatCell), findsNWidgets(2));
    expect(find.text('Select a seat'), findsOneWidget);
  });

  testWidgets(
    'given an available seat tapped then the button reflects the selection',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          SeatSelectionPage(flight: _flight()),
          flightRepository: _FakeFlightRepository(
            seats: const [_availableSeat, _reservedSeat],
          ),
          bookingRepository: _FakeBookingRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DbookSeatCell).first);
      await tester.pump();

      expect(find.text('Book Seat 3A'), findsOneWidget);
    },
  );

  testWidgets(
    'given a seat selected when confirmed then books and shows the success '
    'screen',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          SeatSelectionPage(flight: _flight()),
          flightRepository: _FakeFlightRepository(
            seats: const [_availableSeat],
          ),
          bookingRepository: _FakeBookingRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DbookSeatCell).first);
      await tester.pump();
      await tester.tap(find.text('Book Seat 3A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Book'));
      await tester.pumpAndSettle();

      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(find.text('#99'), findsOneWidget);
    },
  );

  testWidgets(
    'given the backend rejects the booking then keeps the seat map and '
    'shows the error',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          SeatSelectionPage(flight: _flight()),
          flightRepository: _FakeFlightRepository(
            seats: const [_availableSeat],
          ),
          bookingRepository: _FakeBookingRepository(
            error: const DbookConflictException('Seat no longer available'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DbookSeatCell).first);
      await tester.pump();
      await tester.tap(find.text('Book Seat 3A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Book'));
      await tester.pumpAndSettle();

      expect(find.text('Seat no longer available'), findsOneWidget);
      expect(find.byType(DbookSeatCell), findsOneWidget);
    },
  );

  testWidgets(
    'given a 2+2 layout with a full row when the page settles then it '
    'renders one block of 2 and another of 2, all 4 seats',
    (tester) async {
      final flight = _flight().copyWith(
        aircraftType: 'Embraer E195',
        seatLayout: const [2, 2],
      );

      await tester.pumpWidget(
        _wrap(
          SeatSelectionPage(flight: flight),
          flightRepository: _FakeFlightRepository(
            seats: _fullRow(1, ['A', 'B', 'C', 'D']),
          ),
          bookingRepository: _FakeBookingRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DbookSeatCell), findsNWidgets(4));
      for (final label in ['1A', '1B', '1C', '1D']) {
        expect(find.text(label), findsOneWidget);
      }
    },
  );

  testWidgets(
    'given a 3+4+3 layout (widebody) with a full row when the page settles '
    'then it renders all 10 seats across 3 blocks',
    (tester) async {
      final flight = _flight().copyWith(
        aircraftType: 'Boeing 777',
        seatLayout: const [3, 4, 3],
      );
      final letters = 'ABCDEFGHIJ'.split('');

      await tester.pumpWidget(
        _wrap(
          SeatSelectionPage(flight: flight),
          flightRepository: _FakeFlightRepository(seats: _fullRow(1, letters)),
          bookingRepository: _FakeBookingRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DbookSeatCell), findsNWidgets(10));
      for (final letter in letters) {
        expect(find.text('1$letter'), findsOneWidget);
      }
    },
  );
}
