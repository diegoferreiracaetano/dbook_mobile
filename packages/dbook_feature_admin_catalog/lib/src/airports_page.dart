import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_providers.dart';

/// Aeroportos: lista, criar, editar e remover (o que nenhum voo usa).
class AirportsPage extends ConsumerWidget {
  const AirportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final result = ref.watch(airportsProvider);
    final canWrite = ref.watch(canProvider(Permission.catalogWrite));

    Future<void> edit([Airport? airport]) async {
      final saved = await showDialog<bool>(
        context: context,
        builder: (_) => _AirportDialog(airport: airport),
      );
      if ((saved ?? false) && context.mounted) {
        ref.invalidate(airportsProvider);
        showDbookToast(
          context,
          l10n.airportSaved,
          tone: DbookToastTone.success,
        );
      }
    }

    Future<void> remove(Airport airport) async {
      final confirmed = await showDbookConfirmationDialog(
        context,
        title: l10n.airportsDeleteTitle(airport.name),
        message: l10n.catalogDeleteMessage,
        confirmLabel: l10n.catalogDelete,
        cancelLabel: l10n.commonCancel,
        level: DbookConfirmLevel.destructive,
      );
      if (!confirmed || airport.id == null) return;
      try {
        await ref.read(catalogApiProvider).deleteAirport(airport.id!);
        ref.invalidate(airportsProvider);
        if (context.mounted) {
          showDbookToast(
            context,
            l10n.airportDeleted,
            tone: DbookToastTone.success,
          );
        }
      } on DbookNetworkException catch (error) {
        if (context.mounted) {
          showDbookToast(
            context,
            error is DbookConflictException
                ? l10n.catalogDeleteInUse
                : portalErrorMessage(l10n, error),
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
                  l10n.airportsTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              if (canWrite)
                DbookButton(
                  label: l10n.airportsNew,
                  icon: Icons.add,
                  onPressed: edit,
                ),
            ],
          ),
          const SizedBox(height: DbookSpacing.lg),
          Expanded(
            child: DbookDataTable<Airport>(
              semanticLabel: l10n.airportsTitle,
              columns: [
                DbookColumn(
                  id: 'code',
                  label: l10n.airportColCode,
                  width: 110,
                  cellBuilder: (a) => Text(a.iataCode),
                ),
                DbookColumn(
                  id: 'name',
                  label: l10n.airportColName,
                  width: 260,
                  cellBuilder: (a) => Text(
                    a.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DbookColumn(
                  id: 'city',
                  label: l10n.airportColCity,
                  width: 180,
                  cellBuilder: (a) => Text(a.city),
                ),
                DbookColumn(
                  id: 'country',
                  label: l10n.airportColCountry,
                  width: 140,
                  cellBuilder: (a) => Text(a.country),
                ),
                DbookColumn(
                  id: 'region',
                  label: l10n.airportColRegion,
                  width: 170,
                  cellBuilder: (a) => Text(a.region),
                ),
                DbookColumn(
                  id: 'popular',
                  label: l10n.airportColPopular,
                  width: 110,
                  cellBuilder: (a) => Icon(
                    a.isPopular ? Icons.star : Icons.star_outline,
                    semanticLabel: a.isPopular ? l10n.commonYes : l10n.commonNo,
                    size: 20,
                  ),
                ),
                if (canWrite)
                  DbookColumn(
                    id: 'actions',
                    label: l10n.teamColActions,
                    width: 100,
                    canHide: false,
                    cellBuilder: (a) => PopupMenuButton<String>(
                      tooltip: l10n.teamActionsFor(a.name),
                      icon: const Icon(Icons.more_vert),
                      onSelected: (v) => v == 'edit' ? edit(a) : remove(a),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(l10n.catalogEdit),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(l10n.catalogDelete),
                        ),
                      ],
                    ),
                  ),
              ],
              rows: result.value ?? const [],
              rowKey: (a) => a.iataCode,
              isLoading: result.isLoading && !result.hasValue,
              errorMessage: result.hasError
                  ? portalErrorMessage(l10n, result.error!)
                  : null,
              onRetry: () => ref.invalidate(airportsProvider),
              emptyTitle: l10n.commonNoResults,
              emptyMessage: l10n.tabEmptyHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _AirportDialog extends ConsumerStatefulWidget {
  const _AirportDialog({this.airport});

  final Airport? airport;

  @override
  ConsumerState<_AirportDialog> createState() => _AirportDialogState();
}

class _AirportDialogState extends ConsumerState<_AirportDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(
    text: widget.airport?.iataCode ?? '',
  );
  late final _name = TextEditingController(text: widget.airport?.name ?? '');
  late final _city = TextEditingController(text: widget.airport?.city ?? '');
  late final _country = TextEditingController(
    text: widget.airport?.country ?? '',
  );
  late final _photo = TextEditingController(
    text: widget.airport?.photoUrl ?? '',
  );
  late final _region = TextEditingController(
    text: widget.airport?.region ?? '',
  );
  late bool _popular = widget.airport?.isPopular ?? false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_code, _name, _city, _country, _photo, _region]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(catalogApiProvider)
          .saveAirport(
            Airport(
              id: widget.airport?.id,
              iataCode: _code.text,
              name: _name.text,
              city: _city.text,
              country: _country.text,
              photoUrl: _photo.text,
              region: _region.text,
              isPopular: _popular,
            ),
          );
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
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.flightFormRequired : null;

    return AlertDialog(
      title: Text(
        widget.airport == null
            ? l10n.airportFormTitleNew
            : l10n.airportFormTitleEdit,
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: DbookSpacing.md),
                ],
                DbookTextField(
                  label: l10n.airportFormCode,
                  controller: _code,
                  autofocus: true,
                  validator: (v) =>
                      RegExp(r'^[A-Za-z]{3}$').hasMatch((v ?? '').trim())
                      ? null
                      : l10n.airportCodeInvalid,
                ),
                const SizedBox(height: DbookSpacing.md),
                DbookTextField(
                  label: l10n.airportFormName,
                  controller: _name,
                  validator: required,
                ),
                const SizedBox(height: DbookSpacing.md),
                DbookTextField(
                  label: l10n.airportFormCity,
                  controller: _city,
                  validator: required,
                ),
                const SizedBox(height: DbookSpacing.md),
                DbookTextField(
                  label: l10n.airportFormCountry,
                  controller: _country,
                  validator: required,
                ),
                const SizedBox(height: DbookSpacing.md),
                DbookTextField(
                  label: l10n.airportFormRegion,
                  controller: _region,
                  validator: required,
                ),
                const SizedBox(height: DbookSpacing.md),
                DbookTextField(
                  label: l10n.airportFormPhoto,
                  controller: _photo,
                  validator: required,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _popular,
                  title: Text(l10n.airportFormPopular),
                  onChanged: (v) => setState(() => _popular = v ?? false),
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
          onPressed: _submit,
        ),
      ],
    );
  }
}
