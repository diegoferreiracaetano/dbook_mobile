import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/mock_network_image.dart';

Widget _app(Widget home) {
  return ProviderScope(
    child: MaterialApp(theme: DbookTheme.light, home: home),
  );
}

void main() {
  // Os cards de "Destinos em destaque" carregam foto real via
  // NetworkImage — sem isso, o teste bateria numa requisição de rede de
  // verdade e falharia com NetworkImageLoadException.
  testWidgetsWithMockImages(
    'given default selections when Search Flights is tapped then reports '
    'the default origin/destination',
    (tester) async {
      FlightSearchQuery? reported;

      await tester.pumpWidget(
        _app(FlightSearchPage(onSearch: (query) => reported = query)),
      );

      expect(find.text(knownAirports[0].label), findsOneWidget);
      expect(find.text(knownAirports[1].label), findsOneWidget);

      await tester.tap(find.text('Search Flights'));
      await tester.pumpAndSettle();

      expect(reported?.origin, knownAirports[0]);
      expect(reported?.destination, knownAirports[1]);
    },
  );

  testWidgetsWithMockImages(
    'given the destination field tapped when an airport is picked then the '
    'field updates',
    (tester) async {
      await tester.pumpWidget(_app(FlightSearchPage(onSearch: (_) {})));

      await tester.tap(find.text('To'));
      await tester.pumpAndSettle();

      expect(find.text(knownAirports[2].label), findsOneWidget);
      await tester.tap(find.text(knownAirports[2].label));
      await tester.pumpAndSettle();

      expect(find.text(knownAirports[2].label), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a featured destination tapped when built then it fills the '
    'destination field',
    (tester) async {
      await tester.pumpWidget(_app(FlightSearchPage(onSearch: (_) {})));

      // A grade de "Destinos em destaque" tem 2 colunas — New York é o
      // 3º item (2ª linha), pode ficar fora da área visível do teste. Há
      // 2 `Scrollable`s na árvore (o `SingleChildScrollView` da página e
      // o `GridView` em si, mesmo com `NeverScrollableScrollPhysics`) —
      // o primeiro é o da página, o que precisa rolar aqui.
      await tester.scrollUntilVisible(
        find.text(knownAirports[2].city),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(knownAirports[2].city));
      await tester.pumpAndSettle();

      expect(find.text(knownAirports[2].label), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a drawer when built then it opens from the app bar',
    (tester) async {
      await tester.pumpWidget(
        _app(
          FlightSearchPage(
            onSearch: (_) {},
            drawer: const Drawer(child: Text('Menu')),
          ),
        ),
      );

      expect(find.text('Menu'), findsNothing);
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Menu'), findsOneWidget);
    },
  );
}
