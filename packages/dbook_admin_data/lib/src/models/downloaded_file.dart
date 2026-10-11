import 'dart:typed_data';

/// Um arquivo que o servidor mandou para baixar (exportação CSV).
class DownloadedFile {
  const DownloadedFile({
    required this.name,
    required this.bytes,
    this.mimeType = 'text/csv',
  });

  final String name;
  final Uint8List bytes;
  final String mimeType;
}
