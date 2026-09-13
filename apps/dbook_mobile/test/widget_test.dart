import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:dbook_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/mock_network_image.dart';

class _NoSessionTokenStorage implements TokenStorage {
  @override
  Future<void> saveTokens(AuthTokens tokens) async {}

  @override
  Future<AuthTokens?> readTokens() async => null;

  @override
  Future<void> clear() async {}
}

class _FakeFlightRepository implements FlightRepository {
  _FakeFlightRepository({this.flights = const []});

  final List<Flight> flights;

  @override
  Future<List<Flight>> search({
    required String originIataCode,
    required String destinationIataCode,
    required DateTime date,
  }) async => flights;

  @override
  Future<List<Seat>> getSeats(int bookableId) async => [];

}

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
  @override
  Future<List<Destination>> getFeaturedDestinations() async => _destinations;
}

/// Já nasce logado — pula o bootstrap real (que bateria na rede de
/// verdade) e trava o estado em `loggedIn`.
class _FakeLoggedInAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState.loggedIn(
    tokens: AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
    email: 'diego@dbook.com',
  );

  @override
  Future<void> bootstrap() async {}
}

class _FakeAuthRepository implements AuthRepository {
  var loginCallCount = 0;

  @override
  Future<User> register({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    loginCallCount++;
    return const AuthTokens(accessToken: 'access', refreshToken: 'refresh');
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) {
    throw UnimplementedError();
  }
}

Flight _sampleFlight() => Flight(
  id: 1,
  flightNumber: 'IB 6821',
  airlineIataCode: 'IB',
  airlineName: 'Iberia',
  originIataCode: 'GRU',
  destinationIataCode: 'MAD',
  departureTime: DateTime(2026, 1, 13, 10, 30),
  arrivalTime: DateTime(2026, 1, 14, 6, 45),
  seatClass: SeatClass.economy,
  price: 450,
  availableCapacity: 12,
);

Widget _app({
  bool loggedIn = false,
  List<Flight> flights = const [],
  AuthRepository? authRepository,
}) {
  return ProviderScope(
    overrides: [
      baseUrlProvider.overrideWithValue('http://localhost:8080'),
      tokenStorageProvider.overrideWithValue(_NoSessionTokenStorage()),
      flightRepositoryProvider.overrideWithValue(
        _FakeFlightRepository(flights: flights),
      ),
      destinationRepositoryProvider.overrideWithValue(
        _FakeDestinationRepository(),
      ),
      if (authRepository != null)
        authRepositoryProvider.overrideWithValue(authRepository),
      if (loggedIn)
        authNotifierProvider.overrideWith(_FakeLoggedInAuthNotifier.new),
    ],
    child: const DbookMobileApp(),
  );
}

/// Onboarding é "primeira vez só" (M9-9.1) — todo teste que não é
/// especificamente sobre onboarding já nasce com a flag marcada, senão
/// cairia no onboarding em vez da tela que o teste quer checar.
void _skipOnboarding() =>
    SharedPreferences.setMockInitialValues({'has_onboarded': true});

Future<void> _searchAndOpenFlightDetail(WidgetTester tester) async {
  await tester.tap(find.text('Search Flights'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Iberia · IB 6821'));
  await tester.pumpAndSettle();
}

Future<void> _goToTab(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(NavigationDestination, label));
  await tester.pumpAndSettle();
}

void main() {
  group('onboarding (primeiro acesso)', () {
    testWidgetsWithMockImages(
      'given a fresh install when the app builds then shows onboarding',
      (tester) async {
        SharedPreferences.setMockInitialValues({});

        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();

        expect(find.text('Discover New Horizons'), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);
      },
    );

    testWidgetsWithMockImages(
      'given onboarding finished when Get Started is tapped then Home '
      'shows directly, with no login prompt',
      (tester) async {
        SharedPreferences.setMockInitialValues({});

        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        expect(find.text('Search Flights'), findsOneWidget);
        expect(find.text('Welcome Back'), findsNothing);
      },
    );

    testWidgetsWithMockImages(
      'given a returning user when the app builds then skips onboarding '
      'and goes straight to Home',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();

        expect(find.text('Search Flights'), findsOneWidget);
        expect(find.text('Discover New Horizons'), findsNothing);
      },
    );
  });

  group('visitante navega sem login (M9-9.1)', () {
    testWidgetsWithMockImages(
      'given no session when Home builds then shows an Entrar action, not '
      'logout',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.login), findsOneWidget);
        expect(find.byIcon(Icons.logout), findsNothing);
      },
    );

