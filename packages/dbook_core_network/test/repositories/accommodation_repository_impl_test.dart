import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _Replying extends Interceptor {
  _Replying(this.data, {this.statusCode = 200});

  final Object? data;
  final int statusCode;
  RequestOptions? captured;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    captured = options;
    handler.resolve(
      Response(requestOptions: options, data: data, statusCode: statusCode),
    );
  }
}

AccommodationRepositoryImpl _repository(_Replying replying) =>
    AccommodationRepositoryImpl(Dio()..interceptors.add(replying));

void main() {
  test('given a search when searching then sends destination, dates and '
      'guests and reads rooms with the stay total', () async {
    final replying = _Replying({
      'items': [
        {
          'id': 7,
          'name': 'Hotel Copacabana',
          'destinationIataCode': 'GIG',
          'city': 'Rio de Janeiro',
          'address': 'Av. Atlântica, 1000',
          'stars': 4,
          'amenities': ['wifi', 'pool'],
          'averageRating': 4.5,
          'reviewCount': 12,
          'fromPrice': 1050.0,
          'rooms': [
            {
              'roomTypeId': 3,
              'name': 'Double',
              'capacity': 2,
              'nightlyRate': 350.0,
              'totalPrice': 1050.0,
            },
          ],
        },
      ],
    });

    final results = await _repository(replying).search(
      StaySearch(
        destination: 'GIG',
        checkIn: DateTime(2027, 1, 15),
        checkOut: DateTime(2027, 1, 18),
        guests: 2,
      ),
    );

    expect(replying.captured!.path, '/accommodations/search');
    expect(replying.captured!.queryParameters['checkIn'], '2027-01-15');
    expect(replying.captured!.queryParameters['checkOut'], '2027-01-18');
    expect(replying.captured!.queryParameters['guests'], 2);
    expect(results.single.name, 'Hotel Copacabana');
    expect(results.single.amenities, ['wifi', 'pool']);
    expect(results.single.rooms.single.totalPrice, 1050);
  });

  test('given a room when booking then posts the stay and returns the '
      'booking id', () async {
    final replying = _Replying({'id': 91}, statusCode: 201);

    final id = await _repository(replying).book(
      accommodationId: 7,
      roomTypeId: 3,
      checkIn: DateTime(2027, 1, 15),
      checkOut: DateTime(2027, 1, 18),
      guests: 2,
    );

    expect(id, 91);
    expect(replying.captured!.path, '/accommodations/7/bookings');
    expect(replying.captured!.data, {
      'roomTypeId': 3,
      'checkIn': '2027-01-15',
      'checkOut': '2027-01-18',
      'guests': 2,
    });
  });

  test('given a bookings list with a flight and a stay when listing stays '
      'then only the stay comes back', () async {
    final replying = _Replying([
      {'id': 1, 'status': 'CONFIRMED', 'flight': {}, 'seat': {}},
      {
        'id': 2,
        'status': 'PENDING',
        'price': 1050.0,
        'seat': null,
        'flight': null,
        'stay': {
          'checkIn': '2027-01-15',
          'checkOut': '2027-01-18',
          'nights': 3,
          'guests': 2,
        },
        'accommodation': {'id': 7, 'name': 'Hotel Copacabana', 'city': 'Rio'},
      },
    ]);

    final stays = await _repository(replying).myStays();

    expect(stays, hasLength(1));
    expect(stays.single.bookingId, 2);
    expect(stays.single.nights, 3);
    expect(stays.single.hotelName, 'Hotel Copacabana');
  });

  test('given a stay in the bookings list when listing flights then it is '
      'skipped instead of breaking the list', () async {
    final replying = _Replying([
      {
        'id': 2,
        'status': 'PENDING',
        'seat': null,
        'flight': null,
        'stay': {'nights': 3},
      },
    ]);

    final mine = await BookingRepositoryImpl(Dio()..interceptors.add(replying))
        .listMine();

    expect(mine, isEmpty);
  });

  test('given the same search values when comparing then they are equal and '
      'count the nights', () {
    final a = StaySearch(
      destination: 'LIS',
      checkIn: DateTime(2027, 3, 1),
      checkOut: DateTime(2027, 3, 4),
      guests: 2,
    );
    final b = StaySearch(
      destination: 'LIS',
      checkIn: DateTime(2027, 3, 1),
      checkOut: DateTime(2027, 3, 4),
      guests: 2,
    );

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a.nights, 3);
  });
}
