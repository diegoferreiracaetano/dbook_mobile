import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';

/// Estado de uma célula do mapa de assento.
enum DbookSeatState { available, selected, occupied }

/// Célula quadrada do mapa de assento — livre (contorno), selecionado
/// (preenchido com a cor primária) ou ocupado (preenchido neutro,
/// intocável).
class DbookSeatCell extends StatelessWidget {
  const DbookSeatCell({super.key, required this.state, this.onTap});

  final DbookSeatState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (background, border) = switch (state) {
      DbookSeatState.available => (Colors.transparent, colorScheme.outline),
      DbookSeatState.selected => (colorScheme.primary, colorScheme.primary),
      DbookSeatState.occupied => (
        colorScheme.outlineVariant,
        colorScheme.outlineVariant,
      ),
    };

    return InkWell(
      onTap: state == DbookSeatState.occupied ? null : onTap,
      borderRadius: BorderRadius.circular(DbookRadius.xs),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border, width: 1.4),
          borderRadius: BorderRadius.circular(DbookRadius.xs),
        ),
      ),
    );
  }
}
