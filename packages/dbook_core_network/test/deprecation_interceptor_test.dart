import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _Replying extends Interceptor {
  _Replying(this.headers);

  final Map<String, List<String>> headers;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.resolve(
      Response(
        requestOptions: options,
        data: <String, dynamic>{},
        headers: Headers.fromMap(headers),
      ),
      true,
    );
  }
}

void main() {
  late void Function(String, String, String?) original;
  late List<String> reported;

  setUp(() {
    original = onDeprecatedEndpoint;
    reported = [];
    onDeprecatedEndpoint = (method, path, sunset) =>
        reported.add('$method $path ${sunset ?? '-'}');
  });
  tearDown(() => onDeprecatedEndpoint = original);

  Dio dio(Map<String, List<String>> headers) =>
      Dio()
        ..interceptors.addAll([DeprecationInterceptor(), _Replying(headers)]);

  test('given a response with Deprecation when called twice then reports the '
      'endpoint once with the sunset date', () async {
    final client = dio({
      'deprecation': ['true'],
      'sunset': ['Wed, 01 Jul 2027 00:00:00 GMT'],
    });

    await client.get<Object>('/old');
    await client.get<Object>('/old');

    expect(reported, ['GET /old Wed, 01 Jul 2027 00:00:00 GMT']);
  });

  test('given a response without Deprecation when called then reports '
      'nothing', () async {
    await dio({}).get<Object>('/fine');

    expect(reported, isEmpty);
  });
}
