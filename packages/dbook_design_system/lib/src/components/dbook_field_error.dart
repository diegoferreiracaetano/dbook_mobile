import 'package:flutter/material.dart';

import '../tokens/dbook_spacing.dart';

/// Mensagem de erro de um bloco que não é um campo de formulário (diálogo,
/// seção, resultado de importação). Um só lugar para a cor e o tipo, em vez
/// de `TextStyle(color: ...error)` repetido em cada tela. Anunciada como
/// região ativa para leitores de tela.
class DbookFieldError extends StatelessWidget {
  const DbookFieldError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(top: DbookSpacing.xs),
        child: Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}
