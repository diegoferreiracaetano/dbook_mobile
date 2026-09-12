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
  final _incoming = StreamController<String>.broadcast();

  @override
  Future<void> get ready => Future.value();

  @override
  Stream<String> get stream => _incoming.stream;

  @override
  void send(String data) {}

  @override
  Future<void> close() async => _incoming.close();

  void pushRaw(String raw) => _incoming.add(raw);
}

const _connectedFrame = 'CONNECTED\nversion:1.2\n\n\x00';

String _messageFrame(int capacity) =>
    'MESSAGE\n\n{"bookableId":1,"availableCapacity":$capacity}\x00';

void main() {
  testWidgets(
    'given a live update when received then shows the new capacity and the '
    'live indicator',
    (tester) async {
      final socket = _FakeSocket();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            baseUrlProvider.overrideWithValue('http://localhost:8080'),
            tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          ],
          child: MaterialApp(
            theme: DbookTheme.light,
            home: Scaffold(
              body: DbookLiveAvailability(
                bookableId: 1,
                fallbackCapacity: 12,
                socketFactory: (_) => socket,
              ),
            ),
          ),
        ),
      );

      expect(find.text('12'), findsOneWidget);
      expect(find.text('Conectando...'), findsOneWidget);

      // Várias pontas assíncronas antes do CONNECT ir pro socket
      // (readTokens(), addPostFrameCallback, socket.ready.then(...)) — pump
      // de sobra em vez de contar exatamente quantos microtasks cada uma
      // consome.
      for (var i = 0; i < 5; i++) {
        await tester.pump();
      }
      socket.pushRaw(_connectedFrame);
      for (var i = 0; i < 3; i++) {
        await tester.pump();
      }
      socket.pushRaw(_messageFrame(4));
      for (var i = 0; i < 3; i++) {
        await tester.pump();
      }

      expect(find.text('4'), findsOneWidget);
      expect(find.text('Ao vivo'), findsOneWidget);
    },
  );
}
