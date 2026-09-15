import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';

import 'my_bookings_page.dart';

/// Tela cheia de sucesso — mostra depois de reservar. "Ver Minhas Reservas"
/// empilha `MyBookingsPage`; "Concluído" volta pro detalhe do voo.
class BookingSuccessPage extends StatelessWidget {
  const BookingSuccessPage({
    super.key,
    required this.booking,
    required this.flight,
    required this.seat,
    this.nextLegLabel,
    this.onNextLeg,
  });

  final Booking booking;
  final Flight flight;
  final Seat seat;

  /// Quando informados (jornada Round Trip/Multi-city), a ação primária
  /// vira "escolher o assento do próximo voo" em vez de "ver minhas
  /// reservas" — o voo do próximo trecho já foi escolhido ANTES da
  /// seleção de assento começar (ver `_AppShellState._selectFlight` no
  /// app), então não precisa buscar de novo aqui; cada trecho continua
  /// sendo uma reserva de verdade e independente, já que o backend não
  /// modela reserva multi-trecho.
  final String? nextLegLabel;
  final VoidCallback? onNextLeg;

  @override
  Widget build(BuildContext context) {
    final hasNextLeg = nextLegLabel != null && onNextLeg != null;

    return Scaffold(
      body: DbookSuccessScreen(
        title: 'Booking Confirmed!',
        message: 'Seat ${seat.label} on ${flight.flightNumber} is yours.',
        referenceLabel: 'Booking reference',
        referenceValue: '#${booking.id}',
        primaryActionLabel: hasNextLeg
            ? 'Choose Seat: $nextLegLabel'
            : 'View My Bookings',
        onPrimaryAction: hasNextLeg
            ? onNextLeg
            : () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MyBookingsPage())),
        secondaryActionLabel: 'Done',
        onSecondaryAction: () => Navigator.of(context).pop(),
      ),
    );
  }
}
