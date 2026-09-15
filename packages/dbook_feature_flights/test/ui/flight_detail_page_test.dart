import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/mock_network_image.dart';

const _madrid = Destination(
  iataCode: 'MAD',
  city: 'Madrid',
  country: 'Spain',
  photoUrl: 'https://example.com/mad.jpg',
  region: 'Europa',
  isPopular: false,
);

class _FakeDestinationRepository implements DestinationRepository {
  _FakeDestinationRepository([this.destinations = const []]);

  final List<Destination> destinations;

  @override
  Future<List<Destination>> getFeaturedDestinations() async => destinations;
}

Widget _app(Widget home, {List<Destination> destinations = const []}) {
  return ProviderScope(
    overrides: [
      destinationRepositoryProvider.overrideWithValue(
        _FakeDestinationRepository(destinations),
      ),
    ],
    child: MaterialApp(theme: DbookTheme.light, home: home),
  );
}

Flight _flight() => Flight(
  id: 1,
  flightNumber: 'IB 6821',
  airlineIataCode: 'IB',
  airlineName: 'Iberia',
  originIataCode: 'GRU',
  destinationIataCode: 'MAD',
  departureTime: DateTime(2026, 1, 13, 10, 30),
  arrivalTime: DateTime(2026, 1, 14, 6, 45),
  seatClass: SeatClass.business,
  price: 1250,
  availableCapacity: 4,
  aircraftType: 'Airbus A320',
  seatLayout: const [3, 3],
);

void main() {
  testWidgetsWithMockImages(
    'given a flight when built then shows every field',
    (tester) async {
      await tester.pumpWidget(
        _app(
          FlightDetailPage(flight: _flight()),
          destinations: const [_madrid],
        ),
      );
      await tester.pump();

      expect(find.text('GRU'), findsOneWidget);
      expect(find.text('MAD'), findsOneWidget);
      expect(find.text('10:30'), findsOneWidget);
      expect(find.text('06:45'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);
      expect(find.text('Iberia'), findsOneWidget);
      expect(find.text('IB 6821'), findsOneWidget);
      expect(find.text('Airbus A320'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text(r'$1,250.00'), findsOneWidget);
      expect(find.text('Book This Flight'), findsNothing);
    },
  );

  testWidgetsWithMockImages(
    'given a destination with a real photo when built then shows city, '
    'country and the photo instead of the airline-color fallback',
    (tester) async {
      await tester.pumpWidget(
        _app(
          FlightDetailPage(flight: _flight()),
          destinations: const [_madrid],
        ),
      );
      await tester.pump();

      expect(find.text('Madrid, Spain'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    },
  );

  testWidgets('given no matching destination when built then falls back to the '
      'IATA code without a photo', (tester) async {
    await tester.pumpWidget(_app(FlightDetailPage(flight: _flight())));
    await tester.pump();

    expect(find.byType(Image), findsNothing);
  });

  testWidgets(
    'given onBook when Book This Flight is tapped then reports the flight',
    (tester) async {
      Flight? booked;
      final flight = _flight();

      await tester.pumpWidget(
        _app(
          FlightDetailPage(flight: flight, onBook: (value) => booked = value),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Book This Flight'));

      expect(booked, flight);
    },
  );

  testWidgets(
    'given liveAvailability when built then shows it instead of the static '
    'capacity',
    (tester) async {
      await tester.pumpWidget(
        _app(
          FlightDetailPage(
            flight: _flight(),
            liveAvailability: const Text('live-availability-widget'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Seats available'), findsOneWidget);
      expect(find.text('live-availability-widget'), findsOneWidget);
      expect(find.text('4'), findsNothing);
    },
  );
}
