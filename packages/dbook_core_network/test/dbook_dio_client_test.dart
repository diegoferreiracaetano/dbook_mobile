import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _CapturingInterceptor extends Interceptor {
  Uri? requested;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requested = options.uri;
    handler.resolve(
      Response(requestOptions: options, data: <String, dynamic>{}),
    );
  }
}

void main() {
  test('given a versioned base url when a repository path is requested then '
      'the version stays in front of it', () async {
    final capture = _CapturingInterceptor();
    final dio = DbookDioClient.create(baseUrl: 'http://localhost:8080/v1')
      ..interceptors.add(capture);

    await dio.get<Object>('/bookings');

    expect(capture.requested.toString(), 'http://localhost:8080/v1/bookings');
  });
}
