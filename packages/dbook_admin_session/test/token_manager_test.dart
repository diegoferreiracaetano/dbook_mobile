import 'dart:async';

import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  group('jwtExpiry', () {
    test('given a token with exp when read then returns that instant', () {
      final at = DateTime.utc(2026, 10, 7, 12);

      expect(jwtExpiry(fakeJwt(expiresAt: at))?.toUtc(), at);
    });

    test('given a malformed token when read then returns null', () {
      expect(jwtExpiry('not-a-jwt'), isNull);
      expect(jwtExpiry('a.b.c'), isNull);
    });
  });

  group('SessionTokenManager', () {
    test('given many refreshes at once when they run then the server is hit '
        'once and all get the same token', () async {
      var calls = 0;
      final gate = Completer<String>();
      final manager = SessionTokenManager(() {
        calls++;
        return gate.future;
      });

      final results = [for (var i = 0; i < 10; i++) manager.refresh()];
      gate.complete('fresh');

      expect(await Future.wait(results), everyElement('fresh'));
      expect(calls, 1);
      expect(manager.accessToken, 'fresh');
    });

    test('given a finished refresh when another is asked then a new call '
        'happens', () async {
      var calls = 0;
      final manager = SessionTokenManager(() async => 'token-${++calls}');

      await manager.refresh();
      await manager.refresh();

      expect(calls, 2);
    });

    test('given a failed refresh when it ends then the next one can try '
        'again', () async {
      var calls = 0;
      final manager = SessionTokenManager(() async {
        if (++calls == 1) throw StateError('cookie lost');
        return 'ok';
      });

      await expectLater(manager.refresh(), throwsStateError);
      expect(await manager.refresh(), 'ok');
    });

    test('given a token that expires in 5 minutes when asked then it renews '
        '60 seconds early', () {
      final now = DateTime(2026, 10, 7, 12);
      final manager = SessionTokenManager(() async => '')
        ..setToken(fakeJwt(expiresAt: now.add(const Duration(minutes: 5))));

      expect(manager.timeUntilRefresh(now), const Duration(minutes: 4));
    });

    test('given an already expired token when asked then renews now', () {
      final now = DateTime(2026, 10, 7, 12);
      final manager = SessionTokenManager(
        () async => '',
      )..setToken(fakeJwt(expiresAt: now.subtract(const Duration(minutes: 1))));

      expect(manager.timeUntilRefresh(now), Duration.zero);
    });

    test('given cleared when read then there is no token', () {
      final manager = SessionTokenManager(() async => '')..setToken('x.y.z');

      manager.clear();

      expect(manager.hasToken, isFalse);
    });
  });
}
