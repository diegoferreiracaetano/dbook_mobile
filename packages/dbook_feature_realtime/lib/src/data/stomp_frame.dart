/// Um frame STOMP mínimo — só o que este cliente precisa (COMMAND +
/// headers + body), sem heart-beat de verdade (pedimos `heart-beat:0,0`
/// no CONNECT, então o servidor nunca manda um).
class StompFrame {
  const StompFrame(this.command, this.headers, this.body);

  final String command;
  final Map<String, String> headers;
  final String body;

  /// Serializa no formato de fio do STOMP: `COMMAND\nheader:valor\n...\n\nbody\x00`.
  String serialize() {
    final buffer = StringBuffer()..writeln(command);
    headers.forEach((key, value) => buffer.writeln('$key:$value'));
    buffer
      ..writeln()
      ..write(body)
      ..write('\x00');
    return buffer.toString();
  }

  /// Parseia um frame recebido. `raw` pode ou não ter o `\x00` final (o
  /// `web_socket_channel` entrega uma mensagem de texto por frame WebSocket,
  /// e cada frame WebSocket carrega exatamente um frame STOMP).
  static StompFrame parse(String raw) {
    final withoutNull = raw.endsWith('\x00')
        ? raw.substring(0, raw.length - 1)
        : raw;
    final lines = withoutNull.split('\n');
    final command = lines.first;
    final headers = <String, String>{};

    var i = 1;
    for (; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty) {
        i++;
        break;
      }
      final separator = line.indexOf(':');
      if (separator == -1) continue;
      headers[line.substring(0, separator)] = line.substring(separator + 1);
    }

    final body = lines.sublist(i.clamp(0, lines.length)).join('\n');
    return StompFrame(command, headers, body);
  }
}
