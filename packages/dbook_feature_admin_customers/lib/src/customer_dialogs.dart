import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'customers_providers.dart';

/// O mínimo de caracteres do motivo de bloqueio e de anonimização, o mesmo
/// que o servidor exige (`reason` de 10 ou mais, aparado).
const customerReasonMinLength = 10;

/// Corpo comum dos diálogos de moderação: texto de consequência, erro do
/// servidor, e o botão que executa. O servidor continua sendo a autoridade.
class _ModerationDialog extends StatelessWidget {
  const _ModerationDialog({
    required this.title,
    required this.children,
    required this.confirmLabel,
    required this.onConfirm,
    required this.busy,
    required this.destructive,
    required this.canConfirm,
  });

  final String title;
  final List<Widget> children;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final bool busy;
  final bool destructive;
  final bool canConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          style: destructive
              ? ElevatedButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                )
              : null,
          onPressed: busy || !canConfirm ? null : onConfirm,
          child: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(confirmLabel),
        ),
      ],
    );
  }
}

class BlockCustomerDialog extends ConsumerStatefulWidget {
  const BlockCustomerDialog({super.key, required this.customer});

  final CustomerDetail customer;

  @override
  ConsumerState<BlockCustomerDialog> createState() =>
      _BlockCustomerDialogState();
}

class _BlockCustomerDialogState extends ConsumerState<BlockCustomerDialog> {
  final _reason = TextEditingController();
  bool _busy = false;
  String? _error;

  String get _draftKey => 'customer-block-${widget.customer.id}';

  @override
  void initState() {
    super.initState();
    _reason.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(customersApiProvider)
          .block(widget.customer.id, _reason.text.trim());
      ref.read(draftStoreProvider.notifier).clear(_draftKey);
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = portalErrorMessage(context.l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final count = _reason.text.trim().length;

    return _ModerationDialog(
      title: l10n.customerBlockTitle(widget.customer.name),
      confirmLabel: l10n.customerBlockSubmit,
      destructive: true,
      busy: _busy,
      canConfirm: count >= customerReasonMinLength,
      onConfirm: _submit,
      children: [
        Text(l10n.customerBlockMessage),
        const SizedBox(height: DbookSpacing.md),
        if (_error != null) ...[
          DbookFieldError(_error!),
          const SizedBox(height: DbookSpacing.md),
        ],
        DraftGuard(
          draftKey: _draftKey,
          controller: _reason,
          child: DbookTextArea(
            label: l10n.customerBlockReason,
            controller: _reason,
            maxLength: 300,
            helperText: l10n.customerBlockReasonCounter(
              customerReasonMinLength,
              count,
            ),
          ),
        ),
      ],
    );
  }
}

class AnonymizeCustomerDialog extends ConsumerStatefulWidget {
  const AnonymizeCustomerDialog({super.key, required this.customer});

  final CustomerDetail customer;

