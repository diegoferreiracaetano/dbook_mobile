import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/mock_network_image.dart';

const _destinations = [
  Destination(
    iataCode: 'GRU',
    city: 'São Paulo',
    country: 'Brasil',
    photoUrl: 'https://example.com/gru.jpg',
    region: 'América do Sul',
    isPopular: true,
  ),
  Destination(
    iataCode: 'GIG',
    city: 'Rio de Janeiro',
    country: 'Brasil',
    photoUrl: 'https://example.com/gig.jpg',
    region: 'América do Sul',
    isPopular: true,
  ),
  Destination(
    iataCode: 'JFK',
    city: 'New York',
    country: 'Estados Unidos',
    photoUrl: 'https://example.com/jfk.jpg',
    region: 'América do Norte',
    isPopular: true,
  ),
];

class _FakeDestinationRepository implements DestinationRepository {
  var callCount = 0;

  @override
  Future<List<Destination>> getFeaturedDestinations() async {
    callCount++;
    return _destinations;
  }
}

class _FakeFlightRepository implements FlightRepository {
  @override
  Future<List<Flight>> search({
    required String originIataCode,
    required String destinationIataCode,
    required DateTime date,
  }) async => [];

  @override
  Future<List<Seat>> getSeats(int bookableId) async => [];
}

Widget _app(Widget home, {DestinationRepository? destinationRepository}) {
  return ProviderScope(
    overrides: [
      destinationRepositoryProvider.overrideWithValue(
        destinationRepository ?? _FakeDestinationRepository(),
      ),
      flightRepositoryProvider.overrideWithValue(_FakeFlightRepository()),
    ],
    child: MaterialApp(theme: DbookTheme.light, home: home),
  );
}

/// Os rádios de tipo de viagem estão desativados na UI (pedido do
/// usuário, `_TripTypeRow.enabled: false`) até o comportamento de
/// Multi-city ser revisado de novo — os testes abaixo continuam
/// exercitando a lógica (`_TripType`, `_extraLegs`), mas não dá pra
/// alcançá-la tocando o rádio (`IgnorePointer` bloqueia o toque), então
/// ficam pausados junto, não apagados.
const _tripTypeDisabled = true;

