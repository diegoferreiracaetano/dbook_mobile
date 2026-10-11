import 'dart:convert';
import 'dart:io';

import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

/// Respostas **reais** do backend (capturadas de uma API local com dados de
/// teste), para provar que os modelos do portal leem o contrato de verdade e
/// não só o que imaginamos dele. Se o servidor mudar um campo, o teste que
/// lê aquela resposta quebra aqui, antes de quebrar uma tela.
Object _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync()) as Object;

Dio _dioServing(Map<String, String> byPath) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final name = byPath[options.path];
        if (name == null) {
          handler.reject(
            DioException(
              requestOptions: options,
              message: 'sem fixture para ${options.path}',
            ),
          );
          return;
        }
        handler.resolve(
          Response<Object>(
            requestOptions: options,
            statusCode: 200,
            data: _fixture(name),
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  test(
    'given the real /me when parsed then the super admin has permissions',
    () async {
      final dio = _dioServing({'/admin/auth/me': 'me'});

      final me = await DioAdminAuthApi(dio).me();

      expect(me.role, Role.superAdmin);
      expect(me.permissions, contains(Permission.adminManage));
      expect(me.email, isNotEmpty);
    },
  );

  test(
    'given the real staff and invitations when parsed then lists them',
    () async {
      final dio = _dioServing({
        '/admin/staff': 'staff',
        '/admin/invitations': 'invitations',
      });
      final api = DioTeamApi(dio);

      final staff = await api.listStaff();

      expect(staff, isNotEmpty);
      expect(staff.first.status, StaffStatus.active);
      expect(await api.listInvitations(), isEmpty);
    },
  );

  test(
    'given the real customers when parsed then list and detail agree',
    () async {
      final dio = _dioServing({
        '/admin/customers': 'customers',
        '/admin/customers/2': 'customer_detail',
        '/admin/customers/2/reviews': 'customer_reviews',
      });
      final api = DioCustomersApi(dio);

      final page = await api.list(defaultCustomerQuery);
      final detail = await api.get(page.items.first.id);

      expect(page.totalElements, 1);
      expect(detail.email, page.items.first.email);
      expect(detail.bookings.total, greaterThan(0));
      expect(await api.reviews(2), isEmpty);
    },
  );

  test(
    'given the real bookings when parsed then flight and stay differ',
    () async {
      final dio = _dioServing({
        '/admin/bookings': 'bookings',
        '/admin/bookings/2': 'booking_detail',
        '/admin/refunds': 'refunds',
      });
      final api = DioAdminBookingsApi(dio);

      final page = await api.list(defaultBookingQuery);
      final detail = await api.get(2);

      expect(page.items.map((b) => b.id), containsAll([1, 2]));
      expect(detail.booking.status, BookingStatus.confirmed);
      expect(detail.payment, isNotNull);
      expect(detail.timeline, isNotEmpty);
      expect(
        (await api.listRefunds((status: null, page: 0, size: 10))).items,
        isEmpty,
      );
    },
  );

  test('given the real catalog when parsed then flights airlines and '
      'airports are read', () async {
    final dio = _dioServing({
      '/admin/flights': 'flights',
      '/admin/flights/1': 'flight_detail',
      '/admin/airlines': 'airlines',
      '/admin/airports': 'airports',
    });
    final api = DioCatalogApi(dio);

    final flights = await api.listFlights(defaultFlightQuery);
    final detail = await api.getFlight(1);

    expect(flights.items.single.flightNumber, 'DB1001');
    expect(detail.flight.flightNumber, 'DB1001');
    expect(await api.airlines(), hasLength(6));
    expect((await api.airports()).first.iataCode, hasLength(3));
  });

  test('given the real dashboard when parsed then numbers are read', () async {
    final dio = _dioServing({
      '/admin/dashboard/summary': 'summary',
      '/admin/dashboard/timeseries': 'timeseries',
      '/admin/dashboard/top-routes': 'top_routes',
    });
    final api = DioDashboardApi(dio);
    final period = (from: DateTime(2026, 9, 1), to: DateTime(2026, 10, 9));

    final summary = await api.summary(period);
    final series = await api.timeSeries(
      metric: DashboardMetric.revenue,
      granularity: DashboardGranularity.day,
      period: period,
    );

    expect(summary.grossRevenue, 1050);
    expect(series.points, hasLength(greaterThan(30)));
    expect(await api.topRoutes(period), isEmpty);
  });

  test('given the real audit trail when parsed then actions are read and '
      'cursor is optional', () async {
    final dio = _dioServing({'/admin/audit': 'audit'});

    final page = await DioAuditApi(dio).search((
      actorId: null,
      action: null,
      targetType: null,
      targetId: null,
      outcome: null,
      from: null,
      to: null,
      cursor: null,
      size: 10,
    ));

    expect(page.items, isNotEmpty);
    expect(page.items.first.action, isNotEmpty);
    expect(page.hasMore, isFalse);
  });

  test('given the real governance lists when parsed then empty pages are '
      'valid', () async {
    final dio = _dioServing({
      '/admin/promo-codes': 'promos',
      '/admin/reviews': 'reviews',
    });
    final api = DioGovernanceApi(dio);

    expect(
      (await api.promos((active: null, page: 0, size: 10))).totalElements,
      0,
    );
    expect((await api.reviews(queue: ReviewQueue.values.first)).items, isEmpty);
  });
}
