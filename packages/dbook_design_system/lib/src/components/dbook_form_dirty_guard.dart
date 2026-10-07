import 'package:flutter/material.dart';

import 'dbook_confirmation_dialog.dart';

/// Protege um formulário com alterações não salvas: enquanto [isDirty], sair
/// da tela (voltar, gesto, botão do navegador) pergunta antes de descartar.
/// Sem alterações, sai direto.
class DbookFormDirtyGuard extends StatelessWidget {
  const DbookFormDirtyGuard({
    super.key,
    required this.isDirty,
    required this.child,
    this.title = 'Descartar alterações?',
    this.message = 'Há alterações que ainda não foram salvas.',
    this.discardLabel = 'Descartar',
    this.keepEditingLabel = 'Continuar editando',
  });

  final bool isDirty;
  final Widget child;
  final String title;
  final String message;
  final String discardLabel;
  final String keepEditingLabel;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final discard = await showDbookConfirmationDialog(
          context,
          title: title,
          message: message,
          confirmLabel: discardLabel,
          cancelLabel: keepEditingLabel,
          level: DbookConfirmLevel.destructive,
        );
        if (discard) navigator.pop();
      },
      child: child,
    );
  }
}
