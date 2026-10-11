import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);

/// Se a API responde, conferido a cada 30 s em `/health` (sem versão, sem
/// token). Começa em "no ar" para a faixa de aviso não piscar na abertura.
final apiReachableProvider = StreamProvider<bool>((ref) async* {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiRoot,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
  ref.onDispose(dio.close);

  Future<bool> check() async {
    try {
      final response = await dio.get<Object>('/health');
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  yield true;
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 30));
    yield await check();
  }
});
