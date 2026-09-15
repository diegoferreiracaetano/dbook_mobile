import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../airline_colors.dart';
import '../state/flight_providers.dart';

final _timeFormat = DateFormat('HH:mm');
final _heroDateFormat = DateFormat('EEE, MMM d, yyyy');
final _priceFormat = NumberFormat.currency(symbol: r'$');

const _heroHeight = 260.0;

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return '${hours}h ${minutes}m';
}

String _seatClassLabel(SeatClass seatClass) => switch (seatClass) {
  SeatClass.economy => 'Economy',
  SeatClass.premiumEconomy => 'Premium Economy',
  SeatClass.business => 'Business',
  SeatClass.first => 'First',
};

/// Mesma lista já carregada pela Home/Explore/Minhas Viagens
/// (`featuredDestinationsProvider`, já definido nesta feature) — cruzada
/// aqui só pra achar a foto do destino de chegada, sem fetch novo.
Destination? _destinationFor(String iataCode, List<Destination> destinations) {
  for (final destination in destinations) {
    if (destination.iataCode == iataCode) return destination;
  }
  return null;
}

/// Detalhe de um voo já buscado — recebe o [Flight] escolhido na lista de
/// resultados (evita rebuscar ou modelar um "GET /flights/{id}" que o
/// backend não expõe). [onBook] mora na feature de reserva (M5) e
/// [liveAvailability] na de tempo real (M6) — a de voos não importa
/// nenhuma das duas (features não importam features), então quem monta
/// essa tela decide o que cada uma faz.
class FlightDetailPage extends ConsumerWidget {
  const FlightDetailPage({
    super.key,
    required this.flight,
    this.onBook,
    this.liveAvailability,
  });

  final Flight flight;
  final ValueChanged<Flight>? onBook;
  final Widget? liveAvailability;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations =
        ref.watch(featuredDestinationsProvider).value ?? const [];
    final destination = _destinationFor(
      flight.destinationIataCode,
      destinations,
    );
    final airlineColor = airlineColorFor(flight.airlineIataCode);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: DbookAppBar(title: 'Flight Details', transparent: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroHeader(
              flight: flight,
              destination: destination,
              fallbackColor: airlineColor,
            ),
            Padding(
              padding: const EdgeInsets.all(DbookSpacing.lg),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(DbookSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _AirlineBadge(
                            iataCode: flight.airlineIataCode,
                            color: airlineColor,
                          ),
                          const SizedBox(width: DbookSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                flight.airlineName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                flight.flightNumber,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Chip(label: Text(_seatClassLabel(flight.seatClass))),
                        ],
                      ),
                      const SizedBox(height: DbookSpacing.lg),
                      _FlightRouteTimeline(flight: flight),
                      const SizedBox(height: DbookSpacing.lg),
                      DbookSummaryRow(
                        label: 'Aircraft',
                        value: flight.aircraftType,
                      ),
                      if (liveAvailability != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: DbookSpacing.xs,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Seats available',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              liveAvailability!,
                            ],
                          ),
                        )
                      else
                        DbookSummaryRow(
                          label: 'Seats available',
                          value: '${flight.availableCapacity}',
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // M9-9.2: preço + ação primária sempre visíveis, fixos no rodapé —
      // mesmo arranjo da tela de referência (kit, 06).
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(DbookSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: DbookPriceDisplay(
                amount: _priceFormat.format(flight.price),
                caption: 'per passenger',
              ),
            ),
            if (onBook != null) ...[
              const SizedBox(width: DbookSpacing.md),
              DbookButton(
                label: 'Book This Flight',
                onPressed: () => onBook!(flight),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Cabeçalho em foto cheia do destino de chegada (mesma foto já carregada
/// pela Home/Explore/Minhas Viagens, cruzada por `destinationIataCode` —
/// sem fetch novo) com um degradê escuro no rodapé e cidade/país + data
/// sobrepostos, igual à referência visual. Sem foto disponível (destino
/// fora do catálogo — deveria ser raro, mas não impede a tela), cai num
/// degradê pela cor da companhia em vez de deixar um espaço vazio.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.flight,
    required this.destination,
    required this.fallbackColor,
  });

  final Flight flight;
  final Destination? destination;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    final photoUrl = destination?.photoUrl;
    final title = destination != null
        ? '${destination!.city}, ${destination!.country}'
        : flight.destinationIataCode;

    return SizedBox(
      height: _heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          photoUrl == null
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        fallbackColor.withValues(alpha: 0.7),
                        fallbackColor,
                      ],
                    ),
                  ),
                )
              : Image.network(photoUrl, fit: BoxFit.cover),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC000000)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DbookSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      _heroDateFormat.format(flight.departureTime),
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Selo com o código IATA da companhia sobre a cor fixa dela — mesmo
/// visual do badge de `DbookFlightResultTile` (design system), reaplicado
/// aqui porque aquele é privado ao componente de resultado.
class _AirlineBadge extends StatelessWidget {
  const _AirlineBadge({required this.iataCode, required this.color});

  final String iataCode;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DbookRadius.sm),
      ),
      child: Text(
        iataCode,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Rota do voo com horários grandes e a mesma linha pontilhada + ícone de
/// avião do card de resultado (`DbookFlightResultTile`) — reaproveita a
/// mesma composição visual em vez de inventar outra.
class _FlightRouteTimeline extends StatelessWidget {
  const _FlightRouteTimeline({required this.flight});

  final Flight flight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final subtitleStyle = textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _timeFormat.format(flight.departureTime),
              style: textTheme.headlineSmall,
            ),
            Text(flight.originIataCode, style: subtitleStyle),
          ],
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                _formatDuration(
                  flight.arrivalTime.difference(flight.departureTime),
                ),
                style: subtitleStyle,
              ),
              const SizedBox(height: DbookSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: colorScheme.outlineVariant,
                      height: 1,
                    ),
                  ),
                  Icon(Icons.flight, size: 16, color: colorScheme.primary),
                  Expanded(
                    child: Divider(
                      color: colorScheme.outlineVariant,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _timeFormat.format(flight.arrivalTime),
              style: textTheme.headlineSmall,
            ),
            Text(flight.destinationIataCode, style: subtitleStyle),
          ],
        ),
      ],
    );
  }
}
