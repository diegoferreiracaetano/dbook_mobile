import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'governance_providers.dart';

/// Os códigos promocionais: criar, mudar a janela e os limites, ligar e
/// desligar (nunca apagar: pagamentos que o usaram apontam para ele). A regra
/// de cada um aparece em linguagem natural.
class PromosPage extends ConsumerWidget {
  const PromosPage({
    super.key,
    required this.query,
    required this.onQueryChanged,
  });

  final PromoQuery query;
  final ValueChanged<PromoQuery> onQueryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final result = ref.watch(promosProvider(query));
    final page = result.value;

    Future<void> edit([Promo? promo]) async {
      final saved = await showDialog<bool>(
        context: context,
        builder: (_) => _PromoDialog(promo: promo),
      );
      if ((saved ?? false) && context.mounted) {
        ref.invalidate(promosProvider);
        showDbookToast(context, l10n.promoSaved, tone: DbookToastTone.success);
      }
    }

    Future<void> toggle(Promo promo) async {
      if (promo.active) {
        final confirmed = await showDbookConfirmationDialog(
          context,
          title: l10n.promoDeactivateTitle(promo.code),
          message: l10n.promoDeactivateMessage,
          confirmLabel: l10n.promoDeactivate,
          cancelLabel: l10n.commonCancel,
          level: DbookConfirmLevel.destructive,
        );
        if (!confirmed) return;
      }
      try {
        await ref
            .read(governanceApiProvider)
            .setPromoActive(promo.id, active: !promo.active);
        ref.invalidate(promosProvider);
        if (context.mounted) {
          showDbookToast(
            context,
            promo.active ? l10n.promoDeactivated : l10n.promoActivated,
            tone: DbookToastTone.success,
          );
        }
      } on Object catch (error) {
        if (context.mounted) {
          showDbookToast(
            context,
            portalErrorMessage(l10n, error),
            tone: DbookToastTone.danger,
          );
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(DbookSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.promosTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              DbookButton(
                label: l10n.promosNew,
                icon: Icons.add,
                onPressed: edit,
              ),
            ],
          ),
          const SizedBox(height: DbookSpacing.lg),
          Wrap(
            spacing: DbookSpacing.sm,
            children: [
              ChoiceChip(
                label: Text(l10n.promoFilterAll),
                selected: query.active == null,
                onSelected: (_) =>
                    onQueryChanged((active: null, page: 0, size: query.size)),
              ),
              ChoiceChip(
                label: Text(l10n.promoFilterActive),
                selected: query.active == true,
                onSelected: (_) =>
                    onQueryChanged((active: true, page: 0, size: query.size)),
              ),
              ChoiceChip(
                label: Text(l10n.promoFilterOff),
                selected: query.active == false,
                onSelected: (_) =>
                    onQueryChanged((active: false, page: 0, size: query.size)),
              ),
            ],
          ),
          const SizedBox(height: DbookSpacing.md),
          Expanded(
            child: DbookDataTable<Promo>(
              semanticLabel: l10n.promosTitle,
              columns: [
                DbookColumn(
                  id: 'code',
                  label: l10n.promoColCode,
                  width: 150,
                  cellBuilder: (p) => Text(p.code, style: DbookTypography.mono),
                ),
                DbookColumn(
                  id: 'rule',
                  label: l10n.promoColRule,
                  width: 380,
                  cellBuilder: (p) => Text(
                    describePromo(l10n, p),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DbookColumn(
                  id: 'usage',
                  label: l10n.promoColUsage,
                  width: 120,
                  cellBuilder: (p) => Text(
                    p.maxRedemptions == null
                        ? l10n.promoUsageUnlimited(p.redeemed)
                        : l10n.promoUsage(p.redeemed, p.maxRedemptions!),
                  ),
                ),
                DbookColumn(
                  id: 'window',
                  label: l10n.promoColWindow,
                  width: 230,
                  cellBuilder: (p) => Text(
                    p.validFrom == null || p.validUntil == null
                        ? l10n.commonNone
                        : l10n.promoWindow(
                            PortalFormats.date(p.validFrom!.toLocal()),
                            PortalFormats.date(p.validUntil!.toLocal()),
                          ),
                  ),
                ),
                DbookColumn(
                  id: 'status',
                  label: l10n.promoColStatus,
                  width: 120,
                  cellBuilder: (p) => DbookStatusBadge(
                    status: p.active
                        ? DbookStatus.confirmed
                        : DbookStatus.unknown,
                    label: p.active
                        ? l10n.promoStatusActive
                        : l10n.promoStatusOff,
                    showIcon: true,
                  ),
                ),
                DbookColumn(
                  id: 'actions',
                  label: l10n.teamColActions,
                  width: 90,
                  canHide: false,
                  cellBuilder: (p) => PopupMenuButton<String>(
                    tooltip: l10n.teamActionsFor(p.code),
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      switch (value) {
                        case 'edit':
                          await edit(p);
                        case 'toggle':
                          await toggle(p);
                        case 'redemptions':
                          await showDialog<void>(
                            context: context,
                            builder: (_) => _RedemptionsDialog(promo: p),
                          );
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'edit', child: Text(l10n.promoEdit)),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(
                          p.active ? l10n.promoDeactivate : l10n.promoActivate,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'redemptions',
                        child: Text(l10n.promoRedemptionsAction),
                      ),
                    ],
                  ),
                ),
              ],
              rows: page?.items ?? const [],
              rowKey: (p) => p.id,
              isLoading: result.isLoading && !result.hasValue,
              errorMessage: result.hasError
                  ? portalErrorMessage(l10n, result.error!)
                  : null,
              onRetry: () => ref.invalidate(promosProvider(query)),
              emptyTitle: l10n.promosEmpty,
              emptyMessage: l10n.promosEmptyMessage,
              pagination: DbookPagination(
                page: page?.page ?? query.page,
                pageSize: query.size,
                total: page?.totalElements ?? 0,
                onPageChanged: (p) => onQueryChanged((
                  active: query.active,
                  page: p,
                  size: query.size,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoDialog extends ConsumerStatefulWidget {
  const _PromoDialog({this.promo});

  final Promo? promo;

  @override
  ConsumerState<_PromoDialog> createState() => _PromoDialogState();
}

class _PromoDialogState extends ConsumerState<_PromoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(text: widget.promo?.code ?? '');
  late final _value = TextEditingController(
    text: widget.promo == null ? '' : widget.promo!.value.toString(),
  );
  late final _min = TextEditingController(
    text: widget.promo == null || widget.promo!.minAmount == 0
        ? ''
        : widget.promo!.minAmount.toString(),
  );
  late final _maxTotal = TextEditingController(
    text: widget.promo?.maxRedemptions?.toString() ?? '',
  );
  late final _maxPerUser = TextEditingController(
    text: widget.promo?.maxPerUser.toString() ?? '',
  );
  late PromoType _type = widget.promo?.type == PromoType.fixed
      ? PromoType.fixed
      : PromoType.percent;
  late DateTime _from = widget.promo?.validFrom?.toLocal() ?? DateTime.now();
  late DateTime _until =
      widget.promo?.validUntil?.toLocal() ??
      DateTime.now().add(const Duration(days: 30));
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.promo != null;

  @override
  void dispose() {
    for (final c in [_code, _value, _min, _maxTotal, _maxPerUser]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pick(bool start) async {
    final initial = start ? _from : _until;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() => start ? _from = picked : _until = picked);
  }

  Future<void> _submit() async {
    if (_busy || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final form = PromoForm(
      code: _code.text,
      type: _type,
      value: double.parse(_value.text.replaceAll(',', '.')),
      minAmount: _min.text.trim().isEmpty
          ? null
          : double.parse(_min.text.replaceAll(',', '.')),
      validFrom: _from,
      validUntil: _until,
      maxRedemptions: _maxTotal.text.trim().isEmpty
          ? null
          : int.parse(_maxTotal.text.trim()),
      maxPerUser: _maxPerUser.text.trim().isEmpty
          ? null
          : int.parse(_maxPerUser.text.trim()),
    );
    final api = ref.read(governanceApiProvider);
    try {
      if (_isEdit) {
        await api.updatePromo(widget.promo!.id, form);
      } else {
        await api.createPromo(form);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on DbookNetworkException catch (error) {
      if (!mounted) return;
      setState(() => _error = portalErrorMessage(context.l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    String? optionalNumber(String? v) {
      if (v == null || v.trim().isEmpty) return null;
      return double.tryParse(v.replaceAll(',', '.')) == null
          ? l10n.promoValueInvalid
          : null;
    }

    String? optionalInt(String? v) {
      if (v == null || v.trim().isEmpty) return null;
      final n = int.tryParse(v.trim());
      return n == null || n <= 0 ? l10n.promoValueInvalid : null;
    }

    return AlertDialog(
      title: Text(_isEdit ? l10n.promoFormTitleEdit : l10n.promoFormTitleNew),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null) ...[
                  DbookFieldError(_error!),
                  const SizedBox(height: DbookSpacing.md),
                ],
                if (_isEdit) ...[
                  Text(
                    l10n.promoFormImmutable,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: DbookSpacing.md),
                ],
                DbookTextField(
                  label: l10n.promoFormCode,
                  controller: _code,
                  enabled: !_isEdit,
                  autofocus: !_isEdit,
                  validator: (v) =>
                      RegExp(r'^[A-Za-z0-9_-]{3,32}$')
                          .hasMatch((v ?? '').trim())
                      ? null
                      : l10n.promoCodeInvalid,
                ),
                const SizedBox(height: DbookSpacing.md),
                DropdownButtonFormField<PromoType>(
                  initialValue: _type,
                  decoration: InputDecoration(labelText: l10n.promoFormType),
                  items: [
                    DropdownMenuItem(
                      value: PromoType.percent,
                      child: Text(l10n.promoTypePercent),
                    ),
                    DropdownMenuItem(
                      value: PromoType.fixed,
                      child: Text(l10n.promoTypeFixed),
                    ),
                  ],
                  onChanged: _isEdit
                      ? null
                      : (v) => setState(() => _type = v ?? _type),
                ),
                const SizedBox(height: DbookSpacing.md),
                DbookTextField(
                  label: _type == PromoType.percent
                      ? l10n.promoFormValuePercent
                      : l10n.promoFormValueFixed,
                  controller: _value,
                  enabled: !_isEdit,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                    if (n == null || n <= 0) return l10n.promoValueInvalid;
                    return _type == PromoType.percent && n >= 100
                        ? l10n.promoValueInvalid
                        : null;
                  },
                ),
                const SizedBox(height: DbookSpacing.md),
                DbookTextField(
                  label: l10n.promoFormMin,
                  controller: _min,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: optionalNumber,
                ),
                const SizedBox(height: DbookSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pick(true),
                        child: Text(
                          '${l10n.promoFormFrom}: ${PortalFormats.dateTime(_from)}',
                        ),
                      ),
                    ),
                    const SizedBox(width: DbookSpacing.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pick(false),
                        child: Text(
                          '${l10n.promoFormUntil}: ${PortalFormats.dateTime(_until)}',
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_until.isAfter(_from))
                  Padding(
                    padding: const EdgeInsets.only(top: DbookSpacing.xs),
                    child: Text(
                      l10n.promoWindowInvalid,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: DbookSpacing.md),
                DbookTextField(
                  label: l10n.promoFormMaxTotal,
                  controller: _maxTotal,
                  keyboardType: TextInputType.number,
                  validator: optionalInt,
                ),
                const SizedBox(height: DbookSpacing.md),
                DbookTextField(
                  label: l10n.promoFormMaxPerUser,
                  controller: _maxPerUser,
                  keyboardType: TextInputType.number,
                  validator: optionalInt,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        DbookButton(
          label: l10n.commonSave,
          isLoading: _busy,
          onPressed: _until.isAfter(_from) ? _submit : null,
        ),
      ],
    );
  }
}

class _RedemptionsDialog extends ConsumerWidget {
  const _RedemptionsDialog({required this.promo});

  final Promo promo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final result = ref.watch(promoRedemptionsProvider(promo.id));

    return AlertDialog(
      title: Text(l10n.promoRedemptionsTitle(promo.code)),
      content: SizedBox(
        width: 640,
        height: 380,
        child: DbookDataTable<PromoRedemption>(
          semanticLabel: l10n.promoRedemptionsTitle(promo.code),
          columns: [
            DbookColumn(
              id: 'customer',
              label: l10n.promoRedeemColCustomer,
              width: 200,
              cellBuilder: (r) => Text(r.userName),
            ),
            DbookColumn(
              id: 'payment',
              label: l10n.promoRedeemColPayment,
              width: 120,
              cellBuilder: (r) => Text('#${r.paymentId}'),
            ),
            DbookColumn(
              id: 'discount',
              label: l10n.promoRedeemColDiscount,
              width: 120,
              numeric: true,
              cellBuilder: (r) => Text(PortalFormats.money(r.discount)),
            ),
            DbookColumn(
              id: 'date',
              label: l10n.promoRedeemColDate,
              width: 170,
              cellBuilder: (r) => Text(
                r.createdAt == null
                    ? l10n.commonNone
                    : PortalFormats.dateTime(r.createdAt!.toLocal()),
              ),
            ),
          ],
          rows: result.value ?? const [],
          rowKey: (r) => r.paymentId,
          isLoading: result.isLoading && !result.hasValue,
          errorMessage: result.hasError
              ? portalErrorMessage(l10n, result.error!)
              : null,
          onRetry: () => ref.invalidate(promoRedemptionsProvider(promo.id)),
          emptyTitle: l10n.promoRedemptionsEmpty,
          emptyMessage: l10n.tabEmptyHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}
