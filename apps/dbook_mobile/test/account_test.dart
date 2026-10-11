import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_mobile/account/account_api.dart';
import 'package:dbook_mobile/account/account_pages.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Responde pelo caminho e grava o que foi pedido: prova o contrato do
/// `/v1/users/me` sem servidor.
class _Recorder {
  _Recorder({this.failures = const {}, this.replies = const {}}) {
    dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls.add(options);
          final key = '${options.method} ${options.path}';
          final status = failures[key];
          if (status != null) {
            handler.reject(
              DioException.badResponse(
                statusCode: status,
                requestOptions: options,
                response: Response<Object>(
                  requestOptions: options,
                  statusCode: status,
                  data: {'error': 'Recusado pelo servidor'},
                ),
              ),
            );
            return;
          }
          handler.resolve(
            Response<Object>(
              requestOptions: options,
              statusCode: 200,
              data: replies[key] ?? <String, dynamic>{},
            ),
          );
        },
      ),
    );
  }

  final Map<String, int> failures;
  final Map<String, Object> replies;
  late final Dio dio;
  final calls = <RequestOptions>[];

  Iterable<RequestOptions> to(String method, String path) =>
      calls.where((c) => c.method == method && c.path == path);
}

Widget _host(_Recorder recorder, Widget page) => ProviderScope(
  overrides: [accountApiProvider.overrideWithValue(AccountApi(recorder.dio))],
  child: MaterialApp(theme: DbookTheme.light, home: page),
);

class _DialogLauncher extends ConsumerWidget {
  const _DialogLauncher({required this.open});

  final Future<bool> Function(BuildContext context, WidgetRef ref) open;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: Center(
      child: ElevatedButton(
        onPressed: () => open(context, ref),
        child: const Text('abrir'),
      ),
    ),
  );
}

