import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fundo dos cards de destino carrega foto real via `NetworkImage` — em
/// teste de widget não há rede de verdade, então isso derrubava o teste
/// com `NetworkImageLoadException`. Troca só o `HttpClient` usado pelo
/// `NetworkImage` (não o `HttpOverrides` global) por um que devolve um
/// PNG 1x1 válido pra qualquer URL, só durante o teste.
///
/// `debugNetworkImageHttpClientProvider` é verificado pelo
/// `TestWidgetsFlutterBinding` no fim de CADA `testWidgets` (antes de
/// qualquer `tearDown` do pacote `test` rodar) — por isso o reset tem que
/// acontecer dentro do próprio callback do teste, não num `tearDown`
/// global, senão o binding acusa "painting debug variable was changed".
/// `testWidgetsWithMockImages` garante essa ordem.
void testWidgetsWithMockImages(
  String description,
  Future<void> Function(WidgetTester tester) callback,
) {
  testWidgets(description, (tester) async {
    debugNetworkImageHttpClientProvider = () => _FakeHttpClient();
    try {
      await callback(tester);
    } finally {
      debugNetworkImageHttpClientProvider = null;
    }
  });
}

const _transparentPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
    '+A8AAQUBAScY42YAAAAASUVORK5CYII=';

class _FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final Uint8List _bytes = base64Decode(_transparentPngBase64);

  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
