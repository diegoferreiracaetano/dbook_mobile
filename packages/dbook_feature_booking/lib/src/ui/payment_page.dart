import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../booked_leg.dart';
import '../state/booking_providers.dart';
import '../state/payment_state.dart';

final _priceFormat = NumberFormat.currency(symbol: r'$');
final _cardNumberDigits = RegExp(r'\D');

/// Revisão final + pagamento — cobre TODOS os trechos já reservados
/// ([bookedLegs]) de uma vez só (uma Round Trip paga ida e volta juntas,
/// não uma tela por trecho). O assento de cada trecho aparece aqui só como
/// um detalhe do Resumo do Pedido, não como uma confirmação própria. Só
/// mostra o preço real de cada voo (já em memória, sem fetch novo) — sem
/// taxa/imposto fictício, que não existe no backend.
class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key, required this.bookedLegs, this.onPaid});

  final List<BookedLeg> bookedLegs;
  final void Function(PaymentPaid state)? onPaid;

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardholderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  double get _total =>
      widget.bookedLegs.fold(0, (sum, leg) => sum + leg.flight.price);

  @override
  void dispose() {
    _cardholderNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _submit() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    final digits = _cardNumberController.text.replaceAll(_cardNumberDigits, '');
    ref
        .read(paymentNotifierProvider.notifier)
        .pay(
          bookingIds: widget.bookedLegs.map((leg) => leg.booking.id).toList(),
          cardLast4: digits.substring(digits.length - 4),
          cardholderName: _cardholderNameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PaymentState>(paymentNotifierProvider, (previous, next) {
      if (next is PaymentPaid) widget.onPaid?.call(next);
    });

    final state = ref.watch(paymentNotifierProvider);
    final isSubmitting = state is PaymentSubmitting;

    return Scaffold(
      appBar: const DbookAppBar(title: 'Review & Pay'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OrderSummary(bookedLegs: widget.bookedLegs, total: _total),
              const SizedBox(height: DbookSpacing.xl),
              Text(
                'Card Information',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: DbookSpacing.md),
              TextFormField(
                controller: _cardholderNameController,
                autofillHints: const [AutofillHints.creditCardName],
                decoration: const InputDecoration(labelText: 'Cardholder name'),
                validator: _PaymentValidators.cardholderName,
              ),
              const SizedBox(height: DbookSpacing.md),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.creditCardNumber],
                decoration: const InputDecoration(labelText: 'Card number'),
                validator: _PaymentValidators.cardNumber,
              ),
              const SizedBox(height: DbookSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'MM/YY'),
                      validator: _PaymentValidators.expiry,
                    ),
                  ),
                  const SizedBox(width: DbookSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'CVV'),
                      validator: _PaymentValidators.cvv,
                    ),
                  ),
                ],
              ),
              if (state is PaymentError) ...[
                const SizedBox(height: DbookSpacing.md),
                DbookInlineStatusBanner(
                  message: state.message,
                  tone: DbookBannerTone.warning,
                ),
              ],
              const SizedBox(height: DbookSpacing.xl),
              DbookButton(
                label: 'Pay ${_priceFormat.format(_total)}',
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.bookedLegs, required this.total});

  final List<BookedLeg> bookedLegs;
  final double total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(DbookSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DbookRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Order Summary', style: textTheme.titleMedium),
          const SizedBox(height: DbookSpacing.md),
          for (final leg in bookedLegs) ...[
            _OrderSummaryLine(
              label:
                  '${leg.flight.originIataCode} → '
                  '${leg.flight.destinationIataCode} · Seat ${leg.seat.label}',
              value: _priceFormat.format(leg.flight.price),
            ),
            const SizedBox(height: DbookSpacing.sm),
          ],
          const Divider(),
          _OrderSummaryLine(
            label: 'Total',
            value: _priceFormat.format(total),
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryLine extends StatelessWidget {
  const _OrderSummaryLine({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = emphasized
        ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

/// Validação de formato/local só — nenhum gateway de pagamento real está
/// por trás, então não há CVV/bandeira/parcelamento de verdade a validar.
abstract final class _PaymentValidators {
  static String? cardholderName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Digite o nome no cartão';
    }
    return null;
  }

  static String? cardNumber(String? value) {
    final digits = (value ?? '').replaceAll(_cardNumberDigits, '');
    if (digits.length < 13 || digits.length > 19) {
      return 'Número de cartão inválido';
    }
    return null;
  }

  static String? expiry(String? value) {
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value ?? '')) {
      return 'MM/YY';
    }
    return null;
  }

  static String? cvv(String? value) {
    if (!RegExp(r'^\d{3,4}$').hasMatch(value ?? '')) {
      return 'CVV inválido';
    }
    return null;
  }
}
