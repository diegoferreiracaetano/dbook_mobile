import 'dart:async';

import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  late SessionTokenManager tokens;
  late FakeHttpAdapter adapter;
  late Dio dio;
  late int refreshCalls;
  late int sessionLost;
  Completer<String>? gate;
  Object? refreshFailure;

  setUp(() {
    refreshCalls = 0;
    sessionLost = 0;
    gate = null;
    refreshFailure = null;
    tokens = SessionTokenManager(() async {
      refreshCalls++;
      if (gate != null) await gate!.future;
      if (refreshFailure != null) throw refreshFailure!;
      return 'new';
    })..setToken('old');
    // o servidor só aceita o token novo
    adapter = FakeHttpAdapter((options) {
      final ok = options.headers['Authorization'] == 'Bearer new';
      return jsonBody(ok ? 200 : 401, ok ? {'ok': true} : {'error': 'x'});
    });
    dio = Dio(BaseOptions(baseUrl: 'http://api/v1'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      AdminAuthInterceptor(
        tokens: tokens,
        dio: dio,
        onSessionLost: () => sessionLost++,
      ),
    );
  });

  test(
    'given a valid token when a call is made then it carries the bearer',
    () async {
      tokens.setToken('new');

      await dio.get<Object>('/x');

      expect(adapter.seen.single.headers['Authorization'], 'Bearer new');
    },
  );

  test('given an expired token when a call gets 401 then it renews and the '
      'call is repeated with the new token', () async {
    final response = await dio.get<Object>('/x');

    expect(response.statusCode, 200);
    expect(refreshCalls, 1);
    expect(adapter.seen, hasLength(2));
  });

  test('given 10 calls that all get 401 at once when they renew then there '
      'is a single refresh', () async {
    gate = Completer<String>();

    final calls = [for (var i = 0; i < 10; i++) dio.get<Object>('/x$i')];
    await Future<void>.delayed(const Duration(milliseconds: 20));
    gate!.complete('new');
    final responses = await Future.wait(calls);

    expect(refreshCalls, 1);
    expect(responses.map((r) => r.statusCode), everyElement(200));
  });

  test(
    'given a 401 that arrives after another call already renewed when it '
    'ends then it repeats with the new token without renewing again',
    () async {
      adapter = FakeHttpAdapter((options) {
        final ok = options.headers['Authorization'] == 'Bearer new';
        // simula outra chamada que renovou enquanto esta estava no ar
        if (!ok) tokens.setToken('new');
        return jsonBody(ok ? 200 : 401, ok ? {'ok': true} : {'error': 'x'});
      });
      dio.httpClientAdapter = adapter;

      final response = await dio.get<Object>('/late');

      expect(response.statusCode, 200);
      expect(refreshCalls, 0);
    },
  );

  test('given a lost cookie when the renewal is refused then the session is '
      'lost and the original 401 reaches the caller', () async {
    refreshFailure = const DbookUnauthorizedException(
      'cookie',
      code: 'INVALID_TOKEN',
    );

    await expectLater(
      dio.get<Object>('/x'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );

    expect(sessionLost, 1);
    expect(tokens.hasToken, isFalse);
  });

  test('given the API down when the renewal fails with a network error then '
      'the session is kept and the error reaches the caller', () async {
    refreshFailure = const DbookUnknownNetworkException('timeout');

    await expectLater(dio.get<Object>('/x'), throwsA(isA<DioException>()));

    expect(sessionLost, 0);
    expect(tokens.hasToken, isTrue);
  });

  test('given a call that is still 401 after renewing when it ends then it '
      'does not loop', () async {
    adapter = FakeHttpAdapter((options) => jsonBody(401, {'error': 'x'}));
    dio.httpClientAdapter = adapter;

    await expectLater(dio.get<Object>('/x'), throwsA(isA<DioException>()));

    expect(refreshCalls, 1);
    expect(adapter.seen, hasLength(2));
    expect(sessionLost, 1);
  });

  test(
    'given a non-401 error when it happens then there is no renewal',
    () async {
      adapter = FakeHttpAdapter((options) => jsonBody(403, {'error': 'x'}));
      dio.httpClientAdapter = adapter;

      await expectLater(dio.get<Object>('/x'), throwsA(isA<DioException>()));

      expect(refreshCalls, 0);
    },
  );
}
