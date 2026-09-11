import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:dbook_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoSessionTokenStorage implements TokenStorage {
  @override
  Future<void> saveTokens(AuthTokens tokens) async {}

  @override
  Future<AuthTokens?> readTokens() async => null;

  @override
  Future<void> clear() async {}
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

/// Já nasce logado — pula o bootstrap real (que bateria na rede de
/// verdade) e trava o estado em `loggedIn`.
class _FakeLoggedInAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState.loggedIn(
    tokens: AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
  );

  @override
  Future<void> bootstrap() async {}
}

Widget _app({bool loggedIn = false}) {
  return ProviderScope(
    overrides: [
      baseUrlProvider.overrideWithValue('http://localhost:8080'),
      tokenStorageProvider.overrideWithValue(_NoSessionTokenStorage()),
      if (loggedIn) ...[
        authNotifierProvider.overrideWith(_FakeLoggedInAuthNotifier.new),
        flightRepositoryProvider.overrideWithValue(_FakeFlightRepository()),
      ],
    ],
    child: const DbookMobileApp(),
  );
}

void main() {
  testWidgets(
    'given no saved session when the app builds then the first onboarding '
    'slide renders',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('Discover New Horizons'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    },
  );

  testWidgets(
    'given Next tapped three times when settled then Get Started shows',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Travel Your Way'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
    },
  );

  testWidgets(
    'given onboarding finished when Get Started is tapped then the login '
    'screen shows',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    },
  );

  testWidgets(
    'given a logged in session when the app builds then the flight search '
    'screen shows with a logout action',
    (tester) async {
      await tester.pumpWidget(_app(loggedIn: true));
      await tester.pumpAndSettle();

      expect(find.text('Search Flights'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    },
  );
}
