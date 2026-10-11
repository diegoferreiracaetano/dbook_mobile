import 'dart:convert';
import 'dart:io';

import 'package:dbook_admin/src/app.dart';
import 'package:dbook_admin/src/app_config.dart';
import 'package:dbook_admin/src/connectivity.dart';
import 'package:dbook_admin/src/router.dart';
import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart' show Permission, Role;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// O portal inteiro (roteador, casca, menu por permissão, guarda) com a
/// sessão e a rede trocadas: o que está sob teste é a composição do app.
class _SignedIn extends AdminSessionNotifier {
  _SignedIn(this.permissions);

  final Set<Permission> permissions;

  @override
  AdminSessionState build() => SessionSignedIn(
    StaffProfile(
      id: 1,
      name: 'Ana Souza',
      email: 'ana@dbook.test',
      role: Role.support,
      permissions: permissions,
    ),
  );
}

Dio _emptyApi() {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(
        Response<Object>(
          requestOptions: options,
          statusCode: 200,
          data: options.path.contains('export')
              ? <int>[]
              : <String, dynamic>{'items': <Object>[]},
        ),
      ),
    ),
  );
  return dio;
}

/// A API do backend (respostas reais capturadas) servida por caminho.
Dio _realisticApi() {
  const routes = <String, String>{
    '/admin/customers': 'customers',
    '/admin/customers/2': 'customer_detail',
    '/admin/customers/2/bookings': 'customer_bookings',
    '/admin/customers/2/payments': 'customer_payments',
    '/admin/customers/2/reviews': 'customer_reviews',
    '/admin/customers/2/notes': 'customer_notes',
    '/admin/bookings': 'bookings',
    '/admin/bookings/2': 'booking_detail',
    '/admin/flights': 'flights',
    '/admin/flights/1': 'flight_detail',
    '/admin/airlines': 'airlines',
    '/admin/airports': 'airports',
    '/admin/aircraft-models': 'aircraft_models',
    '/admin/promo-codes': 'promos',
    '/admin/reviews': 'reviews',
    '/admin/audit': 'audit',
    '/admin/refunds': 'refunds',
    '/admin/dashboard/summary': 'summary',
    '/admin/dashboard/timeseries': 'timeseries',
    '/admin/dashboard/top-routes': 'top_routes',
  };
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final name = routes[options.path];
        handler.resolve(
          Response<Object>(
            requestOptions: options,
            statusCode: 200,
            data: name == null
                ? <String, dynamic>{'items': <Object>[]}
                : jsonDecode(
                    File('test/fixtures/$name.json').readAsStringSync(),
                  ),
          ),
        );
      },
    ),
  );
  return dio;
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  Set<Permission> permissions, {
  Dio? api,
  bool reachable = true,
  String environment = 'local',
  Size size = const Size(1400, 900),
}) async {
  await PortalFormats.init();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig(
            apiBaseUrl: 'http://api.test/v1',
            environment: environment,
            version: '1.0.0+1',
          ),
        ),
        adminBaseUrlProvider.overrideWithValue('http://api.test/v1'),
        apiReachableProvider.overrideWith((ref) => Stream.value(reachable)),
        adminDioProvider.overrideWithValue(api ?? _emptyApi()),
        adminSessionProvider.overrideWith(() => _SignedIn(permissions)),
      ],
      child: const DbookAdminApp(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(DbookAdminApp)));
}

