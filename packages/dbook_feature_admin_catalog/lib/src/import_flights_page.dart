import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_providers.dart';
import 'csv_preview.dart';

/// Importação de voos em lote: escolher o arquivo, **conferir sem gravar**
/// (`dryRun`), ver a pré-visualização com os erros por linha e só então
/// confirmar. Nada é gravado antes do "Confirmar", e com um erro que seja o
/// servidor não grava nenhuma linha (tudo ou nada).
class ImportFlightsPage extends ConsumerStatefulWidget {
  const ImportFlightsPage({
    super.key,
    required this.onBack,
    required this.onDone,
  });

  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  ConsumerState<ImportFlightsPage> createState() => _ImportFlightsPageState();
}

class _ImportFlightsPageState extends ConsumerState<ImportFlightsPage> {
  static const _previewLimit = 200;

  PickedTextFile? _file;
  ImportReport? _report;
  ImportReport? _done;
  bool _busy = false;
  String? _error;

  Future<void> _choose() async {
    final file = await ref.read(textFilePickerProvider)();
    if (!mounted) return;
    if (file == null) {
      if (_file == null) {
        setState(() => _error = context.l10n.importNotAvailable);
      }
      return;
    }
    setState(() {
      _file = file;
      _report = null;
      _done = null;
      _error = null;
      _busy = true;
    });
    try {
      final report = await ref
          .read(catalogApiProvider)
          .importFlights(file.content, dryRun: true);
      if (mounted) setState(() => _report = report);
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error = portalErrorMessage(context.l10n, error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final file = _file;
    if (file == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(catalogApiProvider)
          .importFlights(file.content, dryRun: false);
      ref.invalidate(flightsProvider);
      if (mounted) {
        setState(() {
          if (result.hasErrors) {
            _report = result;
          } else {
            _done = result;
          }
        });
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error = portalErrorMessage(context.l10n, error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final report = _report;
    final done = _done;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DbookSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DbookBreadcrumbs(
            items: [
              DbookBreadcrumbItem(
                label: l10n.flightFormBackToList,
                onTap: widget.onBack,
              ),
              DbookBreadcrumbItem(label: l10n.importTitle),
            ],
          ),
          const SizedBox(height: DbookSpacing.md),
          Text(l10n.importTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: DbookSpacing.sm),
          Text(l10n.importIntro),
          const SizedBox(height: DbookSpacing.xs),
          Text(l10n.importColumns, style: theme.textTheme.bodySmall),
          const SizedBox(height: DbookSpacing.lg),
          Wrap(
            spacing: DbookSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DbookButton(
                label: _file == null
                    ? l10n.importChoose
                    : l10n.importChooseAnother,
                icon: Icons.upload_file,
                variant: DbookButtonVariant.secondary,
                onPressed: _busy ? null : _choose,
              ),
              if (_file != null)
                Text(_file!.name, style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: DbookSpacing.lg),
          if (_busy)
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: DbookSpacing.sm),
                Text(
                  report == null ? l10n.importChecking : l10n.importConfirming,
                ),
              ],
            ),
          if (_error != null)
            Semantics(liveRegion: true, child: DbookFieldError(_error!)),
          if (done != null) ...[
            DbookInlineStatusBanner(
              tone: DbookBannerTone.success,
              message:
                  '${l10n.importDoneTitle}. ${l10n.importSummaryDone(done.created, done.alreadyExisting)}',
            ),
            const SizedBox(height: DbookSpacing.md),
            DbookButton(
              label: l10n.flightFormBackToList,
              onPressed: widget.onDone,
            ),
          ] else if (report != null && !_busy) ...[
            if (report.hasErrors) ...[
              DbookInlineStatusBanner(
                tone: DbookBannerTone.warning,
                icon: Icons.error_outline,
                message:
                    '${l10n.importErrorsTitle} ${l10n.importLineErrors(report.errors.length)}. '
                    '${l10n.importErrorsHint}',
              ),
            ] else ...[
              DbookInlineStatusBanner(
                tone: DbookBannerTone.success,
                message:
                    '${l10n.importOkTitle} ${l10n.importSummaryOk(report.totalRows, report.toCreate, report.alreadyExisting)}',
              ),
              const SizedBox(height: DbookSpacing.md),
              DbookButton(label: l10n.importConfirm, onPressed: _confirm),
            ],
            const SizedBox(height: DbookSpacing.lg),
            _Preview(
              csv: _file!.content,
              errors: report.errors,
              limit: _previewLimit,
            ),
          ],
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.csv,
    required this.errors,
    required this.limit,
  });

  final String csv;
  final List<ImportError> errors;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final rows = parseCsv(csv);
    if (rows.isEmpty) return const SizedBox.shrink();

    final header = rows.first;
    final body = rows.skip(1).take(limit).toList();
    final errorsByLine = <int, List<String>>{};
    for (final error in errors) {
      errorsByLine.putIfAbsent(error.line, () => []).add(error.message);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.importPreviewTitle, style: theme.textTheme.titleMedium),
        if (rows.length - 1 > limit)
          Text(l10n.importPreviewTruncated, style: theme.textTheme.bodySmall),
        const SizedBox(height: DbookSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: DbookSpacing.lg,
            dataRowMinHeight: 36,
            dataRowMaxHeight: 56,
            columns: [
              DataColumn(label: Text(l10n.importColLine)),
              for (final name in header) DataColumn(label: Text(name)),
              DataColumn(label: Text(l10n.importColProblem)),
            ],
            rows: [
              for (var i = 0; i < body.length; i++)
                DataRow(
                  // linha 1 do arquivo é o cabeçalho
                  color: errorsByLine.containsKey(i + 2)
                      ? WidgetStatePropertyAll(theme.colorScheme.errorContainer)
                      : null,
                  cells: [
                    DataCell(Text('${i + 2}')),
                    for (var c = 0; c < header.length; c++)
                      DataCell(Text(c < body[i].length ? body[i][c] : '')),
                    DataCell(
                      Text(
                        (errorsByLine[i + 2] ?? const []).join(' · '),
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
