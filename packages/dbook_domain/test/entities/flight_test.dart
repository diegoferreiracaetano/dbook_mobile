import 'package:dbook_domain/dbook_domain.dart';
import 'package:test/test.dart';

void main() {
  Flight buildFlight({double price = 450}) {
    return Flight(
      id: 1,
      flightNumber: 'IB 6821',
      airlineIataCode: 'IB',
      airlineName: 'Iberia',
      originIataCode: 'GRU',
      destinationIataCode: 'MAD',
      departureTime: DateTime(2026, 1, 13, 10, 30),
      arrivalTime: DateTime(2026, 1, 14, 6, 45),
      seatClass: SeatClass.economy,
      price: price,
      availableCapacity: 42,
    );
  }

  test(
    'given two flights with the same fields when compared then they are equal',
    () {
      expect(buildFlight(), buildFlight());
    },
  );

  test(
    'given a flight when copyWith changes the price then only price differs',
    () {
      final original = buildFlight();
      final repriced = original.copyWith(price: 612);

      expect(repriced.price, 612);
      expect(repriced.flightNumber, original.flightNumber);
      expect(repriced, isNot(equals(original)));
    },
  );
}
