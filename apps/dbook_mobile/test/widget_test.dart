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
  await tester.tap(find.text('DBook Airlines · IB 6821'));
  await tester.pumpAndSettle();
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
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
      'given no session when the drawer opens then shows an Entrar action, '
      'not Sair',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();
        await _openDrawer(tester);

        final drawer = find.byType(Drawer);
        expect(
          find.descendant(of: drawer, matching: find.text('Entrar')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: drawer, matching: find.text('Sair')),
          findsNothing,
        );
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
      'given a guest when Ask DBook AI is tapped in the drawer then the '
      'Auth Gate opens login instead of the AI screen',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();
        await _openDrawer(tester);
        await tester.tap(find.text('Ask DBook AI'));
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
      'given a logged in session when the drawer opens then shows Sair, '
      'not Entrar',
      (tester) async {
        _skipOnboarding();

        await tester.pumpWidget(_app(loggedIn: true));
        await tester.pumpAndSettle();
        await _openDrawer(tester);

        final drawer = find.byType(Drawer);
        expect(
          find.descendant(of: drawer, matching: find.text('Sair')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: drawer, matching: find.text('Entrar')),
          findsNothing,
        );
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

        final destination = find.descendant(
          of: find.byType(ExplorePage),
          matching: find.text(knownAirports[2].city),
        );
        final exploreScrollable = find.descendant(
          of: find.byType(ExplorePage),
          matching: find.byType(Scrollable),
        );
        await tester.scrollUntilVisible(
          destination,
          200,
          scrollable: exploreScrollable,
        );
        await tester.ensureVisible(destination);
        await tester.pumpAndSettle();
        await tester.tap(destination);
        await tester.pumpAndSettle();

        expect(find.text(knownAirports[2].label), findsOneWidget);
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
