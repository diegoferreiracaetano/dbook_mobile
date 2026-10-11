import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../exceptions/dbook_network_exception.dart';
import '../json_read.dart';

class AppConfigRepositoryImpl implements AppConfigRepository {
  const AppConfigRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<AppConfig> fetch() async {
    try {
      final response = await _dio.get<Object>('/app-config');
      final body = response.data is Map<String, dynamic>
          ? response.data! as Json
          : <String, dynamic>{};
      return AppConfig(
        android: _release(body.obj('android')),
        ios: _release(body.obj('ios')),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  AppRelease? _release(Json? json) {
    if (json == null) return null;
    final min = json.str('minSupportedVersion');
    final latest = json.str('latestVersion');
    if (min == null || latest == null) return null;
    return AppRelease(
      minSupportedVersion: min,
      latestVersion: latest,
      storeUrl: json.text('storeUrl'),
    );
  }
}