  @override
  ConsumerState<AnonymizeCustomerDialog> createState() =>
      _AnonymizeCustomerDialogState();
}

class _AnonymizeCustomerDialogState
    extends ConsumerState<AnonymizeCustomerDialog> {
  final _reason = TextEditingController();
  final _phrase = TextEditingController();
  bool _busy = false;
  String? _error;

  /// A frase que o servidor exige: com o **id**, para que apagar o cliente
  /// errado não passe.
  String get _expected => 'ANONYMIZE ${widget.customer.id}';

  @override
  void initState() {
    super.initState();
    _reason.addListener(() => setState(() {}));
    _phrase.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reason.dispose();
    _phrase.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(customersApiProvider)
          .anonymize(
            widget.customer.id,
            reason: _reason.text.trim(),
            confirmation: _phrase.text,
          );
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = portalErrorMessage(context.l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ready =
        _reason.text.trim().length >= customerReasonMinLength &&
        _phrase.text == _expected;

    return _ModerationDialog(
      title: l10n.customerAnonymizeTitle(widget.customer.name),
      confirmLabel: l10n.customerAnonymizeSubmit,
      destructive: true,
      busy: _busy,
      canConfirm: ready,
      onConfirm: _submit,
      children: [
        Text(l10n.customerAnonymizeConsequence),
        const SizedBox(height: DbookSpacing.md),
        if (_error != null) ...[
          DbookFieldError(_error!),
          const SizedBox(height: DbookSpacing.md),
        ],
        DbookTextArea(
          label: l10n.customerAnonymizeReason,
          controller: _reason,
          maxLength: 300,
          helperText: l10n.customerBlockReasonCounter(
            customerReasonMinLength,
            _reason.text.trim().length,
          ),
        ),
        const SizedBox(height: DbookSpacing.md),
        Text(l10n.customerAnonymizePhrase(_expected)),
        const SizedBox(height: DbookSpacing.xs),
        DbookTextField(label: _expected, controller: _phrase),
      ],
    );
  }
}

/// Nova nota ou edição ([note] preenchida): o texto guardado fica em rascunho
/// enquanto se escreve.
class NoteEditorDialog extends ConsumerStatefulWidget {
  const NoteEditorDialog({super.key, required this.customerId, this.note});

  final int customerId;
  final CustomerNote? note;

  @override
  ConsumerState<NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends ConsumerState<NoteEditorDialog> {
  late final _body = TextEditingController(text: widget.note?.body ?? '');
  bool _busy = false;
  String? _error;

  String get _draftKey =>
      'customer-note-${widget.customerId}-${widget.note?.id ?? 'new'}';

  @override
  void initState() {
    super.initState();
    _body.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(customersApiProvider);
    try {
      final note = widget.note;
      if (note == null) {
        await api.addNote(widget.customerId, body: _body.text.trim());
      } else {
        await api.updateNote(
          widget.customerId,
          note.id,
          body: _body.text.trim(),
        );
      }
      ref.read(draftStoreProvider.notifier).clear(_draftKey);
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = portalErrorMessage(context.l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _ModerationDialog(
      title: widget.note == null ? l10n.noteAdd : l10n.noteEdit,
      confirmLabel: l10n.commonSave,
      destructive: false,
      busy: _busy,
      canConfirm: _body.text.trim().isNotEmpty,
      onConfirm: _submit,
      children: [
        if (_error != null) ...[
          DbookFieldError(_error!),
          const SizedBox(height: DbookSpacing.md),
        ],
        DraftGuard(
          draftKey: _draftKey,
          controller: _body,
          child: DbookTextArea(
            label: l10n.noteLabel,
            controller: _body,
            maxLength: 1000,
            minLines: 4,
          ),
        ),
      ],
    );
  }
}

/// Exportar os clientes que os filtros atuais mostram: explica o que será
/// exportado e o teto antes, mostra progresso, e entrega o arquivo.
Future<void> exportCustomers(
  BuildContext context,
  WidgetRef ref,
  CustomerQuery query,
) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ExportDialog(query: query),
  );
}

class _ExportDialog extends ConsumerStatefulWidget {
  const _ExportDialog({required this.query});

  final CustomerQuery query;

  @override
  ConsumerState<_ExportDialog> createState() => _ExportDialogState();
}

enum _ExportStep { confirm, running, done, failed }

class _ExportDialogState extends ConsumerState<_ExportDialog> {
  _ExportStep _step = _ExportStep.confirm;
  String? _error;

  String _filters(AppLocalizations l10n) {
    final q = widget.query;
    final parts = [
      if (q.text.trim().isNotEmpty) '"${q.text.trim()}"',
      if (q.status == CustomerStatus.active) l10n.customersFilterActive,
      if (q.status == CustomerStatus.blocked) l10n.customersFilterBlocked,
      if (q.hasBookings == true) l10n.customersFilterWithBookings,
      if (q.hasBookings == false) l10n.customersFilterWithoutBookings,
      if (q.from != null && q.to != null)
        '${PortalFormats.date(q.from!)} – ${PortalFormats.date(q.to!)}',
    ];
    return parts.isEmpty ? l10n.exportAllCustomers : parts.join(', ');
  }

  Future<void> _run() async {
    setState(() => _step = _ExportStep.running);
    try {
      final file = await ref.read(customersApiProvider).export(widget.query);
      final saved = downloadFile(
        name: file.name,
        bytes: file.bytes,
        mimeType: file.mimeType,
      );
      if (!mounted) return;
      setState(() {
        _step = saved ? _ExportStep.done : _ExportStep.failed;
        _error = saved ? null : context.l10n.exportNotAvailable;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _step = _ExportStep.failed;
        _error = portalErrorMessage(context.l10n, error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.exportTitle),
      content: SizedBox(
        width: 460,
        child: switch (_step) {
          _ExportStep.confirm => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.exportMessage(_filters(l10n))),
              const SizedBox(height: DbookSpacing.sm),
              Text(l10n.exportCeiling),
              const SizedBox(height: DbookSpacing.sm),
              Text(l10n.exportContents),
            ],
          ),
          _ExportStep.running => Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: DbookSpacing.md),
              Expanded(child: Text(l10n.exportRunning)),
            ],
          ),
          _ExportStep.done => Text(l10n.exportDone),
          _ExportStep.failed => DbookFieldError(_error ?? l10n.errGeneric),
        },
      ),
      actions: [
        if (_step == _ExportStep.confirm) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          DbookButton(label: l10n.exportStart, onPressed: _run),
        ] else if (_step == _ExportStep.failed) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonClose),
          ),
          DbookButton(label: l10n.commonRetry, onPressed: _run),
        ] else if (_step == _ExportStep.done)
          DbookButton(
            label: l10n.commonClose,
            onPressed: () => Navigator.of(context).pop(),
          ),
      ],
    );
  }
}
