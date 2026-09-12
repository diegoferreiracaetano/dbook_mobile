import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../state/availability_state.dart';
import 'dbook_realtime_socket.dart';
import 'stomp_frame.dart';

/// Cliente STOMP mínimo pra assinar `/topic/bookables/{id}/availability` —
/// só o suficiente pra este caso de uso: CONNECT com o token, SUBSCRIBE no
/// tópico, parsear MESSAGE, e reconectar com backoff se a conexão cair.
/// Não manda nada além disso (sem prefixo `/app` no backend, é só o
/// servidor empurrando atualização — o cliente nunca dá SEND).
class StompAvailabilityClient {
  StompAvailabilityClient({
    required this.wsUri,
    required this.accessToken,
    DbookRealtimeSocket Function(Uri uri)? socketFactory,
  }) : _socketFactory = socketFactory ?? WebSocketRealtimeSocket.new;

  final Uri wsUri;
  final String accessToken;
  final DbookRealtimeSocket Function(Uri uri) _socketFactory;

  StreamController<AvailabilityState>? _controller;
  StreamSubscription<String>? _socketSubscription;
  DbookRealtimeSocket? _socket;
  Timer? _reconnectTimer;
  int? _lastKnownCapacity;
  var _reconnectAttempt = 0;
  var _disposed = false;
  late int _bookableId;

  /// Conecta, autentica e assina a disponibilidade de [bookableId]. O
  /// stream retornado emite todo estado da sessão até [dispose] ser
  /// chamado — não feche fora daqui.
  Stream<AvailabilityState> connect(int bookableId) {
    _bookableId = bookableId;
    _controller = StreamController<AvailabilityState>.broadcast();
    _openSocket();
    return _controller!.stream;
  }

  void _openSocket() {
    if (_disposed) return;
    _controller!.add(
      _reconnectAttempt == 0
          ? const AvailabilityState.connecting()
          : AvailabilityState.reconnecting(_lastKnownCapacity),
    );

    final socket = _socketFactory(wsUri);
    _socket = socket;

    socket.ready
        .then((_) {
          if (_disposed) return;
          socket.send(
            StompFrame('CONNECT', {
              'accept-version': '1.2',
              'heart-beat': '0,0',
              'Authorization': 'Bearer $accessToken',
            }, '').serialize(),
          );
        })
        .catchError((Object _) => _scheduleReconnect());

    _socketSubscription = socket.stream.listen(
      _handleRawMessage,
      onError: (Object _) => _scheduleReconnect(),
      onDone: _scheduleReconnect,
    );
  }

  void _handleRawMessage(String raw) {
    if (raw.trim().isEmpty) return; // heartbeat newline, shouldn't happen
    final frame = StompFrame.parse(raw);

    switch (frame.command) {
      case 'CONNECTED':
        _reconnectAttempt = 0;
        _socket!.send(
          StompFrame('SUBSCRIBE', {
            'id': 'sub-availability',
            'destination': '/topic/bookables/$_bookableId/availability',
          }, '').serialize(),
        );
      case 'MESSAGE':
        final json = jsonDecode(frame.body) as Map<String, dynamic>;
        final capacity = json['availableCapacity'] as int;
        _lastKnownCapacity = capacity;
        _controller?.add(AvailabilityState.live(capacity));
      case 'ERROR':
        _controller?.add(
          AvailabilityState.unavailable(
            frame.body.trim().isEmpty
                ? 'A conexão foi recusada pelo servidor'
                : frame.body.trim(),
          ),
        );
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    unawaited(_socketSubscription?.cancel());
    _reconnectAttempt++;
    _controller?.add(AvailabilityState.reconnecting(_lastKnownCapacity));
    final delaySeconds = min(_reconnectAttempt * 2, 10);
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), _openSocket);
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    unawaited(_socketSubscription?.cancel());
    unawaited(_socket?.close());
    unawaited(_controller?.close());
  }
}
