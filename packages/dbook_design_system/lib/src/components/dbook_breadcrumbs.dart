import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

/// Um degrau do caminho. Sem [onTap] é o lugar atual (o último).
class DbookBreadcrumbItem {
  const DbookBreadcrumbItem({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;
}

/// Caminho de navegação ("Clientes › Diego Ferreira"). Os degraus com
/// [DbookBreadcrumbItem.onTap] são focáveis pelo teclado; o último é texto e
/// o leitor de tela o anuncia como o lugar atual.
class DbookBreadcrumbs extends StatelessWidget {
  const DbookBreadcrumbs({super.key, required this.items});

  final List<DbookBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;
      if (i > 0) {
        children.add(
          ExcludeSemantics(
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }
      children.add(
        isLast || item.onTap == null
            ? Semantics(
                label: isLast ? 'Página atual: ${item.label}' : item.label,
                excludeSemantics: true,
                child: Text(
                  item.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isLast
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(DbookRadius.xs),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DbookSpacing.xs,
                    vertical: DbookSpacing.xxs,
                  ),
                  child: Text(
                    item.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Caminho de navegação',
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: DbookSpacing.xxs,
        children: children,
      ),
    );
  }
}
