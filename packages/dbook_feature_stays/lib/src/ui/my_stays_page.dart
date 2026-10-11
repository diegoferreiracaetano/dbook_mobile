import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/stay_providers.dart';
import 'stays_page.dart' show StayCheckout;

final _priceFormat = NumberFormat.currency(symbol: r'$');
final _dayFormat = DateFormat('dd/MM/yyyy');

/// Estadias do usuário (as reservas de hotel de `GET /bookings`). Só lista:
/// o servidor é quem diz o estado, e o cancelamento de reserva segue o mesmo
/// fluxo do voo.
class MyStaysPage extends StatelessWidget {
  const MyStaysPage({super.key, this.onPay});

  final void Function(StayCheckout checkout)? onPay;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const DbookAppBar(title: 'Minhas estadias'),
    body: MyStaysList(onPay: onPay),
  );
}

/// A lista em si, sem `Scaffold`: a aba de viagens a encaixa ao lado dos
/// voos. [onPay] aparece só nas estadias pendentes (a reserva expira).
class MyStaysList extends ConsumerWidget {
  const MyStaysList({super.key, this.onPay});

  final void Function(StayCheckout checkout)? onPay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stays = ref.watch(myStaysProvider);
    return stays.when(
      loading: () => const DbookLoadingIndicator(),
      error: (error, _) => DbookErrorState(
        message: stayErrorMessage(error),
        onRetry: () => ref.invalidate(myStaysProvider),
      ),
      data: (items) => items.isEmpty
          ? const DbookEmptyState(
              icon: Icons.hotel_outlined,
              title: 'Nenhuma estadia ainda',
              message: 'Reserve um hotel e ele aparece aqui.',
            )
          : ListView(
              padding: const EdgeInsets.all(DbookSpacing.lg),
              children: [
                for (final stay in items)
                  _StayTile(
                    stay: stay,
                    onPay: onPay != null && stay.status == 'PENDING'
                        ? () => onPay!((
                            bookingId: stay.bookingId,
                            label: '${stay.hotelName} · ${stay.nights} noites',
                            price: stay.price,
                          ))
                        : null,
                  ),
              ],
            ),
    );
  }
}

class _StayTile extends StatelessWidget {
  const _StayTile({required this.stay, this.onPay});

  final StayBooking stay;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: DbookSpacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(DbookSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stay.hotelName, style: theme.textTheme.titleMedium),
              Text(stay.city, style: theme.textTheme.bodySmall),
              const SizedBox(height: DbookSpacing.sm),
              Text(
                '${_dayFormat.format(stay.checkIn)} a '
                '${_dayFormat.format(stay.checkOut)} · '
                '${stay.nights} noites · ${stay.guests} hóspedes',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: DbookSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DbookStatusBadge(
                    status: _status(stay.status),
                    label: _label(stay.status),
                  ),
                  Text(
                    _priceFormat.format(stay.price),
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
              if (onPay != null) ...[
                const SizedBox(height: DbookSpacing.md),
                DbookButton(label: 'Pagar agora', onPressed: onPay),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static DbookStatus _status(String wire) => switch (wire) {
    'CONFIRMED' => DbookStatus.confirmed,
    'PENDING' => DbookStatus.pending,
    'CANCELLED' || 'REFUNDED' => DbookStatus.cancelled,
    _ => DbookStatus.unknown,
  };

  static String _label(String wire) => switch (wire) {
    'CONFIRMED' => 'Confirmada',
    'PENDING' => 'Pendente',
    'CANCELLED' => 'Cancelada',
    'REFUNDED' => 'Reembolsada',
    'EXPIRED' => 'Expirada',
    _ => 'Status desconhecido',
  };
}
