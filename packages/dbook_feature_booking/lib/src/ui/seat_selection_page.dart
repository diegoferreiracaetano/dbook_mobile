import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/booking_providers.dart';
import '../state/seat_selection_state.dart';

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
/// sucesso, chama [onBooked] em vez de navegar sozinha — quem decide o que
/// acontece depois (próximo trecho em silêncio, ou revisão + pagamento) é
/// sempre quem montou esta página, nunca ela mesma.
class SeatSelectionPage extends ConsumerStatefulWidget {
  const SeatSelectionPage({super.key, required this.flight, this.onBooked});

  final Flight flight;
  final void Function(Booking booking, Flight flight, Seat seat)? onBooked;

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
        widget.onBooked?.call(next.booking, next.flight, next.seat);
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
        SeatSelectionReady() => _SeatMapBody(
          state: state,
          flight: widget.flight,
        ),
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

const _seatCellSize = 40.0;
const _seatGap = DbookSpacing.xs;
const _aisleWidth = DbookSpacing.xl;
const _rowLabelWidth = 28.0;
final _seatLabelPattern = RegExp(r'^(\d+)([A-Z])$');

/// Colunas (letras) de cada bloco do layout — ex. `[3, 3]` vira
/// `[[A,B,C],[D,E,F]]`, `[3, 4, 3]` vira `[[A,B,C],[D,E,F,G],[H,I,J]]`. É a
/// ÚNICA fonte da regra de fileira/corredor no front — o array já vem
/// pronto do backend (`seatLayoutFor`), o Flutter só agrupa por ele.
List<List<String>> _columnBlocksFor(List<int> seatLayout) {
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  var index = 0;
  return seatLayout.map((count) {
    final block = alphabet.substring(index, index + count).split('');
    index += count;
    return block;
  }).toList();
}

/// Agrupa os assentos por número de fileira, mantendo a letra da coluna
/// como chave — uma fileira pode não ter uma coluna presente (não deveria
/// acontecer com dado real do backend, mas o layout não assume isso).
Map<int, Map<String, Seat>> _seatsByRow(List<Seat> seats) {
  final byRow = <int, Map<String, Seat>>{};
  for (final seat in seats) {
    final match = _seatLabelPattern.firstMatch(seat.label);
    if (match == null) continue;
    final row = int.parse(match.group(1)!);
    final letter = match.group(2)!;
    byRow.putIfAbsent(row, () => {})[letter] = seat;
  }
  return byRow;
}

class _SeatMapBody extends ConsumerWidget {
  const _SeatMapBody({required this.state, required this.flight});

  final SeatSelectionReady state;
  final Flight flight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final columnBlocks = _columnBlocksFor(flight.seatLayout);
    final rows = _seatsByRow(state.seats);
    final sortedRowNumbers = rows.keys.toList()..sort();

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: DbookSpacing.lg),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DbookSpacing.md,
                  vertical: DbookSpacing.lg,
                ),
                decoration: BoxDecoration(
                  // Fundo com cantos arredondados lembrando a seção
                  // transversal de uma cabine, sem tentar desenhar um
                  // avião literal.
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(DbookRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ColumnLettersHeader(columnBlocks: columnBlocks),
                    const SizedBox(height: DbookSpacing.sm),
                    for (final rowNumber in sortedRowNumbers)
                      Padding(
                        padding: const EdgeInsets.only(bottom: DbookSpacing.sm),
                        child: _SeatMapRow(
                          rowNumber: rowNumber,
                          seatsByLetter: rows[rowNumber]!,
                          columnBlocks: columnBlocks,
                          selected: state.selected,
                          onSelect: (seat) => ref
                              .read(seatSelectionNotifierProvider.notifier)
                              .selectSeat(seat),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: DbookSpacing.lg),
      ],
    );
  }
}

/// Cabeçalho com as letras das colunas, no mesmo agrupamento por bloco/
/// corredor da(s) fileira(s) abaixo.
class _ColumnLettersHeader extends StatelessWidget {
  const _ColumnLettersHeader({required this.columnBlocks});

  final List<List<String>> columnBlocks;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final children = <Widget>[const SizedBox(width: _rowLabelWidth)];

    for (var blockIndex = 0; blockIndex < columnBlocks.length; blockIndex++) {
      if (blockIndex > 0) children.add(const SizedBox(width: _aisleWidth));
      final block = columnBlocks[blockIndex];
      for (var i = 0; i < block.length; i++) {
        if (i > 0) children.add(const SizedBox(width: _seatGap));
        children.add(
          SizedBox(
            width: _seatCellSize,
            child: Text(
              block[i],
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

/// Uma fileira do mapa: número à esquerda, assentos agrupados em blocos
/// separados por corredor. Só desenha células pra colunas que de fato têm
/// assento naquela fileira (dado sparse, ex. em teste, não gera buracos).
class _SeatMapRow extends StatelessWidget {
  const _SeatMapRow({
    required this.rowNumber,
    required this.seatsByLetter,
    required this.columnBlocks,
    required this.selected,
    required this.onSelect,
  });

  final int rowNumber;
  final Map<String, Seat> seatsByLetter;
  final List<List<String>> columnBlocks;
  final Seat? selected;
  final void Function(Seat seat) onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final children = <Widget>[
      SizedBox(
        width: _rowLabelWidth,
        child: Text('$rowNumber', style: textTheme.labelMedium),
      ),
    ];

    var addedAnyBlock = false;
    for (final block in columnBlocks) {
      final present = block.where(seatsByLetter.containsKey).toList();
      if (present.isEmpty) continue;
      if (addedAnyBlock) children.add(const SizedBox(width: _aisleWidth));
      for (var i = 0; i < present.length; i++) {
        if (i > 0) children.add(const SizedBox(width: _seatGap));
        final seat = seatsByLetter[present[i]]!;
        children.add(
          DbookSeatCell(
            state: _seatCellState(seat, selected),
            label: seat.label,
            onTap: seat.status == SeatStatus.reserved
                ? null
                : () => onSelect(seat),
          ),
        );
      }
      addedAnyBlock = true;
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
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
