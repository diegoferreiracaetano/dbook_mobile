import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

/// JWT mínimo só para os testes: o portal só lê o `exp`.
String fakeJwt({required DateTime expiresAt}) {
  String part(Map<String, Object?> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final exp = expiresAt.millisecondsSinceEpoch ~/ 1000;
  return '${part({'alg': 'none'})}.${part({'exp': exp})}.sig';
}

const staffProfile = StaffProfile(
  id: 1,
  name: 'Diego',
  email: 'diego@dbook.com',
  role: Role.superAdmin,
  permissions: {Permission.adminPortalAccess, Permission.customerRead},
);

/// Falso escrito à mão do contrato de autenticação do portal.
class FakeAdminAuthApi implements AdminAuthApi {
  LoginOutcome loginOutcome = const LoginSucceeded('token-1');
  Object? loginError;
  Object? refreshError;
  String refreshToken = 'token-refreshed';
  Completer<String>? refreshGate;
  int refreshCalls = 0;
  int logoutCalls = 0;
  Object? meError;
  StaffProfile profile = staffProfile;
  Object? verifyError;
  String? lastVerifyCode;
  bool passwordChanged = false;

  @override
  Future<LoginOutcome> login({
    required String email,
    required String password,
  }) async {
    if (loginError != null) throw loginError!;
    return loginOutcome;
  }

  @override
  Future<String> verifyTwoFactor({
    required String challengeToken,
    required String code,
  }) async {
    lastVerifyCode = code;
    if (verifyError != null) throw verifyError!;
    return 'token-2fa';
  }

  @override
  Future<TwoFactorEnrollment> enrollWithChallenge(
    String challengeToken,
  ) async => const TwoFactorEnrollment(
    otpauthUri: 'otpauth://totp/x',
    manualEntryKey: 'ABCD',
  );

  @override
  Future<TwoFactorEnrolled> confirmWithChallenge({
    required String challengeToken,
    required String code,
  }) async => const TwoFactorEnrolled(
    accessToken: 'token-enrolled',
    recoveryCodes: ['aaaa-bbbb', 'cccc-dddd'],
  );

  @override
  Future<String> refresh() async {
    refreshCalls++;
    if (refreshGate != null) await refreshGate!.future;
    if (refreshError != null) throw refreshError!;
    return refreshToken;
  }

  @override
  Future<void> logout() async => logoutCalls++;

  @override
  Future<StaffProfile> me() async {
    if (meError != null) throw meError!;
    return profile;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async => passwordChanged = true;

  @override
  Future<AcceptedInvitation> acceptInvitation({
    required String token,
    required String name,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<TwoFactorEnrollment> enrollTwoFactor() => throw UnimplementedError();

  @override
  Future<List<String>> confirmTwoFactor(String code) =>
      throw UnimplementedError();

  @override
  Future<void> disableTwoFactor({
    required String password,
    required String code,
  }) => throw UnimplementedError();
}

/// Adaptador HTTP de teste: responde pelo [handler].
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final seen = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    seen.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);
