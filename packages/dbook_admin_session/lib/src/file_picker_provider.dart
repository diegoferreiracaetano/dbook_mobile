import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'file_picker.dart';

/// O seletor de arquivo de texto, como provider, para o teste poder entregar
/// um arquivo sem navegador. No app é o seletor real do navegador.
final textFilePickerProvider = Provider<Future<PickedTextFile?> Function()>(
  (ref) => pickTextFile,
);
