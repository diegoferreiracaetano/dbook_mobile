import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';

/// Estado de uma célula do mapa de assento.
enum DbookSeatState { available, selected, occupied }

/// Célula do mapa de assento — livre (contorno), selecionado (preenchido
/// com a cor primária) ou ocupado (preenchido neutro, intocável). O topo
/// mais arredondado que a base lembra o encosto de uma poltrona (sem
/// tentar desenhar um ícone literal de avião), e o [label] (ex. "12A")
/// fica visível dentro da célula.
class DbookSeatCell extends StatelessWidget {
  const DbookSeatCell({super.key, required this.state, this.label, this.onTap});

  final DbookSeatState state;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (background, border, foreground) = switch (state) {
      DbookSeatState.available => (
        Colors.transparent,
        colorScheme.outline,
        colorScheme.onSurface,
      ),
      DbookSeatState.selected => (
        colorScheme.primary,
        colorScheme.primary,
        colorScheme.onPrimary,
      ),
      DbookSeatState.occupied => (
        colorScheme.outlineVariant,
        colorScheme.outlineVariant,
        colorScheme.onSurfaceVariant,
      ),
    };

    return InkWell(
      onTap: state == DbookSeatState.occupied ? null : onTap,
      borderRadius: const BorderRadius.all(Radius.circular(DbookRadius.md)),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border, width: 1.4),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(DbookRadius.md),
            topRight: Radius.circular(DbookRadius.md),
            bottomLeft: Radius.circular(DbookRadius.xs),
            bottomRight: Radius.circular(DbookRadius.xs),
          ),
        ),
        child: label == null
            ? null
            : Text(
                label!,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
