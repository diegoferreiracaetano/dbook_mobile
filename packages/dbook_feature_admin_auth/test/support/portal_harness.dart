import 'dart:convert';
import 'dart:io';

import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// Respostas reais do backend (copiadas de `dbook_admin_data/test/fixtures`),
/// servidas no lugar da rede: a tela roda com a API de verdade (`DioXxxApi`) e
/// só o transporte é falso.
Dio fixtureDio(Map<String, String> byPath) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final name = byPath[options.path];
        if (name == null) {
          handler.reject(
            DioException(requestOptions: options, message: options.path),
          );
          return;
        }
        handler.resolve(
          Response<Object>(
            requestOptions: options,
            statusCode: 200,
            data: jsonDecode(
              File('test/fixtures/$name.json').readAsStringSync(),
            ) as Object,
          ),
        );
      },
    ),
  );
  return dio;
}

final _everything = StaffProfile(
  id: 1,
  name: 'Admin',
  email: 'admin@dbook.test',
  role: Role.superAdmin,
  permissions: Permission.values.toSet(),
);

Future<void> pumpPortal(
  WidgetTester tester, {
  required Dio dio,
  required Widget child,
  List<Override> overrides = const [],
  StaffProfile? profile,
}) async {
  await PortalFormats.init();
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        adminDioProvider.overrideWithValue(dio),
        staffProfileProvider.overrideWithValue(profile ?? _everything),
        ...overrides,
      ],
      child: MaterialApp(
        theme: DbookTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Dio que **grava** toda chamada e responde `{}` (ou o corpo dado em
/// [replies], por "MÉTODO caminho"). Serve para provar o que a tela manda ao
/// servidor sem escrever um falso de cada API.
class RecordingDio {
  RecordingDio({
    Map<String, Object> replies = const {},
    Map<String, int> statuses = const {},
    Map<String, ({int status, Object body})> failures = const {},
  }) {
    dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls.add(options);
          final failure = failures['${options.method} ${options.path}'];
          if (failure != null) {
            handler.reject(
              DioException.badResponse(
                statusCode: failure.status,
                requestOptions: options,
                response: Response<Object>(
                  requestOptions: options,
                  statusCode: failure.status,
                  data: failure.body,
                ),
              ),
            );
            return;
          }
          handler.resolve(
            Response<Object>(
              requestOptions: options,
              statusCode: statuses['${options.method} ${options.path}'] ?? 200,
              data:
                  replies['${options.method} ${options.path}'] ??
                  replies[options.path] ??
                  <String, dynamic>{},
            ),
          );
        },
      ),
    );
  }

  late final Dio dio;
  final calls = <RequestOptions>[];

  Iterable<RequestOptions> to(String method, String path) =>
      calls.where((c) => c.method == method && c.path == path);
}
