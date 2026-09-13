import 'package:flutter/material.dart';

import '../tokens/dbook_elevation.dart';
import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';
import 'dbook_button.dart';

/// Cartão de resumo de uma busca de voo — origem/destino, datas e
/// passageiros. Em [compact] vira uma única linha (topo de Resultados);
/// cheio (default) mostra os campos separados, como na Home.
class DbookTripSummaryCard extends StatelessWidget {
  const DbookTripSummaryCard({
    super.key,
    required this.origin,
    required this.destination,
    required this.dateRangeLabel,
    required this.passengersLabel,
    this.onSwap,
    this.onTapRoute,
    this.onTapDestination,
    this.onTapDates,
    this.onTapPassengers,
    this.returnDateLabel,
    this.onTapReturnDate,
    this.searchLabel,
    this.onSearch,
    this.extraContent,
    this.compact = false,
  });

  final String origin;
  final String destination;
  final String dateRangeLabel;
  final String passengersLabel;
  final VoidCallback? onSwap;

  /// No modo [compact], dispara ao tocar a linha inteira (reabrir a busca).
  /// No modo cheio, dispara só no campo "From" — "To" usa
  /// [onTapDestination], já que os dois campos precisam abrir seletores
  /// diferentes.
  final VoidCallback? onTapRoute;
  final VoidCallback? onTapDestination;
  final VoidCallback? onTapDates;
  final VoidCallback? onTapPassengers;

  /// Quando informado, o campo de data vira "Departure" + "Return" lado a
  /// lado (viagem de ida e volta); `null` mantém um único campo "Dates".
  final String? returnDateLabel;
  final VoidCallback? onTapReturnDate;

  /// Quando informado, renderiza um `DbookButton` de busca como último
  /// item do card (em vez de a tela dona ter que colocar esse botão em
  /// outro lugar, como um `bottomNavigationBar` separado).
  final String? searchLabel;
  final VoidCallback? onSearch;

  /// Conteúdo extra dentro do MESMO card, depois de "Passengers" e antes
  /// do botão de busca — pra jornadas como Multi-city, onde os trechos
  /// extras precisam ser seções do mesmo formulário (com um `Divider`
  /// entre elas), não cards separados empilhados.
  final List<Widget>? extraContent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Card(child: compact ? _CompactContent(this) : _FullContent(this));
  }
}

class _CompactContent extends StatelessWidget {
  const _CompactContent(this.data);

  final DbookTripSummaryCard data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: data.onTapRoute,
      borderRadius: BorderRadius.circular(DbookRadius.lg),
      child: Padding(
        padding: const EdgeInsets.all(DbookSpacing.md),
        child: Row(
          children: [
            Icon(Icons.flight_takeoff, color: colorScheme.primary),
            const SizedBox(width: DbookSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data.origin} → ${data.destination}',
                    style: textTheme.titleSmall,
                  ),
                  Text(
                    '${data.dateRangeLabel} · ${data.passengersLabel}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _FullContent extends StatelessWidget {
  const _FullContent(this.data);

  final DbookTripSummaryCard data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DbookSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  _FieldBox(
                    icon: Icons.flight_takeoff,
                    label: 'From',
                    value: data.origin,
                    onTap: data.onTapRoute,
                  ),
                  const SizedBox(height: DbookSpacing.sm),
                  _FieldBox(
                    icon: Icons.flight_land,
                    label: 'To',
                    value: data.destination,
                    onTap: data.onTapDestination,
                  ),
                ],
              ),
              Positioned(
                right: DbookSpacing.md,
                top: 0,
                bottom: 0,
                child: Center(child: _SwapButton(onTap: data.onSwap)),
              ),
            ],
          ),
          const SizedBox(height: DbookSpacing.sm),
          data.returnDateLabel == null
              ? _FieldBox(
                  icon: Icons.calendar_today_outlined,
                  label: 'Dates',
                  value: data.dateRangeLabel,
                  onTap: data.onTapDates,
                )
              : Row(
                  children: [
                    Expanded(
                      child: _FieldBox(
                        icon: Icons.calendar_today_outlined,
                        label: 'Departure',
                        value: data.dateRangeLabel,
                        onTap: data.onTapDates,
                      ),
                    ),
                    const SizedBox(width: DbookSpacing.sm),
                    Expanded(
                      child: _FieldBox(
                        icon: Icons.calendar_today_outlined,
                        label: 'Return',
                        value: data.returnDateLabel!,
                        onTap: data.onTapReturnDate,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: DbookSpacing.sm),
          _FieldBox(
            icon: Icons.person_outline,
            label: 'Passengers',
            value: data.passengersLabel,
            onTap: data.onTapPassengers,
          ),
          if (data.extraContent != null) ...data.extraContent!,
          if (data.searchLabel != null) ...[
            const SizedBox(height: DbookSpacing.md),
            DbookButton(
              label: data.searchLabel!,
              icon: Icons.search,
              onPressed: data.onSearch,
            ),
          ],
        ],
      ),
    );
  }
}

/// Botão de trocar origem/destino — flutua entre os dois campos, mesma
/// composição da referência visual (Figma Make "App de viagem com design
/// system"): botão circular cheio, preso na borda direita, sobrepondo as
/// duas caixas.
class _SwapButton extends StatelessWidget {
  const _SwapButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primary,
      shape: const CircleBorder(),
      elevation: DbookElevation.md,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(DbookSpacing.sm),
          child: Icon(Icons.swap_vert, color: colorScheme.onPrimary, size: 18),
        ),
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  const _FieldBox({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DbookRadius.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(DbookSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(DbookRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: DbookSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(value, style: textTheme.titleSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
