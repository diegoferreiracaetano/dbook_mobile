import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _Recorder {
  _Recorder(this.reply) {
    dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls.add(options);
          handler.resolve(
            Response<Object>(
              requestOptions: options,
              statusCode: 200,
              data: reply,
            ),
          );
        },
      ),
    );
  }

  final Object reply;
  late final Dio dio;
  final calls = <RequestOptions>[];
}

void main() {
  group('wire enums', () {
    test('given every known notification type when round tripping then it '
        'survives', () {
      for (final type in NotificationType.values) {
        if (type == NotificationType.unknown) continue;
        expect(notificationTypeFromWire(notificationTypeToWire(type)), type);
      }
    });

    test('given an unknown wire value when reading then falls back instead '
        'of throwing', () {
      expect(notificationTypeFromWire('NOVO_TIPO'), NotificationType.unknown);
      expect(notificationChannelFromWire('SMS'), isNull);
      expect(cancellationActionFromWire('???'), CancellationAction.none);
      expect(cancellationBlockFromWire('???'), CancellationBlock.unknown);
      expect(refundProgressFromWire('???'), RefundProgress.unknown);
      expect(roleFromWire('ALGO_NOVO'), Role.unknown);
    });

    test('given every channel when round tripping then it survives', () {
      for (final channel in NotificationChannel.values) {
        expect(
          notificationChannelFromWire(notificationChannelToWire(channel)),
          channel,
        );
      }
    });

    test('given cancellation and refund wire values when reading then maps '
        'each', () {
      expect(
        cancellationActionFromWire('REFUND_REQUEST'),
        CancellationAction.refundRequest,
      );
      expect(
        cancellationBlockFromWire('WINDOW_CLOSED'),
        CancellationBlock.windowClosed,
      );
      expect(
        cancellationBlockFromWire('ALREADY_REFUNDED'),
        CancellationBlock.alreadyRefunded,
      );
      expect(refundProgressFromWire('COMPLETED'), RefundProgress.completed);
      expect(refundProgressFromWire('FAILED'), RefundProgress.failed);
    });

    test('given the four booking statuses when reading then maps each', () {
      expect(bookingStatusFromWire('PENDING'), BookingStatus.pending);
      expect(bookingStatusFromWire('CONFIRMED'), BookingStatus.confirmed);
      expect(bookingStatusFromWire('CANCELLED'), BookingStatus.cancelled);
      expect(bookingStatusFromWire('EXPIRED'), BookingStatus.expired);
      expect(bookingStatusFromWire('REFUNDED'), BookingStatus.refunded);
    });
  });

  group('auth repository', () {
    test('given credentials when logging in then posts them and reads the '
        'tokens', () async {
      final r = _Recorder({'accessToken': 'a', 'refreshToken': 'r'});

      final tokens = await AuthRepositoryImpl(r.dio)
          .login(email: 'a@b.c', password: 'segredo');

      expect(r.calls.single.path, '/auth/login');
      expect(r.calls.single.data, {'email': 'a@b.c', 'password': 'segredo'});
      expect(tokens.accessToken, 'a');
      expect(tokens.refreshToken, 'r');
    });

    test('given a refresh token when refreshing then posts it', () async {
      final r = _Recorder({'accessToken': 'a2', 'refreshToken': 'r2'});

      final tokens = await AuthRepositoryImpl(r.dio).refresh('r1');

      expect(r.calls.single.path, '/auth/refresh');
      expect(r.calls.single.data, {'refreshToken': 'r1'});
      expect(tokens.refreshToken, 'r2');
    });

    test(
      'given a new user when registering then returns the created user',
      () async {
        final r = _Recorder({
          'id': 9,
          'email': 'n@d.t',
          'name': 'Nova',
          'role': 'CLIENT',
        });

        final user = await AuthRepositoryImpl(r.dio)
            .register(email: 'n@d.t', password: 'segredo123', name: 'Nova');

        expect(r.calls.single.path, '/auth/register');
        expect(user.name, 'Nova');
      },
    );

    test('given the profile endpoints when reading and renaming then uses '
        '/users/me', () async {
      final r = _Recorder({
        'id': 9,
        'email': 'n@d.t',
        'name': 'Nova',
        'role': 'CLIENT',
      });
      final repo = AuthRepositoryImpl(r.dio);

      await repo.getMe();
      await repo.updateName('Outro');

      expect(r.calls[0].method, 'GET');
      expect(r.calls[1].method, 'PATCH');
      expect(r.calls[1].data, {'name': 'Outro'});
    });

    test('given a 401 when logging in then throws the typed unauthorized '
        'error', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.reject(
            DioException.badResponse(
              statusCode: 401,
              requestOptions: options,
              response: Response<Object>(
                requestOptions: options,
                statusCode: 401,
                data: {'error': 'Invalid email or password'},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        AuthRepositoryImpl(dio).login(email: 'a@b.c', password: 'x'),
        throwsA(isA<DbookUnauthorizedException>()),
      );
    });
  });

  group('flight repository', () {
    test(
      'given a search when calling then sends the route and the day',
      () async {
        final r = _Recorder(<Object>[]);

        final flights = await FlightRepositoryImpl(r.dio).search(
          originIataCode: 'GRU',
          destinationIataCode: 'GIG',
          date: DateTime(2027, 1, 5),
        );

        expect(flights, isEmpty);
        expect(r.calls.single.path, '/flights/search');
        expect(r.calls.single.queryParameters['date'], '2027-01-05');
        expect(r.calls.single.queryParameters['origin'], 'GRU');
      },
    );

    test('given a flight id when asking the seats then reads them', () async {
      final r = _Recorder([
        {'id': 1, 'label': '1A', 'status': 'AVAILABLE'},
        {'id': 2, 'label': '1B', 'status': 'RESERVED'},
      ]);

      final seats = await FlightRepositoryImpl(r.dio).getSeats(7);

      expect(r.calls.single.path, '/bookables/7/seats');
      expect(seats.map((s) => s.label), ['1A', '1B']);
      expect(seats.last.status, SeatStatus.reserved);
    });
  });

  group('notification repository writes', () {
    test('given the inbox when marking read, all read, registering and '
        'removing a device then uses each route', () async {
      final r = _Recorder(<String, dynamic>{});
      final repo = NotificationRepositoryImpl(r.dio);

      await repo.markRead(4);
      await repo.markAllRead();
      await repo.registerDevice(token: 'tok/1', platform: 'web');
      await repo.unregisterDevice('tok/1');

      expect(r.calls[0].path, '/notifications/4/read');
      expect(r.calls[1].path, '/notifications/read-all');
      expect(r.calls[2].path, '/notifications/devices');
      expect(r.calls[2].data, {'token': 'tok/1', 'platform': 'WEB'});
      expect(r.calls[3].method, 'DELETE');
      expect(r.calls[3].path, '/notifications/devices/tok%2F1');
    });

    test(
      'given preference changes when updating then sends the pairs',
      () async {
        final r = _Recorder([
          {'type': 'PRICE_ALERT', 'channel': 'PUSH', 'enabled': false},
        ]);

        final result = await NotificationRepositoryImpl(r.dio)
            .updatePreferences(const [
              NotificationPreference(
                type: NotificationType.priceAlert,
                channel: NotificationChannel.push,
                enabled: false,
              ),
            ]);

        expect(r.calls.single.method, 'PUT');
        expect(result.single.enabled, isFalse);
      },
    );
  });
}
