import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _Replying extends Interceptor {
  _Replying(this.statusCode, this.data);

  final int statusCode;
  final Object? data;
  RequestOptions? captured;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    captured = options;
    final response = Response<Object>(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
    );
    if (statusCode >= 400) {
      handler.reject(
        DioException.badResponse(
          statusCode: statusCode,
          requestOptions: options,
          response: response,
        ),
      );
    } else {
      handler.resolve(response);
    }
  }
}

DioAdminAuthApi _api(_Replying replying) =>
    DioAdminAuthApi(Dio()..interceptors.add(replying));

void main() {
  test('given a 200 when logging in then returns the access token', () async {
    final replying = _Replying(200, {'accessToken': 'tok'});

    final outcome = await _api(replying).login(email: 'a@b.c', password: 'x');

    expect(outcome, isA<LoginSucceeded>());
    expect((outcome as LoginSucceeded).accessToken, 'tok');
    expect(replying.captured!.path, '/admin/auth/login');
  });

  test('given a 202 when logging in then asks for the second factor', () async {
    final replying = _Replying(202, {
      'challengeToken': 'ch',
      'enrollmentRequired': true,
    });

    final outcome = await _api(replying).login(email: 'a@b.c', password: 'x');

    final second = outcome as LoginNeedsSecondFactor;
    expect(second.challengeToken, 'ch');
    expect(second.enrollmentRequired, isTrue);
  });

  test('given a 401 with a code when logging in then throws the typed error '
      'with that code', () async {
    final replying = _Replying(401, {
      'error': 'Credenciais inválidas',
      'code': 'INVALID_CREDENTIALS',
    });

    await expectLater(
      _api(replying).login(email: 'a@b.c', password: 'x'),
      throwsA(
        isA<DbookNetworkException>().having(
          (e) => e.code,
          'code',
          'INVALID_CREDENTIALS',
        ),
      ),
    );
  });

  test('given a profile with missing and wrong typed fields when parsing '
      'then falls back instead of throwing', () {
    final profile = StaffProfile.fromJson({
      'id': 4,
      'name': null,
      'email': 'a@b.c',
      'role': 'SUPPORT',
      'permissions': ['CUSTOMER_READ', 42, 'NOT_A_PERMISSION'],
      'twoFactorEnabled': 'yes',
    });

    expect(profile.id, 4);
    expect(profile.name, '');
    expect(profile.twoFactorEnabled, isFalse);
    expect(profile.mustChangePassword, isFalse);
  });

  test('given a page payload when parsing then reads items and counters', () {
    final page = PageOf<int>.fromJson({
      'items': [
        {'v': 1},
        {'v': 2},
        'ignored',
      ],
      'page': 1,
      'totalElements': 42,
      'totalPages': 3,
    }, (j) => j['v']! as int);

    expect(page.items, [1, 2]);
    expect(page.size, 20);
    expect(page.totalPages, 3);
  });

  test('given a cursor page without next when parsing then has no more', () {
    final page = CursorPage<int>.fromJson({'items': []}, (j) => 0);

    expect(page.hasMore, isFalse);
  });
}
