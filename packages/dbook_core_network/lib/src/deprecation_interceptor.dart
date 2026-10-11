import 'package:dio/dio.dart';

/// Chamado uma vez por endpoint obsoleto que o servidor ainda atende (resposta
/// com o cabeçalho `Deprecation`). O `main` de cada app liga isto ao registro
/// de erros; por padrão só escreve no console **em debug** (asserts não rodam
/// em produção).
void Function(String method, String path, String? sunset) onDeprecatedEndpoint =
    (method, path, sunset) {
      assert(() {
        // ignore: avoid_print
        print(
          '[dbook] endpoint obsoleto: $method $path'
          '${sunset == null ? '' : ' (sai do ar em $sunset)'}',
        );
        return true;
      }());
    };

/// Lê `Deprecation`/`Sunset` de toda resposta e avisa [onDeprecatedEndpoint]
/// **uma vez** por método e caminho (não por chamada), para um endpoint
/// obsoleto aparecer no registro antes de sair do ar sem inundá-lo.
class DeprecationInterceptor extends Interceptor {
  final _seen = <String>{};

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final deprecation = response.headers.value('deprecation');
    if (deprecation != null) {
      final key =
          '${response.requestOptions.method} ${response.requestOptions.path}';
      if (_seen.add(key)) {
        onDeprecatedEndpoint(
          response.requestOptions.method,
          response.requestOptions.path,
          response.headers.value('sunset'),
        );
      }
    }
    handler.next(response);
  }
}
