import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFlightRepository implements FlightRepository {
  _FakeFlightRepository({this.flights = const [], this.error});

  final List<Flight> flights;
  final DbookNetworkException? error;
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
    if (error != null) throw error!;
    return flights;
  }

  @override
  Future<List<Seat>> getSeats(int bookableId) async => [];
}

Flight _flight({SeatClass seatClass = SeatClass.economy}) => Flight(
  id: 1,
  flightNumber: 'IB 6821',
  airlineIataCode: 'IB',
  airlineName: 'Iberia',
  originIataCode: 'GRU',
  destinationIataCode: 'MAD',
  departureTime: DateTime(2026, 1, 13, 10, 30),
  arrivalTime: DateTime(2026, 1, 14, 6, 45),
  seatClass: seatClass,
  price: 450,
  availableCapacity: 12,
  aircraftType: 'Airbus A320',
  seatLayout: const [3, 3],
);

ProviderContainer _buildContainer(FlightRepository repository) {
  final container = ProviderContainer(
    overrides: [flightRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('given fresh state when built then starts idle', () {
    final container = _buildContainer(_FakeFlightRepository());

    expect(
      container.read(flightSearchNotifierProvider),
      const FlightSearchState.idle(),
    );
  });

  test('given matching flights when searching then forwards params and ends up '
      'in success', () async {
    final flight = _flight();
    final repository = _FakeFlightRepository(flights: [flight]);
    final container = _buildContainer(repository);
    final date = DateTime(2026, 1, 13);

    await container
        .read(flightSearchNotifierProvider.notifier)
        .search(originIataCode: 'GRU', destinationIataCode: 'MAD', date: date);

    final state = container.read(flightSearchNotifierProvider);
    expect(state, isA<FlightSearchSuccess>());
    expect((state as FlightSearchSuccess).flights, [flight]);
    expect(repository.capturedOrigin, 'GRU');
    expect(repository.capturedDestination, 'MAD');
    expect(repository.capturedDate, date);
  });

  test('given the backend rejects the search when searching then ends up in '
      'error with the backend message', () async {
    final repository = _FakeFlightRepository(
      error: const DbookNotFoundException('No flights for that route'),
    );
    final container = _buildContainer(repository);

    await container
        .read(flightSearchNotifierProvider.notifier)
        .search(
          originIataCode: 'GRU',
          destinationIataCode: 'ZZZ',
          date: DateTime(2026, 1, 13),
        );

    final state = container.read(flightSearchNotifierProvider);
    expect(state, isA<FlightSearchError>());
    expect((state as FlightSearchError).message, 'No flights for that route');
  });
}
