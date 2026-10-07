import 'package:flutter/material.dart';

import 'dbook_button.dart';

/// Gravidade da ação a confirmar.
enum DbookConfirmLevel {
  /// Ação comum e reversível.
  simple,

  /// Ação que não se desfaz fácil (bloquear, cancelar): botão em vermelho.
  destructive,

  /// Ação grave e irreversível (apagar dados de um cliente): o usuário
  /// precisa **digitar a frase** de confirmação para liberar o botão.
  typedPhrase,
}

/// Dialog de confirmação padrão (título + mensagem + ações cancelar/
/// confirmar) — retorna `true` se confirmado, `false` caso contrário
/// (incluindo fechar tocando fora). Visual vem de `dialogTheme`.
///
/// Em [DbookConfirmLevel.typedPhrase], [confirmationPhrase] é obrigatória e o
/// botão só habilita quando o texto digitado é igual a ela.
Future<bool> showDbookConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  DbookConfirmLevel level = DbookConfirmLevel.simple,
  String? confirmationPhrase,
}) async {
  assert(
    level != DbookConfirmLevel.typedPhrase || confirmationPhrase != null,
    'typedPhrase needs a confirmationPhrase',
  );

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _ConfirmationDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      level: level,
      phrase: confirmationPhrase,
    ),
  );

  return result ?? false;
}

class _ConfirmationDialog extends StatefulWidget {
  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.level,
    required this.phrase,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final DbookConfirmLevel level;
  final String? phrase;

  @override
  State<_ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<_ConfirmationDialog> {
  final _typed = TextEditingController();

  bool get _canConfirm =>
      widget.level != DbookConfirmLevel.typedPhrase ||
      _typed.text == widget.phrase;

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final destructive = widget.level != DbookConfirmLevel.simple;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          if (widget.level == DbookConfirmLevel.typedPhrase) ...[
            const SizedBox(height: 16),
            Text('Digite "${widget.phrase}" para confirmar'),
            const SizedBox(height: 8),
            TextField(
              controller: _typed,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(isDense: true),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(widget.cancelLabel),
        ),
        if (destructive)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: _canConfirm
                ? () => Navigator.of(context).pop(true)
                : null,
            child: Text(widget.confirmLabel),
          )
        else
          DbookButton(
            label: widget.confirmLabel,
            onPressed: () => Navigator.of(context).pop(true),
          ),
      ],
    );
  }
}
