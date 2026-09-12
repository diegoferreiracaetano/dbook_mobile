import 'dart:async';

import 'package:dbook_feature_realtime/dbook_feature_realtime.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSocket implements DbookRealtimeSocket {
  final _incoming = StreamController<String>.broadcast();
  final sentFrames = <String>[];
  var closed = false;

  @override
  Future<void> get ready => Future.value();

  @override
  Stream<String> get stream => _incoming.stream;

  @override
  void send(String data) => sentFrames.add(data);

  @override
  Future<void> close() async {
    closed = true;
    await _incoming.close();
  }

  void pushRaw(String raw) => _incoming.add(raw);

  void simulateDisconnect() => _incoming.addError(StateError('disconnected'));
}

const _connectedFrame = 'CONNECTED\nversion:1.2\n\n\x00';

String _messageFrame(int capacity) =>
    'MESSAGE\n'
    'destination:/topic/bookables/1/availability\n'
    '\n'
    '{"bookableId":1,"availableCapacity":$capacity}\x00';

const _errorFrame = 'ERROR\n\nInvalid token\x00';

void main() {
  test('given a fresh connection when it becomes ready then sends CONNECT with '
      'the access token', () async {
    final sockets = <_FakeSocket>[];
    final client = StompAvailabilityClient(
      wsUri: Uri.parse('ws://localhost:8080/ws'),
      accessToken: 'access-token',
      socketFactory: (_) {
        final socket = _FakeSocket();
        sockets.add(socket);
        return socket;
      },
    );
    addTearDown(client.dispose);

    client.connect(1);
    await Future<void>.delayed(Duration.zero);

    expect(sockets.single.sentFrames.single, contains('CONNECT'));
    expect(
      sockets.single.sentFrames.single,
      contains('Authorization:Bearer access-token'),
    );
  });

  test('given a CONNECTED frame when received then subscribes to the '
      "bookable's availability topic", () async {
    final sockets = <_FakeSocket>[];
    final client = StompAvailabilityClient(
      wsUri: Uri.parse('ws://localhost:8080/ws'),
      accessToken: 'access-token',
      socketFactory: (_) {
        final socket = _FakeSocket();
        sockets.add(socket);
        return socket;
      },
    );
    addTearDown(client.dispose);

    client.connect(1);
    await Future<void>.delayed(Duration.zero);
    sockets.single.pushRaw(_connectedFrame);
    await Future<void>.delayed(Duration.zero);

    expect(sockets.single.sentFrames.last, contains('SUBSCRIBE'));
    expect(
      sockets.single.sentFrames.last,
      contains('destination:/topic/bookables/1/availability'),
    );
  });

  test('given a MESSAGE frame when received then emits live with the parsed capacity', () async {
    final sockets = <_FakeSocket>[];
    final client = StompAvailabilityClient(
      wsUri: Uri.parse('ws://localhost:8080/ws'),
      accessToken: 'access-token',
      socketFactory: (_) {
        final socket = _FakeSocket();
        sockets.add(socket);
        return socket;
      },
    );
    addTearDown(client.dispose);

    final states = <AvailabilityState>[];
    client.connect(1).listen(states.add);
    await Future<void>.delayed(Duration.zero);
    sockets.single.pushRaw(_connectedFrame);
    await Future<void>.delayed(Duration.zero);
    sockets.single.pushRaw(_messageFrame(4));
    await Future<void>.delayed(Duration.zero);

    expect(states.last, const AvailabilityState.live(4));
  });

  test('given an ERROR frame when received then emits unavailable with the message', () async {
    final sockets = <_FakeSocket>[];
    final client = StompAvailabilityClient(
      wsUri: Uri.parse('ws://localhost:8080/ws'),
      accessToken: 'bad-token',
      socketFactory: (_) {
        final socket = _FakeSocket();
        sockets.add(socket);
        return socket;
      },
    );
    addTearDown(client.dispose);

    final states = <AvailabilityState>[];
    client.connect(1).listen(states.add);
    await Future<void>.delayed(Duration.zero);
    sockets.single.pushRaw(_errorFrame);
    await Future<void>.delayed(Duration.zero);

    expect(states.last, const AvailabilityState.unavailable('Invalid token'));
  });

  test(
    'given a live connection when it disconnects then reconnects after a '
    'backoff and resubscribes, keeping the last known capacity meanwhile',
    () {
      fakeAsync((async) {
        final sockets = <_FakeSocket>[];
        final client = StompAvailabilityClient(
          wsUri: Uri.parse('ws://localhost:8080/ws'),
          accessToken: 'access-token',
          socketFactory: (_) {
            final socket = _FakeSocket();
            sockets.add(socket);
            return socket;
          },
        );
        addTearDown(client.dispose);

        final states = <AvailabilityState>[];
        client.connect(1).listen(states.add);
        async.flushMicrotasks();
        sockets[0].pushRaw(_connectedFrame);
        async.flushMicrotasks();
        sockets[0].pushRaw(_messageFrame(4));
        async.flushMicrotasks();

        expect(states.last, const AvailabilityState.live(4));

        sockets[0].simulateDisconnect();
        async.flushMicrotasks();

        expect(states.last, const AvailabilityState.reconnecting(4));

        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();

        expect(sockets, hasLength(2));
        sockets[1].pushRaw(_connectedFrame);
        async.flushMicrotasks();

        expect(sockets[1].sentFrames.last, contains('SUBSCRIBE'));

        sockets[1].pushRaw(_messageFrame(3));
        async.flushMicrotasks();

        expect(states.last, const AvailabilityState.live(3));
      });
    },
  );

  test('given dispose when called then closes the socket', () async {
    final sockets = <_FakeSocket>[];
    final client = StompAvailabilityClient(
      wsUri: Uri.parse('ws://localhost:8080/ws'),
      accessToken: 'access-token',
      socketFactory: (_) {
        final socket = _FakeSocket();
        sockets.add(socket);
        return socket;
      },
    );

    client.connect(1);
    await Future<void>.delayed(Duration.zero);
    client.dispose();
    await Future<void>.delayed(Duration.zero);

    expect(sockets.single.closed, isTrue);
  });
}