void main() {
  testWidgets('given a signed in user when the app opens then shows the home '
      'with the menu built from the permissions', (tester) async {
    await _pump(tester, {
      Permission.adminPortalAccess,
      Permission.customerRead,
      Permission.bookingReadAny,
    });

    expect(find.textContaining('Ana'), findsWidgets);
    expect(find.text('Clientes'), findsWidgets);
    expect(find.text('Reservas'), findsWidgets);
    expect(find.text('Equipe'), findsNothing);
  });

  testWidgets('given a user without the permission when opening an area by '
      'URL then goes to the forbidden page', (tester) async {
    final container = await _pump(tester, {Permission.adminPortalAccess});

    container.read(routerProvider).go('/team');
    await tester.pumpAndSettle();

    expect(container.read(routerProvider).state.uri.path, '/forbidden');
  });

  testWidgets('given a user with the permission when navigating then the '
      'area opens on its URL', (tester) async {
    final container = await _pump(tester, {
      Permission.adminPortalAccess,
      Permission.customerRead,
    });

    container.read(routerProvider).go('/customers');
    await tester.pumpAndSettle();

    expect(container.read(routerProvider).state.uri.path, '/customers');
    expect(tester.takeException(), isNull);
  });

  testWidgets('given a signed in user when opening the login URL then is '
      'sent home', (tester) async {
    final container = await _pump(tester, {Permission.adminPortalAccess});

    container.read(routerProvider).go('/login');
    await tester.pumpAndSettle();

    expect(container.read(routerProvider).state.uri.path, '/');
  });

  testWidgets('given a super admin when visiting every area by URL then each '
      'one opens without errors', (tester) async {
    final container = await _pump(tester, Permission.values.toSet());
    final router = container.read(routerProvider);

    const paths = [
      '/dashboard',
      '/customers',
      '/customers/2',
      '/bookings',
      '/bookings/2',
      '/refunds',
      '/flights',
      '/flights/new',
      '/flights/import',
      '/airlines',
      '/airports',
      '/reviews',
      '/promos',
      '/audit',
      '/team',
      '/account',
      '/account/password',
      '/forbidden',
      '/nao-existe',
    ];
    for (final path in paths) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: path);
    }
  });

  testWidgets('given a narrow window when the app opens then the menu moves '
      'to a drawer', (tester) async {
    await PortalFormats.init();
    tester.view.physicalSize = const Size(480, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(
              apiBaseUrl: 'http://api.test/v1',
              environment: 'production',
              version: '1.0.0+1',
            ),
          ),
          adminBaseUrlProvider.overrideWithValue('http://api.test/v1'),
          apiReachableProvider.overrideWith((ref) => Stream.value(true)),
          adminDioProvider.overrideWithValue(_emptyApi()),
          adminSessionProvider.overrideWith(
            () => _SignedIn({
              Permission.adminPortalAccess,
              Permission.customerRead,
            }),
          ),
        ],
        child: const DbookAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsNothing);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Clientes'), findsWidgets);
  });

  group('navigation with real data', () {
    testWidgets('given the customers when filtering and opening one then '
        'the URL follows', (tester) async {
      final container = await _pump(
        tester,
        Permission.values.toSet(),
        api: _realisticApi(),
      );
      final router = container.read(routerProvider);

      router.go('/customers');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bloqueados'));
      await tester.pumpAndSettle();
      expect(router.state.uri.queryParameters['status'], 'blocked');

      router.go('/customers');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marina Alves'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/customers/2');
    });

    testWidgets('given the bookings when filtering and opening one then the '
        'URL follows and the customer link works', (tester) async {
      final container = await _pump(
        tester,
        Permission.values.toSet(),
        api: _realisticApi(),
      );
      final router = container.read(routerProvider);

      router.go('/bookings');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pagas'));
      await tester.pumpAndSettle();
      expect(router.state.uri.queryParameters['paid'], 'yes');

      router.go('/bookings');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hotel Copacabana').first);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/bookings/2');

      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/customers/2');
    });

    testWidgets('given the flights when opening, creating and importing '
        'then each goes to its URL', (tester) async {
      final container = await _pump(
        tester,
        Permission.values.toSet(),
        api: _realisticApi(),
      );
      final router = container.read(routerProvider);

      router.go('/flights');
      await tester.pumpAndSettle();
      await tester.tap(find.text('DB1001'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/flights/1');

      router.go('/flights');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Novo voo').first);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/flights/new');

      router.go('/flights');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Importar CSV').first);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/flights/import');
    });

    testWidgets('given the other areas when opened with real data then '
        'render without errors', (tester) async {
      final container = await _pump(
        tester,
        Permission.values.toSet(),
        api: _realisticApi(),
      );
      final router = container.read(routerProvider);

      for (final path in [
        '/audit',
        '/reviews',
        '/promos',
        '/refunds',
        '/dashboard',
        '/airlines',
        '/airports',
      ]) {
        router.go(path);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: path);
      }
    });
  });

  group('shell banners and layouts', () {
    testWidgets('given the API unreachable when the app is open then warns '
        'the person', (tester) async {
      await _pump(tester, {Permission.adminPortalAccess}, reachable: false);

      expect(find.byType(DbookInlineStatusBanner), findsWidgets);
    });

    testWidgets('given production when the app is open then shows no '
        'environment banner', (tester) async {
      await _pump(tester, {
        Permission.adminPortalAccess,
      }, environment: 'production');

      expect(find.textContaining('HOMOLOGAÇÃO'), findsNothing);
      expect(find.textContaining('local'), findsNothing);
    });

    testWidgets('given a medium window when the app is open then the menu '
        'is a rail', (tester) async {
      await _pump(tester, {
        Permission.adminPortalAccess,
        Permission.customerRead,
      }, size: const Size(800, 900));

      expect(find.byType(NavigationRail), findsOneWidget);
    });
  });
}
