import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _booking = Booking(
  id: 9,
  bookableId: 1,
  seatId: 10,
  customerId: 7,
  status: BookingStatus.pending,
);

const _seat = Seat(
  id: 10,
  bookableId: 1,
  label: '1B',
  status: SeatStatus.reserved,
);

Flight _flight() => Flight(
  id: 1,
  flightNumber: 'DBS00141',
  airlineIataCode: 'DL',
  airlineName: 'Delta Air Lines',
  originIataCode: 'GRU',
  destinationIataCode: 'GIG',
  departureTime: DateTime(2026, 9, 15, 6),
  arrivalTime: DateTime(2026, 9, 15, 9),
  seatClass: SeatClass.business,
  price: 1479,
  availableCapacity: 100,
  aircraftType: 'Airbus A320',
  seatLayout: const [3, 3],
);

Widget _app(Widget home) => MaterialApp(theme: DbookTheme.light, home: home);

void main() {
  testWidgets('given no next leg when built then offers View My Bookings', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        BookingSuccessPage(booking: _booking, flight: _flight(), seat: _seat),
      ),
    );

    expect(find.text('View My Bookings'), findsOneWidget);
    expect(find.textContaining('Choose Seat'), findsNothing);
  });

  testWidgets(
    'given a next leg (Round Trip/Multi-city) when built then offers to '
    'choose its seat directly, without searching again',
    (tester) async {
      var nextLegTapCount = 0;

      await tester.pumpWidget(
        _app(
          BookingSuccessPage(
            booking: _booking,
            flight: _flight(),
            seat: _seat,
            nextLegLabel: 'GIG → GRU',
            onNextLeg: () => nextLegTapCount++,
          ),
        ),
      );

      expect(find.text('Choose Seat: GIG → GRU'), findsOneWidget);
      expect(find.text('View My Bookings'), findsNothing);

      await tester.tap(find.text('Choose Seat: GIG → GRU'));

      expect(nextLegTapCount, 1);
    },
  );
}
