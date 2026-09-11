import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(DbookSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _FieldTile(
                  icon: Icons.flight_takeoff,
                  label: 'From',
                  value: data.origin,
                  onTap: data.onTapRoute,
                ),
              ),
              IconButton(
                onPressed: data.onSwap,
                icon: const Icon(Icons.swap_horiz),
                color: colorScheme.primary,
              ),
              Expanded(
                child: _FieldTile(
                  icon: Icons.flight_land,
                  label: 'To',
                  value: data.destination,
                  onTap: data.onTapDestination,
                ),
              ),
            ],
          ),
          const SizedBox(height: DbookSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _FieldTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Dates',
                  value: data.dateRangeLabel,
                  onTap: data.onTapDates,
                ),
              ),
              const SizedBox(width: DbookSpacing.sm),
              Expanded(
                child: _FieldTile(
                  icon: Icons.person_outline,
                  label: 'Passengers',
                  value: data.passengersLabel,
                  onTap: data.onTapPassengers,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({
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
      borderRadius: BorderRadius.circular(DbookRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DbookSpacing.xs),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
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
                  Text(value, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
