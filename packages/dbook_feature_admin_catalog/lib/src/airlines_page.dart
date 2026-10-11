import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_providers.dart';

/// Companhias aéreas: lista, criar, editar e remover. Só se remove o que
/// nenhum voo usa; o servidor recusa o resto (`409`) e a tela explica.
class AirlinesPage extends ConsumerWidget {
  const AirlinesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final result = ref.watch(airlinesProvider);
    final canWrite = ref.watch(canProvider(Permission.catalogWrite));

    Future<void> edit([Airline? airline]) async {
      final saved = await showDialog<bool>(
        context: context,
        builder: (_) => _AirlineDialog(airline: airline),
      );
      if ((saved ?? false) && context.mounted) {
        ref.invalidate(airlinesProvider);
        showDbookToast(
          context,
          l10n.airlineSaved,
          tone: DbookToastTone.success,
        );
      }
    }

    Future<void> remove(Airline airline) async {
      final confirmed = await showDbookConfirmationDialog(
        context,
        title: l10n.airlinesDeleteTitle(airline.name),
        message: l10n.catalogDeleteMessage,
        confirmLabel: l10n.catalogDelete,
        cancelLabel: l10n.commonCancel,
        level: DbookConfirmLevel.destructive,
      );
      if (!confirmed || airline.id == null) return;
      try {
        await ref.read(catalogApiProvider).deleteAirline(airline.id!);
        ref.invalidate(airlinesProvider);
        if (context.mounted) {
          showDbookToast(
            context,
            l10n.airlineDeleted,
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
                  l10n.airlinesTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              if (canWrite)
                DbookButton(
                  label: l10n.airlinesNew,
                  icon: Icons.add,
                  onPressed: edit,
                ),
            ],
          ),
          const SizedBox(height: DbookSpacing.lg),
          Expanded(
            child: DbookDataTable<Airline>(
              semanticLabel: l10n.airlinesTitle,
              columns: [
                DbookColumn(
                  id: 'code',
                  label: l10n.airlineColCode,
                  width: 140,
                  cellBuilder: (a) => Text(a.iataCode),
                ),
                DbookColumn(
                  id: 'name',
                  label: l10n.airlineColName,
                  width: 320,
                  cellBuilder: (a) => Text(a.name),
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
              onRetry: () => ref.invalidate(airlinesProvider),
              emptyTitle: l10n.commonNoResults,
              emptyMessage: l10n.tabEmptyHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _AirlineDialog extends ConsumerStatefulWidget {
  const _AirlineDialog({this.airline});

  final Airline? airline;

  @override
  ConsumerState<_AirlineDialog> createState() => _AirlineDialogState();
}

class _AirlineDialogState extends ConsumerState<_AirlineDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(
    text: widget.airline?.iataCode ?? '',
  );
  late final _name = TextEditingController(text: widget.airline?.name ?? '');
  late final _logo = TextEditingController(text: widget.airline?.logoUrl ?? '');
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _logo.dispose();
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
          .saveAirline(
            id: widget.airline?.id,
            iataCode: _code.text,
            name: _name.text,
            logoUrl: _logo.text,
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
    return AlertDialog(
      title: Text(
        widget.airline == null
            ? l10n.airlineFormTitleNew
            : l10n.airlineFormTitleEdit,
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                DbookFieldError(_error!),
                const SizedBox(height: DbookSpacing.md),
              ],
              DbookTextField(
                label: l10n.airlineFormCode,
                controller: _code,
                autofocus: true,
                // validação de conveniência: quem decide é o servidor
                validator: (v) =>
                    RegExp(r'^[A-Za-z0-9]{2}$').hasMatch((v ?? '').trim())
                    ? null
                    : l10n.airlineCodeInvalid,
              ),
              const SizedBox(height: DbookSpacing.lg),
              DbookTextField(
                label: l10n.airlineFormName,
                controller: _name,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.flightFormRequired
                    : null,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: DbookSpacing.lg),
              DbookTextField(
                label: l10n.airlineFormLogo,
                controller: _logo,
                keyboardType: TextInputType.url,
                validator: (v) {
                  final value = (v ?? '').trim();
                  return value.isEmpty || value.startsWith('https://')
                      ? null
                      : l10n.airlineLogoInvalid;
                },
                onSubmitted: (_) => _submit(),
              ),
              if (_logo.text.trim().startsWith('https://')) ...[
                const SizedBox(height: DbookSpacing.md),
                SizedBox(
                  height: 48,
                  child: DbookPhoto(url: _logo.text.trim(), icon: Icons.flight),
                ),
              ],
            ],
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
