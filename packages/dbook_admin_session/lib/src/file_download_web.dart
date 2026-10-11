import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Salva [bytes] como arquivo pelo navegador (Blob + link temporário).
bool downloadFile({
  required String name,
  required Uint8List bytes,
  String mimeType = 'application/octet-stream',
}) {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = name;
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return true;
}
