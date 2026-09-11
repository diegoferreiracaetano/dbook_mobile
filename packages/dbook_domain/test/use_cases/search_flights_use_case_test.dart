import 'package:dbook_domain/dbook_domain.dart';
import 'package:test/test.dart';

class _FakeFlightRepository implements FlightRepository {
  _FakeFlightRepository(this.flights);

  final List<Flight> flights;
  String? capturedOrigin;
  String? capturedDestination;
  DateTime? capturedDate;

  @override
  Future<List<Flight>> search({
    required String originIataCode,
    required String destinationIataCode,
    required DateTime date,
  }) async {
    capturedOrigin = originIataCode;
    capturedDestination = destinationIataCode;
    capturedDate = date;
    return flights;
  }

  @override
  Future<List<Seat>> getSeats(int bookableId) async => [];
}

void main() {
  test(
    'given matching flights when called then forwards params and returns them',
    () async {
      final flight = Flight(
        id: 1,
        flightNumber: 'IB 6821',
        originIataCode: 'GRU',
        destinationIataCode: 'MAD',
        departureTime: DateTime(2026, 1, 13, 10, 30),
        arrivalTime: DateTime(2026, 1, 14, 6, 45),
        seatClass: SeatClass.economy,
        price: 450,
        availableCapacity: 12,
      );
      final repository = _FakeFlightRepository([flight]);
      final useCase = SearchFlightsUseCase(repository);
      final date = DateTime(2026, 1, 13);

      final result = await useCase(
        originIataCode: 'GRU',
        destinationIataCode: 'MAD',
        date: date,
      );

      expect(result, [flight]);
      expect(repository.capturedOrigin, 'GRU');
      expect(repository.capturedDestination, 'MAD');
      expect(repository.capturedDate, date);
    },
  );
}
