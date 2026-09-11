import 'package:flutter/material.dart';

import 'dbook_button.dart';

/// Dialog de confirmação padrão (título + mensagem + ações cancelar/
/// confirmar) — retorna `true` se confirmado, `false` caso contrário
/// (incluindo fechar tocando fora). Visual vem de `dialogTheme`.
Future<bool> showDbookConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        DbookButton(
          label: confirmLabel,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  return result ?? false;
}
