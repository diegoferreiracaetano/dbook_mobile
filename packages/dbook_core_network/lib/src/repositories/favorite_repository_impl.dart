import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../exceptions/dbook_network_exception.dart';
import '../json_read.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  const FavoriteRepositoryImpl(this._dio);

  final Dio _dio;

  static const _pageSize = 100;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<Set<String>> destinations() => _guard(() async {
    final codes = <String>{};
    var page = 0;
    while (true) {
      final response = await _dio.get<Object>(
        '/favorites',
        queryParameters: {
          'type': 'DESTINATION',
          'page': page,
          'size': _pageSize,
        },
      );
      final body = response.data is Map<String, dynamic>
          ? response.data! as Json
          : <String, dynamic>{};
      for (final item in body.list('items', (j) => j)) {
        final id = item.str('id');
        if (id != null) codes.add(id);
      }
      page++;
      if (page >= body.count('totalPages')) break;
    }
    return codes;
  });

  @override
  Future<void> addDestination(String iataCode) => _guard(
    () async =>
        _dio.put<Object>('/favorites/DESTINATION/${iataCode.toUpperCase()}'),
  );

  @override
  Future<void> removeDestination(String iataCode) => _guard(
    () async =>
        _dio.delete<Object>('/favorites/DESTINATION/${iataCode.toUpperCase()}'),
  );
}
