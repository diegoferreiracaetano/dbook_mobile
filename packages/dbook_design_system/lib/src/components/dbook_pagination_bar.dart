import 'package:flutter/material.dart';

import '../tokens/dbook_spacing.dart';
import 'dbook_data_table_models.dart';

/// Rodapé de paginação: "Linhas por página", faixa atual ("26–50 de 120") e
/// botões de página anterior/próxima. Só mostra e avisa; quem busca a página
/// é o servidor (via [DbookPagination.onPageChanged]).
class DbookPaginationBar extends StatelessWidget {
  const DbookPaginationBar({super.key, required this.pagination});

  final DbookPagination pagination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizes = {...pagination.pageSizes, pagination.pageSize}.toList()
      ..sort();
    final range = pagination.total == 0
        ? '0 resultados'
        : '${pagination.firstItem}–${pagination.lastItem} de '
              '${pagination.total}';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DbookSpacing.md,
        vertical: DbookSpacing.xs,
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: DbookSpacing.md,
        children: [
          if (pagination.onPageSizeChanged != null) ...[
            Text('Linhas por página', style: theme.textTheme.labelMedium),
            DropdownButton<int>(
              value: pagination.pageSize,
              underline: const SizedBox.shrink(),
              items: [
                for (final size in sizes)
                  DropdownMenuItem(value: size, child: Text('$size')),
              ],
              onChanged: (size) {
                if (size != null) pagination.onPageSizeChanged!(size);
              },
            ),
          ],
          Text(
            range,
            style: theme.textTheme.labelMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Página anterior',
            onPressed: pagination.hasPrevious
                ? () => pagination.onPageChanged(pagination.page - 1)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Próxima página',
            onPressed: pagination.hasNext
                ? () => pagination.onPageChanged(pagination.page + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
