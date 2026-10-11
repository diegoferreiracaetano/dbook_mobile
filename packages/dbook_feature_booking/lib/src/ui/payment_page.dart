import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../booked_leg.dart';
import '../state/booking_providers.dart';
import '../state/payment_state.dart';
import '../state/promo_notifier.dart';
import '../state/promo_state.dart';

final _priceFormat = NumberFormat.currency(symbol: r'$');
final _cardNumberDigits = RegExp(r'\D');

/// Revisão final + pagamento — cobre TODOS os trechos já reservados
/// ([bookedLegs]) de uma vez só (uma Round Trip paga ida e volta juntas,
/// não uma tela por trecho). O assento de cada trecho aparece aqui só como
/// um detalhe do Resumo do Pedido, não como uma confirmação própria. Só
/// mostra o preço real de cada voo (já em memória, sem fetch novo) — sem
/// taxa/imposto fictício, que não existe no backend.
class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({
    super.key,
    this.bookedLegs = const [],
    this.items = const [],
    this.onPaid,
  });

  final List<BookedLeg> bookedLegs;

  /// Itens que não são voo (hotel), pagos junto com [bookedLegs].
  final List<PaidItem> items;
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
  final _promoController = TextEditingController();
  final _promoFocus = FocusNode();

  /// O valor das reservas (o servidor cobra `Booking.price`, congelado).
  double get _subtotal =>
      widget.bookedLegs.fold<double>(0, (sum, leg) => sum + leg.flight.price) +
      widget.items.fold<double>(0, (sum, item) => sum + item.price);

  List<int> get _bookingIds => [
    ...widget.bookedLegs.map((leg) => leg.booking.id),
    ...widget.items.map((item) => item.bookingId),
  ];

  @override
  void initState() {
    super.initState();
    // valida o código ao sair do campo
    _promoFocus.addListener(() {
      if (!_promoFocus.hasFocus) _validatePromo();
    });
  }

  void _validatePromo() {
    final current = ref.read(promoNotifierProvider);
    final text = _promoController.text.trim();
    if (current is PromoApplied &&
        current.preview.code.toLowerCase() == text.toLowerCase()) {
      return;
    }
    ref.read(promoNotifierProvider.notifier).validate(text, _bookingIds);
  }

  void _removePromo() {
    _promoController.clear();
    ref.read(promoNotifierProvider.notifier).remove();
  }

  @override
  void dispose() {
    _cardholderNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _promoController.dispose();
    _promoFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    final digits = _cardNumberController.text.replaceAll(_cardNumberDigits, '');
    // só vai o código que o servidor já previu como válido: um código recusado
    // não bloqueia o pagamento, mas também não vai junto
    final promo = ref.read(promoNotifierProvider);
    ref
        .read(paymentNotifierProvider.notifier)
        .pay(
          bookingIds: _bookingIds,
          cardLast4: digits.substring(digits.length - 4),
          cardholderName: _cardholderNameController.text.trim(),
          promoCode: promo is PromoApplied ? promo.preview.code : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PaymentState>(paymentNotifierProvider, (previous, next) {
      if (next is PaymentPaid) widget.onPaid?.call(next);
    });

    final state = ref.watch(paymentNotifierProvider);
    final isSubmitting = state is PaymentSubmitting;
    final promo = ref.watch(promoNotifierProvider);
    // o total a pagar é o que o servidor previu; sem código, a soma das reservas
    final total = promo is PromoApplied ? promo.preview.total : _subtotal;

    return Scaffold(
      appBar: const DbookAppBar(title: 'Revisar e pagar'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OrderSummary(
                bookedLegs: widget.bookedLegs,
                items: widget.items,
                subtotal: _subtotal,
                promo: promo is PromoApplied ? promo.preview : null,
                total: total,
              ),
              const SizedBox(height: DbookSpacing.lg),
              _PromoSection(
                controller: _promoController,
                focusNode: _promoFocus,
                state: promo,
                onApply: _validatePromo,
                onRemove: _removePromo,
              ),
              const SizedBox(height: DbookSpacing.xl),
              Text(
                'Dados do cartão',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: DbookSpacing.md),
              TextFormField(
                controller: _cardholderNameController,
                autofillHints: const [AutofillHints.creditCardName],
                decoration: const InputDecoration(
                  labelText: 'Nome no cartão',
                  hintText: 'Jane Doe',
                ),
                validator: _PaymentValidators.cardholderName,
              ),
              const SizedBox(height: DbookSpacing.md),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.creditCardNumber],
                // Sem gateway de pagamento real por trás — este número
                // nunca é enviado inteiro pro backend (só os 4 últimos
                // dígitos, ver `_submit`), então sugerir um número de
                // teste aqui é só uma conveniência pra quem for testar o
                // fluxo, não uma promessa de cobrança de verdade.
                decoration: const InputDecoration(
                  labelText: 'Número do cartão',
                  hintText: '4242 4242 4242 4242',
                ),
                validator: _PaymentValidators.cardNumber,
              ),
              const SizedBox(height: DbookSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'MM/YY',
                        hintText: '12/29',
                      ),
                      validator: _PaymentValidators.expiry,
                    ),
                  ),
                  const SizedBox(width: DbookSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                      ),
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
                label: 'Pagar ${_priceFormat.format(total)}',
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
  const _OrderSummary({
    required this.bookedLegs,
    required this.items,
    required this.subtotal,
    required this.promo,
    required this.total,
  });

  final List<BookedLeg> bookedLegs;
  final List<PaidItem> items;
  final double subtotal;
  final PromoPreview? promo;
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
          Text('Resumo do pedido', style: textTheme.titleMedium),
          const SizedBox(height: DbookSpacing.md),
          for (final leg in bookedLegs) ...[
            _OrderSummaryLine(
              label:
                  '${leg.flight.originIataCode} → '
                  '${leg.flight.destinationIataCode} · Assento ${leg.seat.label}',
              value: _priceFormat.format(leg.flight.price),
            ),
            const SizedBox(height: DbookSpacing.sm),
          ],
          for (final item in items) ...[
            _OrderSummaryLine(
              label: item.label,
              value: _priceFormat.format(item.price),
            ),
            const SizedBox(height: DbookSpacing.sm),
          ],
          const Divider(),
          if (promo != null) ...[
            _OrderSummaryLine(
              label: 'Subtotal',
              value: _priceFormat.format(promo!.subtotal),
            ),
            const SizedBox(height: DbookSpacing.sm),
            _OrderSummaryLine(
              label: 'Desconto (${promo!.code})',
              value: '-${_priceFormat.format(promo!.discount)}',
            ),
            const SizedBox(height: DbookSpacing.sm),
          ],
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

