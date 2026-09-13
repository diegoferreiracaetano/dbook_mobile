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

/// Returns different flights per day of month — used to exercise the date
/// strip's per-date prices and re-searching when a date chip is tapped.
class _DateAwareFlightRepository implements FlightRepository {
  _DateAwareFlightRepository(this.flightsByDay);

  final Map<int, List<Flight>> flightsByDay;

  @override
  Future<List<Flight>> search({
    required String originIataCode,
    required String destinationIataCode,
    required DateTime date,
  }) async => flightsByDay[date.day] ?? [];

  @override
  Future<List<Seat>> getSeats(int bookableId) async => [];

}

Flight _flightOnDay(
  int day,
  double price, {
  SeatClass seatClass = SeatClass.economy,
  String? label,
}) => Flight(
  id: label?.hashCode ?? day,
  flightNumber: 'DB${label ?? day}',
  airlineIataCode: 'IB',
  airlineName: 'Iberia',
  originIataCode: 'GRU',
  destinationIataCode: 'GIG',
  departureTime: DateTime(2026, 1, day, 10, 30),
  arrivalTime: DateTime(2026, 1, day, 12),
  seatClass: seatClass,
  price: price,
  availableCapacity: 12,
);

const _origin = Destination(
  iataCode: 'GRU',
  city: 'São Paulo',
  country: 'Brasil',
  photoUrl: 'https://example.com/gru.jpg',
);
const _destination = Destination(
  iataCode: 'GIG',
  city: 'Rio de Janeiro',
  country: 'Brasil',
  photoUrl: 'https://example.com/gig.jpg',
);

final _query = FlightSearchQuery(
  origin: _origin,
  destination: _destination,
  date: DateTime(2026, 1, 13),
);

Flight _flight() => Flight(
  id: 1,
  flightNumber: 'IB 6821',
  airlineIataCode: 'IB',
  airlineName: 'Iberia',
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

      expect(find.text('Iberia · IB 6821'), findsOneWidget);
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

      await tester.tap(find.text('Iberia · IB 6821'));
      await tester.pumpAndSettle();

      expect(selected, flight);
    },
  );

  testWidgets(
    "given different prices per day when settled then the date strip shows "
    "each day's lowest price, highlighting the cheapest",
    (tester) async {
      final repository = _DateAwareFlightRepository({
        11: [_flightOnDay(11, 529)],
        12: [_flightOnDay(12, 499)],
        13: [_flightOnDay(13, 450)],
        14: [_flightOnDay(14, 520)],
        15: [_flightOnDay(15, 510)],
      });

      await tester.pumpWidget(
        _wrap(
          FlightResultsPage(query: _query, onSelectFlight: (_) {}),
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(r'$529'), findsOneWidget);
      expect(find.text(r'$499'), findsOneWidget);
      expect(find.text(r'$450'), findsOneWidget);
      expect(find.text(r'$520'), findsOneWidget);
      expect(find.text(r'$510'), findsOneWidget);
      // Jan 13, 2026 (the query date) is the cheapest of the 5 — badge shows.
      expect(find.text('Best prices today'), findsOneWidget);
    },
  );

  testWidgets(
    'given a different date chip tapped when settled then the results '
    'reflect that day instead',
    (tester) async {
      final repository = _DateAwareFlightRepository({
        13: [_flightOnDay(13, 450)],
        12: [_flightOnDay(12, 499)],
      });

      await tester.pumpWidget(
        _wrap(
          FlightResultsPage(query: _query, onSelectFlight: (_) {}),
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Iberia · DB13'), findsOneWidget);

      await tester.tap(find.text('Mon 12'));
      await tester.pumpAndSettle();

      expect(find.text('Iberia · DB12'), findsOneWidget);
      expect(find.text('Iberia · DB13'), findsNothing);
    },
  );

  testWidgets(
    'given flights of different cabin classes when Business is chosen in '
    'the filter then only business flights show',
    (tester) async {
      final economyFlight = _flightOnDay(13, 450, label: 'E13');
      final businessFlight = _flightOnDay(
        13,
        900,
        seatClass: SeatClass.business,
        label: 'B13',
      );
      final repository = _DateAwareFlightRepository({
        13: [economyFlight, businessFlight],
      });

      await tester.pumpWidget(
        _wrap(
          FlightResultsPage(query: _query, onSelectFlight: (_) {}),
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 flights found'), findsOneWidget);

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Business'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Apply'),
        200,
        scrollable: find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(find.text('1 flight found'), findsOneWidget);
      expect(find.text('Iberia · DB13'), findsNothing);
      expect(find.text('Iberia · DBB13'), findsOneWidget);
      expect(find.text(r'$900.00'), findsOneWidget);
    },
  );
}
