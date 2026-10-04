import 'dart:async';

import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_realtime/dbook_feature_realtime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTokenStorage implements TokenStorage {
  @override
  Future<AuthTokens?> readTokens() async =>
      const AuthTokens(accessToken: 'access', refreshToken: 'refresh');

  @override
  Future<void> saveTokens(AuthTokens tokens) async {}

  @override
  Future<void> clear() async {}
}

class _FakeSocket implements DbookRealtimeSocket {
  @override
  Future<void> get ready => Future.value();

  @override
  Stream<String> get stream => const Stream<String>.empty();

  @override
  void send(String data) {}

  @override
  Future<void> close() async {}
}

void main() {
  testWidgets('given an api base url that carries a version when the live '
      'availability connects then the websocket does not inherit it', (
    tester,
  ) async {
    Uri? connectedTo;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          baseUrlProvider.overrideWithValue('http://localhost:8080/v1'),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
        ],
        child: MaterialApp(
          theme: DbookTheme.light,
          home: Scaffold(
            body: DbookLiveAvailability(
              bookableId: 1,
              fallbackCapacity: 12,
              socketFactory: (uri) {
                connectedTo = uri;
                return _FakeSocket();
              },
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump();
    }

    // the WebSocket is outside any API version: /ws, not /v1/ws
    expect(connectedTo.toString(), 'ws://localhost:8080/ws');
  });
}
