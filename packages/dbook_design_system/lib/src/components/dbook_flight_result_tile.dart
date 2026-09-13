import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

/// Linha de resultado de busca de voo — companhia, horários de
/// partida/chegada, duração, paradas e preço, com contorno de destaque
/// quando [selected].
class DbookFlightResultTile extends StatelessWidget {
  const DbookFlightResultTile({
    super.key,
    required this.airlineName,
    required this.departureTime,
    required this.departureAirport,
    required this.arrivalTime,
    required this.arrivalAirport,
    required this.durationLabel,
    required this.price,
    this.airlineIataCode,
    this.airlineColor,
    this.airlineIcon = Icons.flight,
    this.flightNumber,
    this.stopsLabel = 'Nonstop',
    this.selected = false,
    this.onTap,
  });

  final String airlineName;
  final String? flightNumber;

  /// Quando informado (com [airlineColor]), o selo vira um quadrado colorido
  /// com o código IATA da companhia (ex.: referência visual real de apps de
  /// busca de voo) em vez do ícone genérico de avião.
  final String? airlineIataCode;
  final Color? airlineColor;
  final IconData airlineIcon;
  final String departureTime;
  final String departureAirport;
  final String arrivalTime;
  final String arrivalAirport;
  final String durationLabel;
  final String stopsLabel;
  final String price;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(DbookRadius.lg);
    final subtitleStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: selected
            ? BorderSide(color: colorScheme.primary, width: 1.6)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(DbookSpacing.md),
          child: Row(
            children: [
              _AirlineBadge(
                iataCode: airlineIataCode,
                color: airlineColor,
                icon: airlineIcon,
              ),
              const SizedBox(width: DbookSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flightNumber == null
                          ? airlineName
                          : '$airlineName · $flightNumber',
                      style: textTheme.labelMedium,
                    ),
                    const SizedBox(height: DbookSpacing.xs),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(departureTime, style: textTheme.titleSmall),
                            Text(departureAirport, style: subtitleStyle),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(durationLabel, style: subtitleStyle),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: colorScheme.outlineVariant,
                                      height: 1,
                                    ),
                                  ),
                                  Icon(
                                    Icons.flight,
                                    size: 12,
                                    color: colorScheme.primary,
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: colorScheme.outlineVariant,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(stopsLabel, style: subtitleStyle),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(arrivalTime, style: textTheme.titleSmall),
                            Text(arrivalAirport, style: subtitleStyle),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DbookSpacing.sm),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    price,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AirlineBadge extends StatelessWidget {
  const _AirlineBadge({required this.iataCode, required this.color, required this.icon});

  final String? iataCode;
  final Color? color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (iataCode == null || color == null) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
      );
    }

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DbookRadius.sm),
      ),
      child: Text(
        iataCode!,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
