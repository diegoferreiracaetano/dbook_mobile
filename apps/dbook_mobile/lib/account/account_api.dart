import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// O que o servidor guarda sobre a conta do cliente, além do nome: foto,
/// "membro desde" e preferências. Mora no app (e não numa feature) porque só
/// o Perfil usa; os nomes dos campos são os do `/v1/users/me`.
class AccountApi {
  const AccountApi(this._dio);

  final Dio _dio;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  static Map<String, dynamic> _map(Response<Object> response) =>
      response.data is Map<String, dynamic>
      ? response.data! as Map<String, dynamic>
      : <String, dynamic>{};

  Future<AccountSummary> me() => _guard(() async {
    final map = _map(await _dio.get<Object>('/users/me'));
    return AccountSummary(
      avatarUrl: map['avatarUrl'] as String?,
      createdAt: DateTime.tryParse('${map['createdAt'] ?? ''}'),
    );
  });

  Future<Preferences> preferences() => _guard(() async {
    return Preferences.fromJson(
      _map(await _dio.get<Object>('/users/me/preferences')),
    );
  });

  Future<Preferences> savePreferences(Preferences preferences) =>
      _guard(() async {
        return Preferences.fromJson(
          _map(
            await _dio.put<Object>(
              '/users/me/preferences',
              data: preferences.toJson(),
            ),
          ),
        );
      });

  Future<void> setAvatar(String? url) => _guard(() async {
    if (url == null) {
      await _dio.delete<Object>('/users/me/avatar');
    } else {
      await _dio.put<Object>('/users/me/avatar', data: {'avatarUrl': url});
    }
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _guard(() async {
    await _dio.post<Object>(
      '/users/me/password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  });

  Future<List<DeviceSession>> sessions() => _guard(() async {
    final response = await _dio.get<Object>('/users/me/sessions');
    final list = response.data is List ? response.data! as List : const [];
    return [
      for (final item in list.whereType<Map<String, dynamic>>())
        DeviceSession(
          id: '${item['id']}',
          lastActiveAt: DateTime.tryParse('${item['lastActiveAt'] ?? ''}'),
        ),
    ];
  });

  Future<void> endSession(String id) => _guard(() async {
    await _dio.delete<Object>('/users/me/sessions/$id');
  });
}

class AccountSummary {
  const AccountSummary({this.avatarUrl, this.createdAt});

  final String? avatarUrl;
  final DateTime? createdAt;
}

class DeviceSession {
  const DeviceSession({required this.id, this.lastActiveAt});

  final String id;
  final DateTime? lastActiveAt;
}

/// As preferências guardadas no servidor. Tudo é opcional: `null` é "sem
/// escolha" e o app usa o padrão dele. O servidor substitui o conjunto
/// inteiro a cada gravação, por isso o app sempre manda todas.
class Preferences {
  const Preferences({
    this.language,
    this.theme,
    this.homeAirport,
    this.country,
    this.currency,
    this.cabinClass,
    this.seatPreference,
    this.dateFormat,
    this.distanceUnit,
  });

  factory Preferences.fromJson(Map<String, dynamic> json) => Preferences(
    language: json['language'] as String?,
    theme: json['theme'] as String?,
    homeAirport: json['homeAirport'] as String?,
    country: json['country'] as String?,
    currency: json['currency'] as String?,
    cabinClass: json['cabinClass'] as String?,
    seatPreference: json['seatPreference'] as String?,
    dateFormat: json['dateFormat'] as String?,
    distanceUnit: json['distanceUnit'] as String?,
  );

  final String? language;
  final String? theme;
  final String? homeAirport;
  final String? country;
  final String? currency;
  final String? cabinClass;
  final String? seatPreference;
  final String? dateFormat;
  final String? distanceUnit;

  Preferences copyWith({
    String? Function()? language,
    String? Function()? theme,
    String? Function()? homeAirport,
    String? Function()? currency,
    String? Function()? cabinClass,
    String? Function()? seatPreference,
  }) => Preferences(
    language: language != null ? language() : this.language,
    theme: theme != null ? theme() : this.theme,
    homeAirport: homeAirport != null ? homeAirport() : this.homeAirport,
    country: country,
    currency: currency != null ? currency() : this.currency,
    cabinClass: cabinClass != null ? cabinClass() : this.cabinClass,
    seatPreference: seatPreference != null
        ? seatPreference()
        : this.seatPreference,
    dateFormat: dateFormat,
    distanceUnit: distanceUnit,
  );

  Map<String, dynamic> toJson() => {
    'language': language,
    'theme': theme,
    'homeAirport': homeAirport,
    'country': country,
    'currency': currency,
    'cabinClass': cabinClass,
    'seatPreference': seatPreference,
    'dateFormat': dateFormat,
    'distanceUnit': distanceUnit,
  };
}

final accountApiProvider = Provider<AccountApi>(
  (ref) => AccountApi(ref.watch(dioProvider)),
);

final accountSummaryProvider = FutureProvider.autoDispose<AccountSummary>(
  (ref) => ref.watch(accountApiProvider).me(),
);

final preferencesProvider = FutureProvider.autoDispose<Preferences>(
  (ref) => ref.watch(accountApiProvider).preferences(),
);

final sessionsProvider = FutureProvider.autoDispose<List<DeviceSession>>(
  (ref) => ref.watch(accountApiProvider).sessions(),
);
