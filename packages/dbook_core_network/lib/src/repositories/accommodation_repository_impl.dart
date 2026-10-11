import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../exceptions/dbook_network_exception.dart';
import '../json_read.dart';

class AccommodationRepositoryImpl implements AccommodationRepository {
  const AccommodationRepositoryImpl(this._dio);

  final Dio _dio;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  static Json _body(Response<Object> response) =>
      response.data is Map<String, dynamic>
      ? response.data! as Json
      : <String, dynamic>{};

  static String _day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static RoomOffer _offer(Json j) => RoomOffer(
    roomTypeId: j.count('roomTypeId'),
    name: j.text('name'),
    capacity: j.count('capacity'),
    nightlyRate: j.decimal('nightlyRate') ?? 0,
    totalPrice: j.decimal('totalPrice') ?? 0,
  );

  static AccommodationResult _result(Json j) => AccommodationResult(
    id: j.count('id'),
    name: j.text('name'),
    city: j.text('city'),
    destinationIataCode: j.text('destinationIataCode'),
    address: j.text('address'),
    stars: j.count('stars'),
    amenities: j.strings('amenities'),
    rooms: j.list('rooms', _offer),
    photoUrl: j.str('photoUrl'),
    averageRating: j.decimal('averageRating'),
    reviewCount: j.count('reviewCount'),
    fromPrice: j.decimal('fromPrice'),
  );

  @override
  Future<List<AccommodationResult>> search(StaySearch search) =>
      _guard(() async {
        final response = await _dio.get<Object>(
          '/accommodations/search',
          queryParameters: {
            'destination': search.destination,
            'checkIn': _day(search.checkIn),
            'checkOut': _day(search.checkOut),
            'guests': search.guests,
            'page': 0,
            'size': 50,
          },
        );
        return _body(response).list('items', _result);
      });

  @override
  Future<AccommodationDetail> detail(int id) => _guard(() async {
    final j = _body(await _dio.get<Object>('/accommodations/$id'));
    return AccommodationDetail(
      id: j.count('id'),
      name: j.text('name'),
      city: j.text('city'),
      destinationIataCode: j.text('destinationIataCode'),
      address: j.text('address'),
      stars: j.count('stars'),
      amenities: j.strings('amenities'),
      description: j.str('description'),
      photoUrl: j.str('photoUrl'),
      roomTypes: j.list(
        'roomTypes',
        (r) => RoomType(
          id: r.count('id'),
          name: r.text('name'),
          capacity: r.count('capacity'),
          nightlyRate: r.decimal('nightlyRate') ?? 0,
        ),
      ),
    );
  });

  @override
  Future<int> book({
    required int accommodationId,
    required int roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) => _guard(() async {
    final response = await _dio.post<Object>(
      '/accommodations/$accommodationId/bookings',
      data: {
        'roomTypeId': roomTypeId,
        'checkIn': _day(checkIn),
        'checkOut': _day(checkOut),
        'guests': guests,
      },
    );
    return _body(response).count('id');
  });

  @override
  Future<List<StayBooking>> myStays() => _guard(() async {
    final response = await _dio.get<Object>('/bookings');
    final data = response.data;
    if (data is! List) return const [];
    return [
      for (final item in data)
        if (item is Map<String, dynamic> &&
            item['stay'] is Map<String, dynamic> &&
            item['accommodation'] is Map<String, dynamic>)
          _stay(item),
    ];
  });

  static StayBooking _stay(Json item) {
    final stay = item.obj('stay')!;
    final hotel = item.obj('accommodation')!;
    return StayBooking(
      bookingId: item.count('id'),
      status: item.text('status'),
      hotelName: hotel.text('name'),
      city: hotel.text('city'),
      checkIn: DateTime.tryParse(stay.text('checkIn')) ?? DateTime(1970),
      checkOut: DateTime.tryParse(stay.text('checkOut')) ?? DateTime(1970),
      nights: stay.count('nights'),
      guests: stay.count('guests'),
      price: item.decimal('price') ?? 0,
    );
  }
}
