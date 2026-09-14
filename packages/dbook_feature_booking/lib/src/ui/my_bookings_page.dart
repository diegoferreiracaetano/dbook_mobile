import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/booking_providers.dart';

final _dateFormat = DateFormat('EEE, MMM d, yyyy · HH:mm');

const _knownAirlineColors = {
  'LA': Color(0xFFB23A2E),
  'AD': Color(0xFF1E4FA3),
  'G3': Color(0xFF1E7A34),
  'AA': Color(0xFF6A3FA0),
  'DL': Color(0xFFB35A00),
  'UA': Color(0xFF00838F),
};

const _airlinePalette = [
  Color(0xFF5C6BC0),
  Color(0xFF26A69A),
  Color(0xFFEC6C4B),
  Color(0xFF8D6E63),
];

/// Companhia fora da lista conhecida cai num hash determinístico — mesmo
/// espírito de `_airlineColor` em `dbook_feature_flights`, duplicado aqui
/// de propósito (features não importam features, cada uma monta sua
/// própria fiação/apresentação fina).
Color _airlineColor(String iataCode) =>
    _knownAirlineColors[iataCode] ??
    _airlinePalette[iataCode.hashCode.abs() % _airlinePalette.length];

DbookStatus _toDbookStatus(BookingStatus status) => switch (status) {
  BookingStatus.pending => DbookStatus.pending,
  BookingStatus.confirmed => DbookStatus.confirmed,
  BookingStatus.cancelled => DbookStatus.cancelled,
};

String _statusLabel(BookingStatus status) => switch (status) {
  BookingStatus.pending => 'Pendente',
  BookingStatus.confirmed => 'Confirmada',
  BookingStatus.cancelled => 'Cancelada',
};

Destination? _destinationFor(String iataCode, List<Destination> destinations) {
  for (final destination in destinations) {
    if (destination.iataCode == iataCode) return destination;
  }
  return null;
}

/// Minhas Viagens — busca via `GET /bookings` (`MyBookingsNotifier`, agora
/// persistido de verdade, não só memória de sessão), separadas em Próximas
/// e Anteriores. [destinations] é a MESMA lista já carregada por
/// `featuredDestinationsProvider` (`dbook_feature_flights`) — repassada
/// pela tela dona (`main.dart`, que já importa as duas features) pra cruzar
/// a foto do destino sem um fetch novo; vazia por padrão (cai no
/// fallback de gradiente) pra quem chamar de dentro da própria feature
/// (ex. `BookingSuccessPage`) sem precisar dela.
class MyBookingsPage extends ConsumerStatefulWidget {
  const MyBookingsPage({super.key, this.destinations = const []});

  final List<Destination> destinations;