/// Campo do código promocional: valida ao sair do campo, mostra o selo
/// "aplicado" (removível) ou o motivo da recusa. Mostra o que o servidor
/// previu; quem decide o desconto é o pagamento.
class _PromoSection extends StatelessWidget {
  const _PromoSection({
    required this.controller,
    required this.focusNode,
    required this.state,
    required this.onApply,
    required this.onRemove,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final PromoState state;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state case PromoApplied(:final preview)) {
      return Align(
        alignment: Alignment.centerLeft,
        child: InputChip(
          avatar: const Icon(Icons.local_offer_outlined, size: 18),
          label: Text('${preview.code} aplicado'),
          onDeleted: onRemove,
          deleteButtonTooltipMessage: 'Remover o código ${preview.code}',
        ),
      );
    }

    final validating = state is PromoValidating;
    final rejected = state is PromoRejected ? state as PromoRejected : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: !validating,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onApply(),
                decoration: InputDecoration(
                  labelText: 'Código promocional',
                  errorText: rejected?.reason,
                ),
              ),
            ),
            const SizedBox(width: DbookSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(top: DbookSpacing.xs),
              child: validating
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: onApply,
                      child: const Text('Aplicar'),
                    ),
            ),
          ],
        ),
        if (rejected != null)
          Padding(
            padding: const EdgeInsets.only(top: DbookSpacing.xs),
            child: Text(
              'O pagamento segue sem o código.',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
