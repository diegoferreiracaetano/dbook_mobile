import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _FakeResponseInterceptor extends Interceptor {
  _FakeResponseInterceptor({this.data});

  final Object? data;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.resolve(Response(requestOptions: options, data: data));
  }
}

void main() {
  test(
    'given a successful destinations response when called then maps every '
    'destination',
    () async {
      final dio = Dio()
        ..interceptors.add(
          _FakeResponseInterceptor(
            data: [
              {
                'iataCode': 'GIG',
                'city': 'Rio de Janeiro',
                'country': 'Brasil',
                'photoUrl': 'https://example.com/gig.jpg',
                'region': 'América do Sul',
                'isPopular': true,
                'lowestPrice': 305.0,
              },
              {
                'iataCode': 'LHR',
                'city': 'Londres',
                'country': 'Reino Unido',
                'photoUrl': 'https://example.com/lhr.jpg',
                'region': 'Europa',
                'isPopular': false,
                'lowestPrice': null,
              },
            ],
          ),
        );
      final repository = DestinationRepositoryImpl(dio);

      final destinations = await repository.getFeaturedDestinations();

      expect(destinations, hasLength(2));
      expect(destinations[0].iataCode, 'GIG');
      expect(destinations[0].lowestPrice, 305.0);
      expect(destinations[1].iataCode, 'LHR');
      expect(destinations[1].lowestPrice, isNull);
    },
  );
}
