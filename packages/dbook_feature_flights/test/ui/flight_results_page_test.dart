import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFlightRepository implements FlightRepository {
  _FakeFlightRepository({this.flights = const [], this.error});

  final List<Flight> flights;
  final DbookNetworkException? error;

  @override
  Future<List<Flight>> search({
    required String originIataCode,
    required String destinationIataCode,
    required DateTime date,
  }) async {
    if (error != null) throw error!;
    return flights;
  }

  @override
  Future<List<Seat>> getSeats(int bookableId) async => [];
}

final _query = FlightSearchQuery(
  origin: knownAirports[0],
  destination: knownAirports[1],
  date: DateTime(2026, 1, 13),
);

Flight _flight() => Flight(
  id: 1,
  flightNumber: 'IB 6821',
  originIataCode: 'GRU',
  destinationIataCode: 'GIG',
  departureTime: DateTime(2026, 1, 13, 10, 30),
  arrivalTime: DateTime(2026, 1, 13, 12),
  seatClass: SeatClass.economy,
  price: 450,
  availableCapacity: 12,
);

Widget _wrap(Widget child, {required FlightRepository repository}) {
  return ProviderScope(
    overrides: [flightRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(theme: DbookTheme.light, home: child),
  );
}

void main() {
  testWidgets(
    'given matching flights when the page settles then lists every flight',
    (tester) async {
      final flight = _flight();

      await tester.pumpWidget(
        _wrap(
          FlightResultsPage(query: _query, onSelectFlight: (_) {}),
          repository: _FakeFlightRepository(flights: [flight]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DBook Airlines · IB 6821'), findsOneWidget);
      expect(find.text(r'$450.00'), findsOneWidget);
    },
  );

  testWidgets(
    'given no flights when the page settles then shows the empty state',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          FlightResultsPage(query: _query, onSelectFlight: (_) {}),
          repository: _FakeFlightRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nenhum voo encontrado'), findsOneWidget);
    },
  );

  testWidgets(
    'given the backend rejects the search when the page settles then shows '
    'the error state with a retry button',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          FlightResultsPage(query: _query, onSelectFlight: (_) {}),
          repository: _FakeFlightRepository(
            error: const DbookNotFoundException('No flights for that route'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No flights for that route'), findsOneWidget);
      expect(find.text('Tentar de novo'), findsOneWidget);
    },
  );

  testWidgets(
    'given a flight tile tapped when settled then reports the selected '
    'flight',
    (tester) async {
      Flight? selected;
      final flight = _flight();

      await tester.pumpWidget(
        _wrap(
          FlightResultsPage(
            query: _query,
            onSelectFlight: (flight) => selected = flight,
          ),
          repository: _FakeFlightRepository(flights: [flight]),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('DBook Airlines · IB 6821'));
      await tester.pumpAndSettle();

      expect(selected, flight);
    },
  );
}
