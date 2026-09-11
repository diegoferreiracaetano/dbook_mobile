import 'package:flutter/material.dart';

import '../tokens/dbook_spacing.dart';

/// Indicador de carregamento padrão — reusado em toda tela que busca dado
/// (resultados de busca, detalhe do voo etc.) enquanto o request está em voo.
class DbookLoadingIndicator extends StatelessWidget {
  const DbookLoadingIndicator({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          if (message != null) ...[
            const SizedBox(height: DbookSpacing.md),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
