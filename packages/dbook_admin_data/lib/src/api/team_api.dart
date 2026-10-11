import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../json.dart';
import '../models/team.dart';

/// Equipe e convites (`/v1/admin/staff` e `/v1/admin/invitations`, permissão
/// `ADMIN_MANAGE`).
abstract interface class TeamApi {
  Future<List<StaffMember>> listStaff();

  Future<List<Invitation>> listInvitations();

  Future<Invitation> invite({required String email, required Role role});

  Future<void> resendInvitation(int id);

  Future<void> revokeInvitation(int id);

  Future<StaffMember> changeRole({required int id, required Role role});

  Future<StaffMember> block({required int id, required String reason});

  Future<StaffMember> unblock(int id);
}

class DioTeamApi implements TeamApi {
  const DioTeamApi(this._dio);

  final Dio _dio;

  @override
  Future<List<StaffMember>> listStaff() => guarded(() async {
    final response = await _dio.get<Object>('/admin/staff');
    return _list(response, StaffMember.fromJson);
  });

  @override
  Future<List<Invitation>> listInvitations() => guarded(() async {
    final response = await _dio.get<Object>('/admin/invitations');
    return _list(response, Invitation.fromJson);
  });

  @override
  Future<Invitation> invite({required String email, required Role role}) =>
      guarded(() async {
        final response = await _dio.post<Object>(
          '/admin/invitations',
          data: {'email': email, 'role': roleToWire(role)},
        );
        return Invitation.fromJson(bodyOf(response));
      });

  @override
  Future<void> resendInvitation(int id) =>
      guarded(() async => _dio.post<Object>('/admin/invitations/$id/resend'));

  @override
  Future<void> revokeInvitation(int id) =>
      guarded(() async => _dio.delete<Object>('/admin/invitations/$id'));

  @override
  Future<StaffMember> changeRole({required int id, required Role role}) =>
      guarded(() async {
        final response = await _dio.patch<Object>(
          '/admin/staff/$id/role',
          data: {'role': roleToWire(role)},
        );
        return StaffMember.fromJson(bodyOf(response));
      });

  @override
  Future<StaffMember> block({required int id, required String reason}) =>
      guarded(() async {
        final response = await _dio.post<Object>(
          '/admin/staff/$id/block',
          data: {'reason': reason},
        );
        return StaffMember.fromJson(bodyOf(response));
      });

  @override
  Future<StaffMember> unblock(int id) => guarded(() async {
    final response = await _dio.post<Object>('/admin/staff/$id/unblock');
    return StaffMember.fromJson(bodyOf(response));
  });

  List<T> _list<T>(Response<Object> response, T Function(Json) parse) {
    final data = response.data;
    if (data is! List) return const [];
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) parse(item),
    ];
  }
}
