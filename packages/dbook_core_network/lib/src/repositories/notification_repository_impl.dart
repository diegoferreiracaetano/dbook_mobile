import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../exceptions/dbook_network_exception.dart';
import '../json_read.dart';
import '../wire_enums.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._dio);

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

  static AppNotification _notification(Json json) => AppNotification(
    id: json.count('id'),
    type: notificationTypeFromWire(json.text('type')),
    title: json.text('title'),
    body: json.text('body'),
    read: json.flag('read'),
    createdAt: json.time('createdAt') ?? DateTime.fromMillisecondsSinceEpoch(0),
    data: json.obj('data') ?? const {},
  );

  static List<NotificationPreference> _preferences(Object? data) {
    if (data is! List) return const [];
    return [
      for (final item in data)
        if (item is Map<String, dynamic>)
          if (notificationChannelFromWire(item.text('channel'))
              case final channel?)
            NotificationPreference(
              type: notificationTypeFromWire(item.text('type')),
              channel: channel,
              enabled: item.flag('enabled', fallback: true),
            ),
    ];
  }

  @override
  Future<NotificationPage> list({
    String? cursor,
    int size = 20,
    bool unreadOnly = false,
  }) => _guard(() async {
    final response = await _dio.get<Object>(
      '/notifications',
      queryParameters: {
        'size': size,
        'unreadOnly': unreadOnly,
        'cursor': ?cursor,
      },
    );
    final body = _body(response);
    return NotificationPage(
      items: body.list('items', _notification),
      nextCursor: body.str('nextCursor'),
    );
  });

  @override
  Future<int> unreadCount() => _guard(() async {
    final response = await _dio.get<Object>('/notifications/unread-count');
    return _body(response).count('count');
  });

  @override
  Future<void> markRead(int id) =>
      _guard(() async => _dio.post<Object>('/notifications/$id/read'));

  @override
  Future<void> markAllRead() =>
      _guard(() async => _dio.post<Object>('/notifications/read-all'));

  @override
  Future<List<NotificationPreference>> preferences() => _guard(() async {
    final response = await _dio.get<Object>('/notifications/preferences');
    return _preferences(response.data);
  });

  @override
  Future<List<NotificationPreference>> updatePreferences(
    List<NotificationPreference> changes,
  ) => _guard(() async {
    final response = await _dio.put<Object>(
      '/notifications/preferences',
      data: [
        for (final change in changes)
          {
            'type': notificationTypeToWire(change.type),
            'channel': notificationChannelToWire(change.channel),
            'enabled': change.enabled,
          },
      ],
    );
    return _preferences(response.data);
  });

  @override
  Future<void> registerDevice({
    required String token,
    required String platform,
  }) => _guard(
    () async => _dio.post<Object>(
      '/notifications/devices',
      data: {'token': token, 'platform': platform.toUpperCase()},
    ),
  );

  @override
  Future<void> unregisterDevice(String token) => _guard(
    () async => _dio.delete<Object>(
      '/notifications/devices/${Uri.encodeComponent(token)}',
    ),
  );
}
