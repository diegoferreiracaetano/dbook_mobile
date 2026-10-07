import 'package:flutter/material.dart';

import '../tokens/dbook_spacing.dart';

/// Um par rótulo/valor. O valor é texto ([value]) ou um widget ([child], por
/// exemplo um [DbookStatusBadge]); sem nenhum dos dois mostra "—" (o app não
/// preenche o que o backend não mandou).
class DbookDefinition {
  const DbookDefinition({required this.label, this.value, this.child})
    : assert(value == null || child == null, 'Use value or child, not both');

  final String label;
  final String? value;
  final Widget? child;
}

/// Lista de pares rótulo/valor (a "visão 360º" de um cliente ou reserva). Em
/// largura de 480dp ou mais, rótulo e valor ficam lado a lado; abaixo disso,
/// empilhados. O texto é selecionável: o operador copia e-mail e códigos.
class DbookDefinitionList extends StatelessWidget {
  const DbookDefinitionList({super.key, required this.items});

  static const double _sideBySideFrom = 480;
  static const double _labelWidth = 160;

  final List<DbookDefinition> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= _sideBySideFrom;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: DbookSpacing.sm),
                child: sideBySide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: _labelWidth,
                            child: _label(context, item),
                          ),
                          Expanded(child: _value(context, item)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label(context, item),
                          const SizedBox(height: DbookSpacing.xxs),
                          _value(context, item),
                        ],
                      ),
              ),
          ],
        );
      },
    );
  }

  Widget _label(BuildContext context, DbookDefinition item) {
    final theme = Theme.of(context);
    return Text(
      item.label,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _value(BuildContext context, DbookDefinition item) {
    if (item.child != null) {
      return Align(alignment: Alignment.centerLeft, child: item.child);
    }
    final text = item.value;
    return SelectableText(
      text == null || text.isEmpty ? '—' : text,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
