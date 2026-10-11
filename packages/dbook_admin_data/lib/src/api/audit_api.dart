import 'package:dio/dio.dart';

import '../json.dart';
import '../models/audit.dart';
import '../models/pages.dart';

abstract interface class AuditApi {
  Future<CursorPage<AuditEntry>> search(AuditQuery query);
}

class DioAuditApi implements AuditApi {
  const DioAuditApi(this._dio);

  final Dio _dio;

  @override
  Future<CursorPage<AuditEntry>> search(AuditQuery query) => guarded(() async {
    final response = await _dio.get<Object>(
      '/admin/audit',
      queryParameters: compact({
        'actorId': query.actorId,
        'action': query.action,
        'targetType': query.targetType,
        'targetId': query.targetId,
        'outcome': query.outcome,
        'from': query.from?.toUtc().toIso8601String(),
        'to': query.to?.toUtc().toIso8601String(),
        'cursor': query.cursor,
        'size': query.size,
      }),
    );
    return CursorPage.fromJson(bodyOf(response), AuditEntry.fromJson);
  });
}