void main() {
  // Os cards de "Destinos em destaque" carregam foto real via
  // NetworkImage — sem isso, o teste bateria numa requisição de rede de
  // verdade e falharia com NetworkImageLoadException.
  testWidgetsWithMockImages(
    'given default selections when Search Flights is tapped then reports '
    'a single-item list with the default origin/destination',
    (tester) async {
      List<FlightSearchQuery>? reported;

      await tester.pumpWidget(
        _app(FlightSearchPage(onSearch: (queries) => reported = queries)),
      );
      await tester.pumpAndSettle();

      expect(find.text(_destinations[0].label), findsOneWidget);
      expect(find.text(_destinations[1].label), findsOneWidget);

      await tester.tap(find.text('Search Flights'));
      await tester.pumpAndSettle();

      expect(reported, hasLength(1));
      expect(reported?.first.origin, _destinations[0]);
      expect(reported?.first.destination, _destinations[1]);
    },
  );

  testWidgetsWithMockImages(
    'given Multi-city selected with no extra legs when Search Flights is '
    'tapped then reports just the main leg',
    (tester) async {
      // Google Flights (referência confirmada com o usuário) começa
      // Multi-city com só 1 trecho visível — nenhum é criado sozinho.
      List<FlightSearchQuery>? reported;

      await tester.pumpWidget(
        _app(FlightSearchPage(onSearch: (queries) => reported = queries)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Multi-city'));
      await tester.pumpAndSettle();

      expect(find.text('Flight 2'), findsNothing);
      await tester.tap(find.text('Search Flights'));
      await tester.pumpAndSettle();

      expect(reported, hasLength(1));
      expect(reported?.first.origin, _destinations[0]);
      expect(reported?.first.destination, _destinations[1]);
    },
    skip: _tripTypeDisabled,
  );

  testWidgetsWithMockImages(
    'given Multi-city when a leg is added then its origin defaults to the '
    'previous leg\'s destination',
    (tester) async {
      final scrollable = find.byType(Scrollable).first;
      Future<void> scrollTo(Finder finder) =>
          tester.scrollUntilVisible(finder, 200, scrollable: scrollable);

      await tester.pumpWidget(_app(FlightSearchPage(onSearch: (_) {})));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Multi-city'));
      await tester.pumpAndSettle();
      await scrollTo(find.text('Add another flight'));
      await tester.tap(find.text('Add another flight'));
      await tester.pumpAndSettle();

      // O destino do trecho principal é _destinations[1] por padrão —
      // encadeamento automático (mesmo comportamento do Google Flights):
      // quem viaja pra vários lugares geralmente segue voando de onde
      // chegou, então o próximo "From" já vem preenchido, só o "To"
      // fica em aberto.
      final leg2 = find.byKey(const Key('extra_leg_0'));
      expect(
        find.descendant(
          of: leg2,
          matching: find.text(_destinations[1].label),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: leg2, matching: find.text('To')),
        findsOneWidget,
      );
    },
    skip: _tripTypeDisabled,
  );

  testWidgetsWithMockImages(
    'given Multi-city with a leg added when its destination is filled and '
    'search is tapped then reports both legs in order',
    (tester) async {
      List<FlightSearchQuery>? reported;
      final scrollable = find.byType(Scrollable).first;

      Future<void> scrollTo(Finder finder) =>
          tester.scrollUntilVisible(finder, 200, scrollable: scrollable);

      await tester.pumpWidget(
        _app(FlightSearchPage(onSearch: (queries) => reported = queries)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Multi-city'));
      await tester.pumpAndSettle();
      await scrollTo(find.text('Add another flight'));
      await tester.tap(find.text('Add another flight'));
      await tester.pumpAndSettle();

      // A origem já veio preenchida (encadeada do trecho principal) —
      // só falta o destino. Escopado ao card do trecho extra ("Flight
      // 2") e ao `BottomSheet` de seleção pra não colidir com o "To" do
      // card principal nem com o valor já visível atrás dele.
      final leg2 = find.byKey(const Key('extra_leg_0'));
      await scrollTo(find.text('Flight 2'));
      await tester.tap(
        find.descendant(of: leg2, matching: find.text('To')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text(_destinations[2].label),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(find.text('Search Flights'));
      await tester.tap(find.text('Search Flights'));
      await tester.pumpAndSettle();

      expect(reported, hasLength(2));
      expect(reported?[1].origin, _destinations[1]);
      expect(reported?[1].destination, _destinations[2]);
    },
    skip: _tripTypeDisabled,
  );

  testWidgetsWithMockImages(
    'given Multi-city with 2 extra legs when the 1st is removed then only '
    'the 2nd remains',
    (tester) async {
      final scrollable = find.byType(Scrollable).first;
      Future<void> scrollTo(Finder finder) =>
          tester.scrollUntilVisible(finder, 200, scrollable: scrollable);

      await tester.pumpWidget(_app(FlightSearchPage(onSearch: (_) {})));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Multi-city'));
      await tester.pumpAndSettle();
      await scrollTo(find.text('Add another flight'));
      await tester.tap(find.text('Add another flight'));
      await tester.pumpAndSettle();
      await scrollTo(find.text('Add another flight'));
      await tester.tap(find.text('Add another flight'));
      await tester.pumpAndSettle();

      expect(find.text('Flight 2'), findsOneWidget);
      expect(find.text('Flight 3'), findsOneWidget);

      // Rola de novo: adicionar o trecho pode ter deixado a posição de
      // rolagem num ponto onde "Flight 2" (mais acima na lista) já não
      // está mais visível.
      await scrollTo(find.text('Flight 2'));
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('extra_leg_0')),
          matching: find.byIcon(Icons.close),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flight 2'), findsOneWidget);
      expect(find.text('Flight 3'), findsNothing);
    },
    skip: _tripTypeDisabled,
  );

  testWidgetsWithMockImages(
    'given the destination field tapped when an airport is picked then the '
    'field updates',
    (tester) async {
      await tester.pumpWidget(_app(FlightSearchPage(onSearch: (_) {})));
      await tester.pumpAndSettle();

      await tester.tap(find.text('To'));
      await tester.pumpAndSettle();

      expect(find.text(_destinations[2].label), findsOneWidget);
      await tester.tap(find.text(_destinations[2].label));
      await tester.pumpAndSettle();

      expect(find.text(_destinations[2].label), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a featured destination tapped when built then it fills the '
    'destination field',
    (tester) async {
      await tester.pumpWidget(_app(FlightSearchPage(onSearch: (_) {})));
      await tester.pumpAndSettle();

      // A grade de "Destinos em destaque" tem 2 colunas — New York é o
      // 3º item (2ª linha), pode ficar fora da área visível do teste. Há
      // 2 `Scrollable`s na árvore (o `SingleChildScrollView` da página e
      // o `GridView` em si, mesmo com `NeverScrollableScrollPhysics`) —
      // o primeiro é o da página, o que precisa rolar aqui. "New York"
      // também aparece na seção "Mais destinos" (outro estilo de card),
      // então o toque tem que ficar restrito ao `DestinationCard`.
      final destination = find.descendant(
        of: find.byType(DestinationCard),
        matching: find.text(_destinations[2].city),
      );
      await tester.scrollUntilVisible(
        destination,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(destination);
      await tester.pumpAndSettle();

      expect(find.text(_destinations[2].label), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given actions when built then they render in the app bar',
    (tester) async {
      await tester.pumpWidget(
        _app(
          FlightSearchPage(
            onSearch: (_) {},
            actions: const [Icon(Icons.logout)],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a pull-to-refresh gesture when triggered then it re-fetches the '
    'destinations list',
    (tester) async {
      final repository = _FakeDestinationRepository();

      await tester.pumpWidget(
        _app(
          FlightSearchPage(onSearch: (_) {}),
          destinationRepository: repository,
        ),
      );
      await tester.pumpAndSettle();

      final callsAfterInitialLoad = repository.callCount;
      expect(callsAfterInitialLoad, 1);

      await tester.fling(
        find.byType(Scrollable).first,
        const Offset(0, 300),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(repository.callCount, callsAfterInitialLoad + 1);
    },
  );
}
