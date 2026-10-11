import 'dart:convert';
import 'dart:io';

import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

/// Respostas **reais** do backend para o app de clientes (capturadas de uma
/// API local), lidas pelos repositórios de verdade. Se o servidor mudar um
/// campo, quebra aqui antes de quebrar uma tela.
Dio _dioServing(Map<String, String> byPath) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final name = byPath[options.path];
        if (name == null) {
          handler.reject(
            DioException(requestOptions: options, message: options.path),
          );
          return;
        }
        handler.resolve(
          Response<Object>(
            requestOptions: options,
            statusCode: 200,
            data: jsonDecode(
              File('test/fixtures/$name.json').readAsStringSync(),
            ),
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  test('given the real inbox when read then the page is empty with no '
      'cursor and the count is zero', () async {
    final repo = NotificationRepositoryImpl(
      _dioServing({
        '/notifications': 'notifications',
        '/notifications/unread-count': 'unread_count',
        '/notifications/preferences': 'notif_prefs',
      }),
    );

    final page = await repo.list();
    final prefs = await repo.preferences();

    expect(page.items, isEmpty);
    expect(page.nextCursor, isNull);
    expect(await repo.unreadCount(), 0);
    expect(prefs, isNotEmpty);
    expect(
      prefs.map((p) => p.type),
      contains(NotificationType.bookingConfirmed),
    );
    expect(prefs.map((p) => p.channel), contains(NotificationChannel.inApp));
  });

  test(
    'given the real favorites when read then returns the IATA codes',
    () async {
      final repo = FavoriteRepositoryImpl(
        _dioServing({'/favorites': 'favorites'}),
      );

      expect(await repo.destinations(), {'GIG'});
    },
  );

  test('given the real price alerts and history when read then maps '
      'them', () async {
    final repo = PriceRepositoryImpl(
      _dioServing({
        '/price-alerts': 'price_alerts',
        '/flights/1/price-history': 'price_history',
      }),
    );

    final alerts = await repo.alerts();
    final history = await repo.history(1);

    expect(alerts.single.origin, 'GRU');
    expect(alerts.single.targetPrice, 400);
    expect(alerts.single.active, isTrue);
    expect(history.current, 450);
    expect(history.points, isNotEmpty);
  });

  test('given the real app-config when read then the platforms have a '
      'release', () async {
    final repo = AppConfigRepositoryImpl(
      _dioServing({'/app-config': 'app_config'}),
    );

    final config = await repo.fetch();

    expect(config.android, isNotNull);
    expect(config.forPlatform('web'), isNull);
  });

  test('given the real cancellation policy of an unpaid booking when read '
      'then the action is just cancel', () async {
    final repo = RefundRepositoryImpl(
      _dioServing({'/bookings/1/cancellation-policy': 'cancel_policy'}),
    );

    final policy = await repo.policy(1);

    expect(policy.action, CancellationAction.cancel);
    expect(policy.refundAmount, isNull);
  });

  test('given the real destination reviews when read then the summary '
      'has no average yet', () async {
    final repo = DestinationReviewRepositoryImpl(
      _dioServing({'/destinations/GIG/reviews': 'dest_reviews'}),
    );

    final reviews = await repo.list('GIG');

    expect(reviews.summary.average, isNull);
    expect(reviews.summary.total, 0);
    expect(reviews.page.items, isEmpty);
  });

  test('given the real data export when read then has the profile', () async {
    final repo = PrivacyRepositoryImpl(
      _dioServing({'/users/me/export': 'export'}),
    );

    final data = await repo.exportMyData();

    expect(data['profile'], isA<Map<String, dynamic>>());
  });

  test('given the real hotel search when read then rooms carry the stay '
      'total', () async {
    final repo = AccommodationRepositoryImpl(
      _dioServing({'/accommodations/search': 'accommodations_search'}),
    );

    final results = await repo.search(
      StaySearch(
        destination: 'GIG',
        checkIn: DateTime(2027, 1, 15),
        checkOut: DateTime(2027, 1, 18),
        guests: 2,
      ),
    );

    expect(results.single.rooms.single.totalPrice, 1050);
    expect(results.single.fromPrice, 1050);
  });
}
