import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Flight _flight({required String origin, required String destination}) => Flight(
  id: 1,
  flightNumber: 'IB 6821',
  airlineIataCode: 'IB',
  airlineName: 'Iberia',
  originIataCode: origin,
  destinationIataCode: destination,
  departureTime: DateTime(2026, 1, 13, 10, 30),
  arrivalTime: DateTime(2026, 1, 14, 6, 45),
  seatClass: SeatClass.economy,
  price: 500,
  availableCapacity: 12,
  aircraftType: 'Airbus A320',
  seatLayout: const [3, 3],
);

const _outboundBooking = Booking(
  id: 1,
  bookableId: 1,
  seatId: 10,
  customerId: 7,
  status: BookingStatus.confirmed,
);
const _returnBooking = Booking(
  id: 2,
  bookableId: 2,
  seatId: 20,
  customerId: 7,
  status: BookingStatus.confirmed,
);
const _outboundSeat = Seat(
  id: 10,
  bookableId: 1,
  label: '12A',
  status: SeatStatus.reserved,
);
const _returnSeat = Seat(
  id: 20,
  bookableId: 2,
  label: '8C',
  status: SeatStatus.reserved,
);

void main() {
  testWidgets('given a payment covering two legs when built then shows both as '
      'detail lines and the real total', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: PaymentSuccessPage(
          payment: const Payment(
            id: 55,
            amount: 800,
            cardLast4: '4242',
            bookingIds: [1, 2],
            status: 'CONFIRMED',
          ),
          bookedLegs: [
            (
              booking: _outboundBooking,
              flight: _flight(origin: 'GRU', destination: 'GIG'),
              seat: _outboundSeat,
            ),
            (
              booking: _returnBooking,
              flight: _flight(origin: 'GIG', destination: 'GRU'),
              seat: _returnSeat,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Payment Confirmed!'), findsOneWidget);
    expect(find.textContaining('GRU → GIG · Seat 12A'), findsOneWidget);
    expect(find.textContaining('GIG → GRU · Seat 8C'), findsOneWidget);
    expect(find.textContaining('\$800.00'), findsOneWidget);
    expect(find.text('#55'), findsOneWidget);
    expect(find.text('View My Bookings'), findsOneWidget);
  });
}