  @override
  ConsumerState<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends ConsumerState<MyBookingsPage> {
  var _tabIndex = 0;

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    MyBooking booking,
  ) async {
    final confirmed = await showDbookConfirmationDialog(
      context,
      title: 'Cancel Booking',
      message: 'Cancel your seat ${booking.seat.label} booking?',
      confirmLabel: 'Cancel Booking',
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    try {
      await ref.read(myBookingsNotifierProvider.notifier).cancel(booking.id);
    } on DbookNetworkException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _refresh() async {
    final _ = await ref.refresh(myBookingsNotifierProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(myBookingsNotifierProvider);

    return Scaffold(
      appBar: const DbookAppBar(title: 'My Bookings'),
      body: switch (bookingsAsync) {
        AsyncData(:final value) => _BookingsBody(
          bookings: value,
          tabIndex: _tabIndex,
          destinations: widget.destinations,
          onTabChanged: (index) => setState(() => _tabIndex = index),
          onRefresh: _refresh,
          onCancel: (booking) => _cancel(context, ref, booking),
        ),
        AsyncError(:final error) => DbookStatusPlaceholder(
          icon: Icons.error_outline,
          iconColor: Theme.of(context).colorScheme.error,
          title: 'Não foi possível carregar suas reservas',
          message: error is DbookNetworkException
              ? error.message
              : 'Tente novamente em instantes.',
          actionLabel: 'Tentar de novo',
          onAction: () => ref.invalidate(myBookingsNotifierProvider),
        ),
        _ => const DbookLoadingIndicator(message: 'Carregando reservas...'),
      },
    );
  }
}

class _BookingsBody extends StatelessWidget {
  const _BookingsBody({
    required this.bookings,
    required this.tabIndex,
    required this.destinations,
    required this.onTabChanged,
    required this.onRefresh,
    required this.onCancel,
  });

  final List<MyBooking> bookings;
  final int tabIndex;
  final List<Destination> destinations;
  final ValueChanged<int> onTabChanged;
  final Future<void> Function() onRefresh;
  final void Function(MyBooking booking) onCancel;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming =
        bookings.where((b) => b.flight.departureTime.isAfter(now)).toList()
          ..sort(
            (a, b) => a.flight.departureTime.compareTo(b.flight.departureTime),
          );
    final past =
        bookings.where((b) => !b.flight.departureTime.isAfter(now)).toList()
          ..sort(
            (a, b) => b.flight.departureTime.compareTo(a.flight.departureTime),
          );
    final shown = tabIndex == 0 ? upcoming : past;

    if (bookings.isEmpty) {
      return const DbookStatusPlaceholder(
        icon: Icons.confirmation_number_outlined,
        title: 'Nenhuma reserva ainda',
        message: 'As reservas que você fizer aparecem aqui.',
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(DbookSpacing.lg),
            child: DbookChipRow(
              labels: const ['Próximas', 'Anteriores'],
              selectedIndex: tabIndex,
              onSelected: onTabChanged,
            ),
          ),
          Expanded(
            child: shown.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 300,
                      child: DbookStatusPlaceholder(
                        icon: Icons.confirmation_number_outlined,
                        title: tabIndex == 0
                            ? 'Nenhuma viagem futura'
                            : 'Nenhuma viagem anterior',
                        message: tabIndex == 0
                            ? 'Suas próximas reservas aparecem aqui.'
                            : 'Reservas já realizadas aparecem aqui.',
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      DbookSpacing.lg,
                      0,
                      DbookSpacing.lg,
                      DbookSpacing.lg,
                    ),
                    itemCount: shown.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: DbookSpacing.sm),
                    itemBuilder: (context, index) {
                      final booking = shown[index];
                      return _BookingCard(
                        booking: booking,
                        destination: _destinationFor(
                          booking.flight.destinationIataCode,
                          destinations,
                        ),
                        onCancel: booking.status == BookingStatus.pending
                            ? () => onCancel(booking)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.destination,
    this.onCancel,
  });

  final MyBooking booking;
  final Destination? destination;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final flight = booking.flight;
    final airlineColor = _airlineColor(flight.airlineIataCode);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DbookSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DestinationThumbnail(
              photoUrl: destination?.photoUrl,
              fallbackColor: airlineColor,
            ),
            const SizedBox(width: DbookSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${flight.originIataCode} → '
                          '${flight.destinationIataCode}',
                          style: textTheme.titleSmall,
                        ),
                      ),
                      DbookStatusBadge(
                        status: _toDbookStatus(booking.status),
                        label: _statusLabel(booking.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: DbookSpacing.xs),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: airlineColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: DbookSpacing.xs),
                      Expanded(
                        child: Text(
                          '${flight.airlineName} · ${flight.aircraftType}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DbookSpacing.xs),
                  Text(
                    '${_dateFormat.format(flight.departureTime)} · '
                    'Seat ${booking.seat.label}',
                    style: textTheme.bodySmall,
                  ),
                  if (onCancel != null) ...[
                    const SizedBox(height: DbookSpacing.sm),
                    DbookButton(
                      label: 'Cancel Booking',
                      variant: DbookButtonVariant.text,
                      onPressed: onCancel,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Foto real do destino quando disponível no catálogo já carregado
/// (`destinations`); senão um degradê na cor da companhia — nunca um
/// espaço vazio.
class _DestinationThumbnail extends StatelessWidget {
  const _DestinationThumbnail({this.photoUrl, required this.fallbackColor});

  final String? photoUrl;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DbookRadius.md),
      child: SizedBox(
        width: 64,
        height: 64,
        child: photoUrl == null
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
                child: const Icon(Icons.flight_outlined, color: Colors.white),
              )
            : Image.network(photoUrl!, fit: BoxFit.cover),
      ),
    );
  }
}
