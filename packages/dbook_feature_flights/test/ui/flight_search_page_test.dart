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
const _tripTypeDisabled = false;

/// Escolhe o tipo de viagem sem tocar no rádio (a UI o mantém desativado):
/// chama o `onChanged` do grupo com o valor do rádio na posição dada
/// (0 Round Trip, 1 One Way, 2 Multi-city). Assim a lógica pausada continua
/// coberta e o dia em que os rádios voltarem é só trocar por `tap`.
Future<void> _chooseTripType(WidgetTester tester, int index) async {
  final radios = tester.widgetList(find.byWidgetPredicate((w) => w is Radio));
  final value = (radios.elementAt(index) as dynamic).value;
  final group = tester.widget(find.byWidgetPredicate((w) => w is RadioGroup));
  (group as dynamic).onChanged(value);
  await tester.pumpAndSettle();
}

/// A Home nasce sem origem nem destino (nada é escolhido pelo usuário):
/// escolhe os dois primeiros pelo seletor, como o usuário faria.
Future<void> _pickRoute(WidgetTester tester) async {
  await tester.tap(find.text('Selecionar').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(_destinations[0].label).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Selecionar').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(_destinations[1].label).last);
  await tester.pumpAndSettle();
}

void main() {
  // Os cards de "Destinos em destaque" carregam foto real via
  // NetworkImage — sem isso, o teste bateria numa requisição de rede de
  // verdade e falharia com NetworkImageLoadException.
  testWidgetsWithMockImages(
    'given a picked route (Round Trip) when Search Flights is tapped '
    'then reports the outbound leg and a real return leg, swapped',
    (tester) async {
      List<FlightSearchQuery>? reported;

      await tester.pumpWidget(
        _app(FlightSearchPage(onSearch: (queries) => reported = queries)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Selecionar'), findsNWidgets(2));
      await _pickRoute(tester);

      expect(find.text(_destinations[0].label), findsOneWidget);
      expect(find.text(_destinations[1].label), findsOneWidget);

      await tester.tap(find.text('Buscar voos'));
      await tester.pumpAndSettle();

      expect(reported, hasLength(2));
      expect(reported?[0].origin, _destinations[0]);
      expect(reported?[0].destination, _destinations[1]);
      // Volta: origem/destino invertidos, data diferente da ida.
      expect(reported?[1].origin, _destinations[1]);
      expect(reported?[1].destination, _destinations[0]);
      expect(reported?[1].date, isNot(reported?[0].date));
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
      await _pickRoute(tester);

      await _chooseTripType(tester, 2);

      expect(find.text('Voo 2'), findsNothing);
      await tester.tap(find.text('Buscar voos'));
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
      await _pickRoute(tester);

      await _chooseTripType(tester, 2);
      await scrollTo(find.text('Adicionar outro voo'));
      await tester.tap(find.text('Adicionar outro voo'));
      await tester.pumpAndSettle();

      // O destino do trecho principal é _destinations[1] por padrão —
      // encadeamento automático (mesmo comportamento do Google Flights):
      // quem viaja pra vários lugares geralmente segue voando de onde
      // chegou, então o próximo "From" já vem preenchido, só o "To"
      // fica em aberto.
      final leg2 = find.byKey(const Key('extra_leg_0'));
      expect(
        find.descendant(of: leg2, matching: find.text(_destinations[1].label)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: leg2, matching: find.text('Destino')),
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
      await _pickRoute(tester);

      await _chooseTripType(tester, 2);
      await scrollTo(find.text('Adicionar outro voo'));
      await tester.tap(find.text('Adicionar outro voo'));
      await tester.pumpAndSettle();

      // A origem já veio preenchida (encadeada do trecho principal) —
      // só falta o destino. Escopado ao card do trecho extra ("Flight
      // 2") e ao `BottomSheet` de seleção pra não colidir com o "To" do
      // card principal nem com o valor já visível atrás dele.
      final leg2 = find.byKey(const Key('extra_leg_0'));
      await scrollTo(find.text('Voo 2'));
      await tester.tap(
        find.descendant(of: leg2, matching: find.text('Destino')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text(_destinations[2].label),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(find.text('Buscar voos'));
      await tester.tap(find.text('Buscar voos'));
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

      await _chooseTripType(tester, 2);
      await scrollTo(find.text('Adicionar outro voo'));
      await tester.tap(find.text('Adicionar outro voo'));
      await tester.pumpAndSettle();
      await scrollTo(find.text('Adicionar outro voo'));
      await tester.tap(find.text('Adicionar outro voo'));
      await tester.pumpAndSettle();

      expect(find.text('Voo 2'), findsOneWidget);
      expect(find.text('Voo 3'), findsOneWidget);

      // Rola de novo: adicionar o trecho pode ter deixado a posição de
      // rolagem num ponto onde "Flight 2" (mais acima na lista) já não
      // está mais visível.
      await scrollTo(find.text('Voo 2'));
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('extra_leg_0')),
          matching: find.byIcon(Icons.close),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Voo 2'), findsOneWidget);
      expect(find.text('Voo 3'), findsNothing);
    },
    skip: _tripTypeDisabled,
  );

  testWidgetsWithMockImages(
    'given the destination field tapped when an airport is picked then the '
    'field updates',
    (tester) async {
      await tester.pumpWidget(_app(FlightSearchPage(onSearch: (_) {})));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Destino'));
      await tester.pumpAndSettle();

      expect(find.text(_destinations[2].label), findsOneWidget);
      await tester.tap(find.text(_destinations[2].label));
      await tester.pumpAndSettle();

      expect(find.text(_destinations[2].label), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a featured destination tapped when built then it fills the '
    'destination field AND already searches — no manual "Search Flights" '
    'step needed',
    (tester) async {
      List<FlightSearchQuery>? reported;

      await tester.pumpWidget(
        _app(FlightSearchPage(onSearch: (queries) => reported = queries)),
      );
      await tester.pumpAndSettle();
      await _pickRoute(tester);

      // Há 2 `Scrollable`s na árvore (o `SingleChildScrollView` da página
      // e o `GridView` em si, mesmo com `NeverScrollableScrollPhysics`) —
      // o primeiro é o da página, o que precisa rolar aqui.
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
      // Round Trip (padrão) — respeita a mesma lógica de "Search Flights",
      // ida (origem atual → destino tocado) + volta invertida.
      expect(reported, hasLength(2));
      expect(reported?[0].origin, _destinations[0]);
      expect(reported?[0].destination, _destinations[2]);
      expect(reported?[1].origin, _destinations[2]);
      expect(reported?[1].destination, _destinations[0]);
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

  testWidgetsWithMockImages(
    'given the departure date tapped when another day is picked then the '
    'search reports that day',
    (tester) async {
      List<FlightSearchQuery>? reported;
      await tester.pumpWidget(
        _app(FlightSearchPage(onSearch: (queries) => reported = queries)),
      );
      await tester.pumpAndSettle();
      await _pickRoute(tester);

      await tester.tap(find.text('Partida'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('27').first);
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buscar voos'));
      await tester.pumpAndSettle();

      expect(reported?.first.date.day, 27);
    },
  );

  testWidgetsWithMockImages(
    'given the swap button when tapped then origin and destination trade '
    'places',
    (tester) async {
      List<FlightSearchQuery>? reported;
      await tester.pumpWidget(
        _app(FlightSearchPage(onSearch: (queries) => reported = queries)),
      );
      await tester.pumpAndSettle();
      await _pickRoute(tester);

      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buscar voos'));
      await tester.pumpAndSettle();

      expect(reported?.first.origin, _destinations[1]);
      expect(reported?.first.destination, _destinations[0]);
    },
  );

  testWidgetsWithMockImages(
    'given a hotel panel when choosing Hotéis then swaps the flight card for '
    'the panel and back',
    (tester) async {
      await tester.pumpWidget(
        _app(
          FlightSearchPage(
            onSearch: (_) {},
            hotelPanelBuilder: (context, destinations) =>
                Text('painel com ${destinations.length} destinos'),
            extrasBuilder: (context, destinations) => const Text('vitrine'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Buscar voos'), findsOneWidget);
      expect(find.text('vitrine'), findsNothing);

      await tester.tap(find.text('Hotéis'));
      await tester.pumpAndSettle();

      expect(find.text('painel com 3 destinos'), findsOneWidget);
      expect(find.text('Buscar voos'), findsNothing);
      expect(find.text('vitrine'), findsOneWidget);

      await tester.tap(find.text('Voos'));
      await tester.pumpAndSettle();

      expect(find.text('Buscar voos'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given no hotel panel when the Home builds then has no mode toggle',
    (tester) async {
      await tester.pumpWidget(_app(FlightSearchPage(onSearch: (_) {})));
      await tester.pumpAndSettle();

      expect(find.text('Hotéis'), findsNothing);
    },
  );

  testWidgetsWithMockImages(
    'given the Home already built when the parent passes new actions (the user '
    'logged in) then the header shows them, not the ones it was born with',
    (tester) async {
      Widget host(List<Widget> actions) => ProviderScope(
        overrides: [
          destinationRepositoryProvider.overrideWithValue(
            _FakeDestinationRepository(),
          ),
          flightRepositoryProvider.overrideWithValue(_FakeFlightRepository()),
        ],
        child: MaterialApp(
          theme: DbookTheme.light,
          home: FlightsHomePage(actions: actions),
        ),
      );

      await tester.pumpWidget(host(const [Icon(Icons.login)]));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.login), findsOneWidget);

      await tester.pumpWidget(host(const [Icon(Icons.logout)]));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.byIcon(Icons.login), findsNothing);
    },
  );
}
