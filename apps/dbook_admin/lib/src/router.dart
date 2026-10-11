import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_feature_admin_auth/dbook_feature_admin_auth.dart';
import 'package:dbook_feature_admin_bookings/dbook_feature_admin_bookings.dart';
import 'package:dbook_feature_admin_catalog/dbook_feature_admin_catalog.dart';
import 'package:dbook_feature_admin_customers/dbook_feature_admin_customers.dart';
import 'package:dbook_feature_admin_dashboard/dbook_feature_admin_dashboard.dart'
    deferred as dashboard;
import 'package:dbook_feature_admin_governance/dbook_feature_admin_governance.dart';
import 'package:dbook_feature_admin_team/dbook_feature_admin_team.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'deferred_page.dart';
import 'destinations.dart';
import 'home_page.dart';
import 'shell.dart';
import 'status_pages.dart';

/// Só endereços **internos** servem de destino depois do login: evita o
/// *open redirect* (`?returnTo=https://site-malicioso`). Aceita um caminho que
/// começa com uma única `/` e não é a própria tela de login.
String? safeReturnTo(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (!raw.startsWith('/') || raw.startsWith('//') || raw.startsWith('/\\')) {
    return null;
  }
  final uri = Uri.tryParse(raw);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  if (uri.path == '/login' || uri.path == '/accept-invite') return null;
  return raw;
}

const _publicPaths = {'/login', '/accept-invite'};

