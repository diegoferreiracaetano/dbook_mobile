import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Um arquivo de texto escolhido pela pessoa.
class PickedTextFile {
  const PickedTextFile({required this.name, required this.content});

  final String name;
  final String content;
}

/// Abre o seletor de arquivo do navegador e lê o arquivo escolhido como
/// texto. `null` se a pessoa cancela.
Future<PickedTextFile?> pickTextFile({String accept = '.csv,text/csv'}) {
  final completer = Completer<PickedTextFile?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = accept;

  input.addEventListener(
    'change',
    (web.Event _) {
      final file = input.files?.item(0);
      if (file == null) {
        completer.complete(null);
        return;
      }
      file.text().toDart.then((content) {
        completer.complete(
          PickedTextFile(name: file.name, content: content.toDart),
        );
      });
    }.toJS,
  );
  input.addEventListener(
    'cancel',
    (web.Event _) {
      if (!completer.isCompleted) completer.complete(null);
    }.toJS,
  );
  input.click();
  return completer.future;
}
