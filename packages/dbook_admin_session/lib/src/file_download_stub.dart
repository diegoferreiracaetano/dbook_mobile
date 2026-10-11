import 'dart:typed_data';

/// Fora do navegador não há download: devolve `false` (os testes de VM caem
/// aqui).
bool downloadFile({
  required String name,
  required Uint8List bytes,
  String mimeType = 'application/octet-stream',
}) => false;