/// A regra de acesso por endereço, pura para poder ser testada: quem não tem
/// sessão vai ao login (guardando para onde queria ir), quem tem não vê o
/// login, e a rota de uma área sem permissão leva a "sem acesso".
String? portalRedirect(AdminSessionState session, Uri uri) {
  final path = uri.path;
  final isPublic = _publicPaths.contains(path);

  switch (session) {
    case SessionRestoring() ||
        SessionSignedOut() ||
        SessionChallenge() ||
        SessionRecoveryCodes():
      if (isPublic) return null;
      final wanted = uri.toString();
      return wanted == '/'
          ? '/login'
          : '/login?returnTo=${Uri.encodeQueryComponent(wanted)}';
    case SessionSignedIn(:final profile):
      if (path == '/login') {
        return safeReturnTo(uri.queryParameters['returnTo']) ?? '/';
      }
      if (profile.mustChangePassword) {
        return path == '/change-password' ? null : '/change-password';
      }
      if (path == '/change-password') return '/';
      final destination = destinationFor(path);
      final needed = destination?.permission;
      if (needed != null && !profile.can(needed)) return '/forbidden';
      return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(adminSessionProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) =>
        portalRedirect(ref.read(adminSessionProvider), state.uri),
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/accept-invite',
        builder: (context, state) => AcceptInvitePage(
          token: state.uri.queryParameters['token'],
          onGoToLogin: () => context.go('/login'),
        ),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordPage(forced: true),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            PortalShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/account',
            builder: (context, state) => AccountPage(
              onChangePassword: () => context.go('/account/password'),
            ),
            routes: [
              GoRoute(
                path: 'password',
                builder: (context, state) => const ChangePasswordPage(),
              ),
            ],
          ),
          GoRoute(path: '/team', builder: (context, state) => const TeamPage()),
          GoRoute(
            path: '/customers',
            builder: (context, state) => CustomersPage(
              query: CustomerQueryCodec.decode(state.uri.queryParameters),
              onQueryChanged: (query) => context.go(
                Uri(
                  path: '/customers',
                  queryParameters: CustomerQueryCodec.encode(query),
                ).toString(),
              ),
              onOpen: (id) => context.go('/customers/$id'),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => CustomerDetailPage(
                  id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
                  onBack: () => context.go('/customers'),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => BookingsPage(
              query: BookingQueryCodec.decode(state.uri.queryParameters),
              onQueryChanged: (query) => context.go(
                Uri(
                  path: '/bookings',
                  queryParameters: BookingQueryCodec.encode(query),
                ).toString(),
              ),
              onOpen: (id) => context.go('/bookings/$id'),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => BookingDetailPage(
                  id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
                  onBack: () => context.go('/bookings'),
                  onOpenCustomer: (id) => context.go('/customers/$id'),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/refunds',
            builder: (context, state) {
              final status = RefundStatus.values
                  .asNameMap()[state.uri.queryParameters['status']];
              final page =
                  int.tryParse(state.uri.queryParameters['page'] ?? '') ?? 0;
              return RefundsPage(
                query: (status: status, page: page, size: 20),
                onQueryChanged: (query) => context.go(
                  Uri(
                    path: '/refunds',
                    queryParameters: {
                      if (query.status != null) 'status': query.status!.name,
                      if (query.page != 0) 'page': '${query.page}',
                    },
                  ).toString(),
                ),
                onOpenBooking: (id) => context.go('/bookings/$id'),
              );
            },
          ),
          GoRoute(
            path: '/flights',
            builder: (context, state) => FlightsPage(
              query: FlightQueryCodec.decode(state.uri.queryParameters),
              onQueryChanged: (query) => context.go(
                Uri(
                  path: '/flights',
                  queryParameters: FlightQueryCodec.encode(query),
                ).toString(),
              ),
              onOpen: (id) => context.go('/flights/$id'),
              onCreate: () => context.go('/flights/new'),
              onImport: () => context.go('/flights/import'),
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => FlightFormPage(
                  onBack: () => context.go('/flights'),
                  onSaved: (id) =>
                      context.go(id == null ? '/flights' : '/flights/$id'),
                ),
              ),
              GoRoute(
                path: 'import',
                builder: (context, state) => ImportFlightsPage(
                  onBack: () => context.go('/flights'),
                  onDone: () => context.go('/flights'),
                ),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => FlightFormPage(
                  id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
                  onBack: () => context.go('/flights'),
                  onSaved: (_) {},
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/airlines',
            builder: (context, state) => const AirlinesPage(),
          ),
          GoRoute(
            path: '/airports',
            builder: (context, state) => const AirportsPage(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) {
              final from = DateTime.tryParse(
                state.uri.queryParameters['from'] ?? '',
              );
              final to = DateTime.tryParse(
                state.uri.queryParameters['to'] ?? '',
              );
              final period = from != null && to != null && !to.isBefore(from)
                  ? (from: from, to: to)
                  : lastDays(DateTime.now(), 30);
              String day(DateTime d) =>
                  '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
              return DeferredPage(
                load: dashboard.loadLibrary,
                builder: (_) => dashboard.DashboardPage(
                  period: period,
                  onPeriodChanged: (next) => context.go(
                    Uri(
                      path: '/dashboard',
                      queryParameters: {
                        'from': day(next.from),
                        'to': day(next.to),
                      },
                    ).toString(),
                  ),
                ),
              );
            },
          ),
          GoRoute(
            path: '/audit',
            builder: (context, state) => AuditPage(
              query: AuditQueryCodec.decode(state.uri.queryParameters),
              onQueryChanged: (query) => context.go(
                Uri(
                  path: '/audit',
                  queryParameters: AuditQueryCodec.encode(query),
                ).toString(),
              ),
              onOpenTarget: (type, id) {
                final path = switch (type) {
                  'CUSTOMER' => '/customers/$id',
                  'BOOKING' => '/bookings/$id',
                  'FLIGHT' => '/flights/$id',
                  _ => null,
                };
                if (path != null) context.go(path);
              },
            ),
          ),
          GoRoute(
            path: '/reviews',
            builder: (context, state) {
              final queue =
                  ReviewQueue.values
                      .asNameMap()[state.uri.queryParameters['queue']] ??
                  ReviewQueue.reported;
              final page =
                  int.tryParse(state.uri.queryParameters['page'] ?? '') ?? 0;
              return ReviewsPage(
                request: (queue: queue, page: page),
                onRequestChanged: (request) => context.go(
                  Uri(
                    path: '/reviews',
                    queryParameters: {
                      'queue': request.queue.name,
                      if (request.page != 0) 'page': '${request.page}',
                    },
                  ).toString(),
                ),
              );
            },
          ),
          GoRoute(
            path: '/promos',
            builder: (context, state) {
              final active = switch (state.uri.queryParameters['active']) {
                'yes' => true,
                'no' => false,
                _ => null,
              };
              final page =
                  int.tryParse(state.uri.queryParameters['page'] ?? '') ?? 0;
              return PromosPage(
                query: (active: active, page: page, size: 20),
                onQueryChanged: (query) => context.go(
                  Uri(
                    path: '/promos',
                    queryParameters: {
                      if (query.active != null)
                        'active': query.active! ? 'yes' : 'no',
                      if (query.page != 0) 'page': '${query.page}',
                    },
                  ).toString(),
                ),
              );
            },
          ),
          GoRoute(
            path: '/forbidden',
            builder: (context, state) => const ForbiddenPage(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
