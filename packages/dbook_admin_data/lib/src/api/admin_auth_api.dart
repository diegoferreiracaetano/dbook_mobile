import 'package:dio/dio.dart';

import '../json.dart';
import '../models/auth.dart';

/// Sessão do portal (`/v1/admin/auth/*` e `/v1/admin/2fa/*`). O token de
/// acesso volta no corpo e o de renovação vai num cookie `httpOnly` que o
/// navegador guarda e que script nenhum lê.
abstract interface class AdminAuthApi {
  Future<LoginOutcome> login({required String email, required String password});

  Future<String> verifyTwoFactor({
    required String challengeToken,
    required String code,
  });

  Future<TwoFactorEnrollment> enrollWithChallenge(String challengeToken);

  Future<TwoFactorEnrolled> confirmWithChallenge({
    required String challengeToken,
    required String code,
  });

  /// Renova a sessão com o cookie; devolve o novo token de acesso.
  Future<String> refresh();

  Future<void> logout();

  Future<StaffProfile> me();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<AcceptedInvitation> acceptInvitation({
    required String token,
    required String name,
    required String password,
  });

  Future<TwoFactorEnrollment> enrollTwoFactor();

  Future<List<String>> confirmTwoFactor(String code);

  Future<void> disableTwoFactor({
    required String password,
    required String code,
  });
}

class DioAdminAuthApi implements AdminAuthApi {
  const DioAdminAuthApi(this._dio);

  final Dio _dio;

  @override
  Future<LoginOutcome> login({
    required String email,
    required String password,
  }) => guarded(() async {
    final response = await _dio.post<Object>(
      '/admin/auth/login',
      data: {'email': email, 'password': password},
    );
    final body = bodyOf(response);
    if (response.statusCode == 202) {
      return LoginNeedsSecondFactor(
        challengeToken: body.text('challengeToken'),
        enrollmentRequired: body.flag('enrollmentRequired'),
      );
    }
    return LoginSucceeded(body.text('accessToken'));
  });

  @override
  Future<String> verifyTwoFactor({
    required String challengeToken,
    required String code,
  }) => guarded(() async {
    final response = await _dio.post<Object>(
      '/admin/auth/2fa/verify',
      data: {'challengeToken': challengeToken, 'code': code},
    );
    return bodyOf(response).text('accessToken');
  });

  @override
  Future<TwoFactorEnrollment> enrollWithChallenge(String challengeToken) =>
      guarded(() async {
        final response = await _dio.post<Object>(
          '/admin/auth/2fa/enroll',
          data: {'challengeToken': challengeToken},
        );
        return TwoFactorEnrollment.fromJson(bodyOf(response));
      });

  @override
  Future<TwoFactorEnrolled> confirmWithChallenge({
    required String challengeToken,
    required String code,
  }) => guarded(() async {
    final response = await _dio.post<Object>(
      '/admin/auth/2fa/confirm',
      data: {'challengeToken': challengeToken, 'code': code},
    );
    return TwoFactorEnrolled.fromJson(bodyOf(response));
  });

  @override
  Future<String> refresh() => guarded(() async {
    final response = await _dio.post<Object>('/admin/auth/refresh');
    return bodyOf(response).text('accessToken');
  });

  @override
  Future<void> logout() =>
      guarded(() async => _dio.post<Object>('/admin/auth/logout'));

  @override
  Future<StaffProfile> me() => guarded(() async {
    final response = await _dio.get<Object>('/admin/auth/me');
    return StaffProfile.fromJson(bodyOf(response));
  });

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => guarded(
    () async => _dio.post<Object>(
      '/admin/auth/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    ),
  );

  @override
  Future<AcceptedInvitation> acceptInvitation({
    required String token,
    required String name,
    required String password,
  }) => guarded(() async {
    final response = await _dio.post<Object>(
      '/admin/invitations/accept',
      data: {'token': token, 'name': name, 'password': password},
    );
    return AcceptedInvitation.fromJson(bodyOf(response));
  });

  @override
  Future<TwoFactorEnrollment> enrollTwoFactor() => guarded(() async {
    final response = await _dio.post<Object>('/admin/2fa/enroll');
    return TwoFactorEnrollment.fromJson(bodyOf(response));
  });

  @override
  Future<List<String>> confirmTwoFactor(String code) => guarded(() async {
    final response = await _dio.post<Object>(
      '/admin/2fa/confirm',
      data: {'code': code},
    );
    return bodyOf(response).strings('recoveryCodes');
  });

  @override
  Future<void> disableTwoFactor({
    required String password,
    required String code,
  }) => guarded(
    () async => _dio.post<Object>(
      '/admin/2fa/disable',
      data: {'password': password, 'code': code},
    ),
  );
}
