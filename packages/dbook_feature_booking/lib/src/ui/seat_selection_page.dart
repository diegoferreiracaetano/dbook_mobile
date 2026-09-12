import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/booking_providers.dart';
import '../state/seat_selection_state.dart';
import 'booking_success_page.dart';

final _priceFormat = NumberFormat.currency(symbol: r'$');

DbookSeatState _seatCellState(Seat seat, Seat? selected) {
  if (seat.id == selected?.id) return DbookSeatState.selected;
  return switch (seat.status) {
    SeatStatus.available => DbookSeatState.available,
    SeatStatus.reserved => DbookSeatState.occupied,
  };
}

/// Mapa de assentos de um voo — carrega ao montar (`SeatSelectionNotifier`),
/// deixa escolher um assento livre e confirma a reserva. Ao reservar com
/// sucesso, troca (não empilha) pela tela de sucesso.
class SeatSelectionPage extends ConsumerStatefulWidget {
  const SeatSelectionPage({super.key, required this.flight});

  final Flight flight;

  @override
  ConsumerState<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends ConsumerState<SeatSelectionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref
          .read(seatSelectionNotifierProvider.notifier)
          .loadSeats(widget.flight),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SeatSelectionState>(seatSelectionNotifierProvider, (
      previous,
      next,
    ) {
      if (next is SeatSelectionBooked) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BookingSuccessPage(record: next.record),
          ),
        );
      }
    });

    final state = ref.watch(seatSelectionNotifierProvider);

    return Scaffold(
      appBar: DbookAppBar(
        title: 'Select a Seat',
        subtitle:
            '${widget.flight.originIataCode} → '
            '${widget.flight.destinationIataCode}',
      ),
      body: switch (state) {
        SeatSelectionIdle() || SeatSelectionLoadingSeats() =>
          const DbookLoadingIndicator(message: 'Carregando assentos...'),
        SeatSelectionSeatsError(:final message) => DbookStatusPlaceholder(
          icon: Icons.error_outline,
          iconColor: Theme.of(context).colorScheme.error,
          title: 'Não foi possível carregar os assentos',
          message: message,
          actionLabel: 'Tentar de novo',
          onAction: () => ref
              .read(seatSelectionNotifierProvider.notifier)
              .loadSeats(widget.flight),
        ),
        SeatSelectionReady() => _SeatMapBody(state: state),
        SeatSelectionBooked() => const SizedBox.shrink(),
      },
      // M9-9.2: ação primária sempre alcançável, fixa no rodapé — nunca
      // solta no fim de um conteúdo que rola.
      bottomNavigationBar: state is SeatSelectionReady
          ? _SeatSelectionFooter(flight: widget.flight, state: state)
          : null,
    );
  }
}

class _SeatMapBody extends ConsumerWidget {
  const _SeatMapBody({required this.state});

  final SeatSelectionReady state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(DbookSpacing.lg),
          child: Wrap(
            spacing: DbookSpacing.lg,
            children: [
              DbookLegendItem(
                label: 'Available',
                color: colorScheme.outline,
                outlined: true,
              ),
              DbookLegendItem(label: 'Selected', color: colorScheme.primary),
              DbookLegendItem(
                label: 'Occupied',
                color: colorScheme.outlineVariant,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: DbookSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: DbookSpacing.sm,
              crossAxisSpacing: DbookSpacing.sm,
            ),
            itemCount: state.seats.length,
            itemBuilder: (context, index) {
              final seat = state.seats[index];
              return DbookSeatCell(
                state: _seatCellState(seat, state.selected),
                onTap: seat.status == SeatStatus.reserved
                    ? null
                    : () => ref
                          .read(seatSelectionNotifierProvider.notifier)
                          .selectSeat(seat),
              );
            },
          ),
        ),
        const SizedBox(height: DbookSpacing.lg),
      ],
    );
  }
}

class _SeatSelectionFooter extends ConsumerWidget {
  const _SeatSelectionFooter({required this.flight, required this.state});

  final Flight flight;
  final SeatSelectionReady state;

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final seat = state.selected;
    if (seat == null) return;

    final confirmed = await showDbookConfirmationDialog(
      context,
      title: 'Confirm Booking',
      message:
          'Book seat ${seat.label} for '
          '${_priceFormat.format(flight.price)}?',
      confirmLabel: 'Book',
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    await ref
        .read(seatSelectionNotifierProvider.notifier)
        .confirmBooking(flight);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      minimum: const EdgeInsets.all(DbookSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.bookingError != null) ...[
            DbookInlineStatusBanner(
              message: state.bookingError!,
              tone: DbookBannerTone.warning,
            ),
            const SizedBox(height: DbookSpacing.sm),
          ],
          DbookButton(
            label: state.selected == null
                ? 'Select a seat'
                : 'Book Seat ${state.selected!.label}',
            isLoading: state.isBooking,
            onPressed: state.selected == null
                ? null
                : () => _confirm(context, ref),
          ),
        ],
      ),
    );
  }
}
