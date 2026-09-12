import 'package:web_socket_channel/web_socket_channel.dart';

/// Porta fina sobre um WebSocket de texto — existe só pra poder trocar por
/// um fake nos testes (`web_socket_channel` não oferece um jeito simples de
/// simular servidor sem abrir um socket de verdade).
abstract interface class DbookRealtimeSocket {
  Future<void> get ready;
  Stream<String> get stream;
  void send(String data);
  Future<void> close();
}

class WebSocketRealtimeSocket implements DbookRealtimeSocket {
  WebSocketRealtimeSocket(Uri uri) : _channel = WebSocketChannel.connect(uri);

  final WebSocketChannel _channel;

  @override
  Future<void> get ready => _channel.ready;

  @override
  Stream<String> get stream => _channel.stream.cast<String>();

  @override
  void send(String data) => _channel.sink.add(data);

  @override
  Future<void> close() => _channel.sink.close();
}