void main() {
  test('given the server answers when reading the account then it parses the '
      'picture, the date and the preferences', () async {
    final recorder = _Recorder(
      replies: {
        'GET /users/me': {
          'avatarUrl': 'https://cdn.example.com/me.jpg',
          'createdAt': '2026-10-05T02:59:12Z',
        },
        'GET /users/me/preferences': {
          'language': 'pt-BR',
          'homeAirport': 'GRU',
          'cabinClass': 'BUSINESS',
        },
        'GET /users/me/sessions': [
          {'id': 'abc', 'lastActiveAt': '2026-10-10T10:00:00Z'},
        ],
      },
    );
    final api = AccountApi(recorder.dio);

    final me = await api.me();
    final prefs = await api.preferences();
    final sessions = await api.sessions();

    expect(me.avatarUrl, 'https://cdn.example.com/me.jpg');
    expect(me.createdAt?.year, 2026);
    expect(prefs.homeAirport, 'GRU');
    expect(prefs.cabinClass, 'BUSINESS');
    expect(sessions.single.id, 'abc');
  });

  test('given a change when saving the preferences then sends the whole set '
      'and a server refusal becomes the server message', () async {
    final recorder = _Recorder(
      failures: {'PUT /users/me/avatar': 400},
      replies: {
        'PUT /users/me/preferences': {'language': 'en', 'currency': 'USD'},
      },
    );
    final api = AccountApi(recorder.dio);

    final saved = await api.savePreferences(
      const Preferences(language: 'en', currency: 'USD', homeAirport: 'GIG'),
    );
    final body =
        recorder.to('PUT', '/users/me/preferences').single.data
            as Map<String, dynamic>;

    expect(saved.currency, 'USD');
    expect(body['homeAirport'], 'GIG');
    expect(body.containsKey('theme'), isTrue);
    await expectLater(
      api.setAvatar('http://x'),
      throwsA(isA<DbookNetworkException>()),
    );
    await api.setAvatar(null);
    expect(recorder.to('DELETE', '/users/me/avatar'), hasLength(1));
    await api.endSession('abc');
    expect(recorder.to('DELETE', '/users/me/sessions/abc'), hasLength(1));
  });

  testWidgets('given saved preferences when the page opens then shows them '
      'and choosing another one sends it', (tester) async {
    final recorder = _Recorder(
      replies: {
        'GET /users/me/preferences': {
          'homeAirport': 'GRU',
          'cabinClass': 'ECONOMY',
          'currency': 'BRL',
        },
        'PUT /users/me/preferences': {
          'homeAirport': 'GRU',
          'cabinClass': 'BUSINESS',
          'currency': 'BRL',
        },
      },
    );
    await tester.pumpWidget(_host(recorder, const TravelPreferencesPage()));
    await tester.pumpAndSettle();

    expect(find.text('GRU'), findsOneWidget);
    expect(find.text('Econômica'), findsOneWidget);

    await tester.tap(find.text('Econômica'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Executiva').last);
    await tester.pumpAndSettle();

    final sent =
        recorder.to('PUT', '/users/me/preferences').single.data
            as Map<String, dynamic>;
    expect(sent['cabinClass'], 'BUSINESS');
    expect(sent['homeAirport'], 'GRU');
  });

  testWidgets('given the server refuses when saving a preference then it goes '
      'back and shows the reason', (tester) async {
    final recorder = _Recorder(
      failures: {'PUT /users/me/preferences': 400},
      replies: {
        'GET /users/me/preferences': {'cabinClass': 'ECONOMY'},
      },
    );
    await tester.pumpWidget(_host(recorder, const TravelPreferencesPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Econômica'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Executiva').last);
    await tester.pumpAndSettle();

    expect(find.text('Recusado pelo servidor'), findsOneWidget);
    expect(find.text('Econômica'), findsOneWidget);
  });

  testWidgets('given open sessions when ending one then asks the server and '
      'lists again', (tester) async {
    final recorder = _Recorder(
      replies: {
        'GET /users/me/sessions': [
          {'id': 'abc', 'lastActiveAt': '2026-10-10T10:00:00Z'},
        ],
      },
    );
    await tester.pumpWidget(_host(recorder, const DevicesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Sessão aberta'), findsOneWidget);
    await tester.tap(find.text('Encerrar'));
    await tester.pumpAndSettle();

    expect(recorder.to('DELETE', '/users/me/sessions/abc'), hasLength(1));
  });

  testWidgets('given no sessions when the page opens then shows the empty '
      'state', (tester) async {
    final recorder = _Recorder(replies: {'GET /users/me/sessions': <Object>[]});
    await tester.pumpWidget(_host(recorder, const DevicesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum dispositivo'), findsOneWidget);
  });

  testWidgets('given the passwords when saving then posts them, and a refusal '
      'keeps the dialog with the reason', (tester) async {
    final ok = _Recorder();
    await tester.pumpWidget(
      _host(
        ok,
        _DialogLauncher(open: (c, ref) => showChangePasswordDialog(c, ref)),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'senha-antiga-1');
    await tester.enterText(find.byType(TextField).last, 'senha-nova-123');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final sent =
        ok.to('POST', '/users/me/password').single.data as Map<String, dynamic>;
    expect(sent['currentPassword'], 'senha-antiga-1');
    expect(sent['newPassword'], 'senha-nova-123');

    final refused = _Recorder(failures: {'POST /users/me/password': 401});
    await tester.pumpWidget(
      _host(
        refused,
        _DialogLauncher(open: (c, ref) => showChangePasswordDialog(c, ref)),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'errada');
    await tester.enterText(find.byType(TextField).last, 'senha-nova-123');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Recusado pelo servidor'), findsOneWidget);
  });

  testWidgets('given a picture url when saving or removing then calls the '
      'right endpoint', (tester) async {
    final recorder = _Recorder();
    await tester.pumpWidget(
      _host(
        recorder,
        _DialogLauncher(
          open: (c, ref) => showAvatarDialog(
            c,
            ref,
            currentUrl: 'https://cdn.example.com/old.jpg',
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'https://cdn.example.com/new.jpg',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final put =
        recorder.to('PUT', '/users/me/avatar').single.data
            as Map<String, dynamic>;
    expect(put['avatarUrl'], 'https://cdn.example.com/new.jpg');

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover foto'));
    await tester.pumpAndSettle();

    expect(recorder.to('DELETE', '/users/me/avatar'), hasLength(1));
  });
}
