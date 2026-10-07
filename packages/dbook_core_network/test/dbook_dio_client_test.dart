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

  test('given an app identity when a request is made then both headers are '
      'sent', () async {
    late Map<String, dynamic> sent;
    final dio =
        DbookDioClient.create(
            baseUrl: 'http://localhost:8080/v1',
            appClient: const AppClientInfo(
              version: '1.4.2+17',
              platform: 'ios',
            ),
          )
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                sent = options.headers;
                handler.resolve(
                  Response(requestOptions: options, data: <String, dynamic>{}),
                );
              },
            ),
          );

    await dio.get<Object>('/bookings');

    expect(sent['X-App-Version'], '1.4.2+17');
    expect(sent['X-App-Platform'], 'ios');
  });

  test('given no app identity when a request is made then it says unknown', () {
    final dio = DbookDioClient.create(baseUrl: 'http://localhost:8080/v1');

    expect(dio.options.headers['X-App-Version'], 'unknown');
    expect(dio.options.headers['X-App-Platform'], 'unknown');
  });
}