    testWidgetsWithMockImages(
      'given a flight found when a guest searches then sees results and '
      'the flight detail with no login prompt anywhere',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app(flights: [_sampleFlight()]));
        await tester.pumpAndSettle();
        await _searchAndOpenFlightDetail(tester);

        expect(find.text('Book This Flight'), findsOneWidget);
        expect(find.text('Welcome Back'), findsNothing);
      },
    );

    testWidgetsWithMockImages(
      'given a guest when Ask DBook AI is tapped then the Auth Gate opens '
      'login instead of the AI screen',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.auto_awesome_outlined));
        await tester.pumpAndSettle();

        expect(find.text('Welcome Back'), findsOneWidget);
      },
    );

    testWidgetsWithMockImages(
      'given a guest when the Trips tab opens then shows a guest '
      'placeholder, and tapping Entrar opens the Auth Gate',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();
        await _goToTab(tester, 'Trips');

        final tripsGate = find.byKey(const Key('guest_gate_Trips'));
        expect(
          find.descendant(
            of: tripsGate,
            matching: find.text('Faça login para ver suas reservas.'),
          ),
          findsOneWidget,
        );

        await tester.tap(
          find.descendant(of: tripsGate, matching: find.text('Entrar')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Welcome Back'), findsOneWidget);
      },
    );

    testWidgetsWithMockImages(
      'given a guest when the Profile tab opens then shows a guest '
      'placeholder',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();
        await _goToTab(tester, 'Profile');

        expect(
          find.descendant(
            of: find.byKey(const Key('guest_gate_Profile')),
            matching: find.text('Faça login para ver seu perfil.'),
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('Auth Gate na compra (M9-9.1)', () {
    testWidgetsWithMockImages(
      'given a guest when Book This Flight is tapped then the Auth Gate '
      'opens login instead of seat selection',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app(flights: [_sampleFlight()]));
        await tester.pumpAndSettle();
        await _searchAndOpenFlightDetail(tester);
        await tester.tap(find.text('Book This Flight'));
        await tester.pumpAndSettle();

        expect(find.text('Welcome Back'), findsOneWidget);
        expect(find.text('Select a Seat'), findsNothing);
      },
    );

    testWidgetsWithMockImages('given a guest who logs in through the Auth Gate then lands '
        'directly on seat selection for the flight they picked — never '
        'back on Home', (tester) async {
      _skipOnboarding();
      final authRepository = _FakeAuthRepository();

      await tester.pumpWidget(
        _app(flights: [_sampleFlight()], authRepository: authRepository),
      );
      await tester.pumpAndSettle();
      await _searchAndOpenFlightDetail(tester);
      await tester.tap(find.text('Book This Flight'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'),
        'diego@dbook.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'hunter2',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(authRepository.loginCallCount, 1);
      expect(find.text('Select a Seat'), findsOneWidget);
      expect(find.text('Welcome Back'), findsNothing);

      // Voltar da tela de assento cai no detalhe do voo (a origem do
      // gate), nunca na Home nem no login — back-stack coerente.
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Book This Flight'), findsOneWidget);
    });

    testWidgetsWithMockImages(
      'given a logged in session when Book This Flight is tapped then '
      'goes straight to seat selection, no Auth Gate',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(
          _app(loggedIn: true, flights: [_sampleFlight()]),
        );
        await tester.pumpAndSettle();
        await _searchAndOpenFlightDetail(tester);
        await tester.tap(find.text('Book This Flight'));
        await tester.pumpAndSettle();

        expect(find.text('Select a Seat'), findsOneWidget);
      },
    );
  });

  group('sessão autenticada vê as 4 abas de verdade (M9-9.3)', () {
    testWidgetsWithMockImages(
      'given a logged in session when Home builds then shows a logout '
      'action, not Entrar',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app(loggedIn: true));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.logout), findsOneWidget);
        expect(find.byIcon(Icons.login), findsNothing);
      },
    );

    testWidgetsWithMockImages(
      'given a logged in session when the Trips tab opens then shows the '
      'bookings list, not the guest placeholder',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app(loggedIn: true));
        await tester.pumpAndSettle();
        await _goToTab(tester, 'Trips');

        expect(find.text('My Bookings'), findsOneWidget);
        expect(find.text('Entre para continuar'), findsNothing);
      },
    );

    testWidgetsWithMockImages(
      'given a logged in session when the Profile tab opens then shows the '
      'session e-mail',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app(loggedIn: true));
        await tester.pumpAndSettle();
        await _goToTab(tester, 'Profile');

        expect(find.text('diego@dbook.com'), findsOneWidget);
      },
    );

    testWidgetsWithMockImages(
      'given a destination tapped on the Explore tab then the Home tab '
      'shows it pre-filled as the destination',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();
        await _goToTab(tester, 'Explore');

        // `New York` é popular, então aparece 2x na página (em "Principais
        // destinos" e de novo em "Destinos por região") — `.first` porque
        // tocar qualquer uma das duas cópias visuais é equivalente, dispara
        // o mesmo callback com o mesmo destino.
        final destination = find
            .descendant(
              of: find.byType(ExplorePage),
              matching: find.text(_destinations[2].city),
            )
            .first;
        // ExplorePage envolve a grade num SingleChildScrollView — o
        // próprio GridView continua sendo um Scrollable por baixo (mesmo
        // com NeverScrollableScrollPhysics), então há 2 na árvore; o
        // primeiro é o da página, que precisa rolar aqui.
        final exploreScrollable = find
            .descendant(
              of: find.byType(ExplorePage),
              matching: find.byType(Scrollable),
            )
            .first;
        await tester.scrollUntilVisible(
          destination,
          200,
          scrollable: exploreScrollable,
        );
        await tester.ensureVisible(destination);
        await tester.pumpAndSettle();
        await tester.tap(destination);
        await tester.pumpAndSettle();

        expect(find.text(_destinations[2].label), findsOneWidget);
      },
    );

    testWidgetsWithMockImages(
      'given a region card tapped on the Home carousel then the Explore '
      'tab shows only that region, pre-selected',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();

        // Escopado à FlightSearchPage (Home) porque a Explore também tem
        // um card/chip "América do Norte" na própria árvore (montada por
        // baixo, via IndexedStack) — sem escopo, `.first` podia acabar
        // pegando o `Scrollable`/texto errado.
        final homeScrollable = find
            .descendant(
              of: find.byType(FlightSearchPage),
              matching: find.byType(Scrollable),
            )
            .first;
        final regionCard = find
            .descendant(
              of: find.byType(FlightSearchPage),
              matching: find.text('América do Norte'),
            )
            .first;
        await tester.scrollUntilVisible(
          regionCard,
          200,
          scrollable: homeScrollable,
        );
        await tester.tap(regionCard);
        await tester.pumpAndSettle();

        expect(
          tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
          1,
        );
        // O chip "América do Norte" já vem selecionado no filtro
        // "Destinos por região" — só o destino daquela região aparece
        // ali. Escopado a `DestinationsByRegion` (não a `ExplorePage`
        // inteira): "São Paulo" continua legitimamente visível em
        // "Principais destinos" (é popular, não passa pelo filtro de
        // região) — e a Home também continua montada por baixo
        // (IndexedStack) com o próprio "São Paulo" no grid de destaque.
        expect(
          find.descendant(
            of: find.byType(DestinationsByRegion),
            matching: find.text('New York'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(DestinationsByRegion),
            matching: find.text('São Paulo'),
          ),
          findsNothing,
        );
      },
    );
  });

  testWidgetsWithMockImages('given a flight when the detail page opens then shows the live '
      'availability indicator instead of the static count', (tester) async {
    _skipOnboarding();

    await tester.pumpWidget(_app(loggedIn: true, flights: [_sampleFlight()]));
    await tester.pumpAndSettle();
    await _searchAndOpenFlightDetail(tester);

    expect(find.text('Seats available'), findsOneWidget);
    expect(find.text('Conectando...'), findsOneWidget);
  });
}
