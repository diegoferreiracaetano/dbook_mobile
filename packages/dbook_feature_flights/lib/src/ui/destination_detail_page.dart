import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/destination_reviews_notifier.dart';
import 'destination_gradient.dart';

/// Detalhe de um destino: a nota média, quantas avaliações há de cada nota
/// e a lista delas (por rolagem). Quem escreveu uma avaliação pode editá-la
/// ou apagá-la (com alguns segundos para desfazer); as dos outros podem ser
/// denunciadas. Tudo isso só aparece com sessão.
class DestinationDetailPage extends ConsumerStatefulWidget {
  const DestinationDetailPage({super.key, required this.destination});

  final Destination destination;

  @override
  ConsumerState<DestinationDetailPage> createState() =>
      _DestinationDetailPageState();
}

class _DestinationDetailPageState extends ConsumerState<DestinationDetailPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) {
        _notifier.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  DestinationReviewsNotifier get _notifier => ref.read(
    destinationReviewsNotifierProvider(widget.destination.iataCode).notifier,
  );

  void _tell(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _message(Object error) => error is DbookNetworkException
      ? error.message
      : 'Não foi possível concluir. Tente de novo.';

  Future<void> _edit(PublicReview review) async {
    final result = await showDialog<({int rating, String comment})>(
      context: context,
      builder: (_) => _EditReviewDialog(review: review),
    );
    if (result == null) return;
    try {
      await _notifier.edit(
        review,
        rating: result.rating,
        comment: result.comment,
      );
      _tell('Avaliação atualizada.');
    } on Object catch (error) {
      _tell(_message(error));
    }
  }

  /// Apagar: some da lista na hora, mostra "Desfazer" por alguns segundos e só
  /// então apaga no servidor. Se a pessoa desfaz, volta ao lugar.
  Future<void> _delete(PublicReview review) async {
    final confirmed = await showDbookConfirmationDialog(
      context,
      title: 'Apagar sua avaliação?',
      message: 'Ela some do destino e da média. Você terá alguns segundos para desfazer.',
      confirmLabel: 'Apagar',
      level: DbookConfirmLevel.destructive,
    );
    if (!confirmed || !mounted) return;
    final index = _notifier.hideLocally(review);
    final undone = await showDbookUndoSnackbar(
      context,
      'Avaliação apagada',
      duration: const Duration(seconds: 5),
    );
    if (undone) {
      _notifier.restore(review, index);
      return;
    }
    try {
      await _notifier.commitDelete(review, index);
    } on Object catch (error) {
      _tell(_message(error));
    }
  }

  Future<void> _report(PublicReview review) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _ReportDialog(),
    );
    if (reason == null) return;
    try {
      await _notifier.report(review, reason);
      _tell('Denúncia enviada. A equipe vai analisar.');
    } on Object catch (error) {
      _tell(_message(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;
    final state = ref.watch(
      destinationReviewsNotifierProvider(destination.iataCode),
    );
    final own = ref.watch(ownReviewIdsProvider);
    final loggedIn = ref.watch(isLoggedInProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: DbookAppBar(
        title: destination.city,
        subtitle: destination.country,
      ),
      body: RefreshIndicator(
        onRefresh: _notifier.refresh,
        child: ListView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              height: 160,
              decoration: destinationBackground(destination),
            ),
            Padding(
              padding: const EdgeInsets.all(DbookSpacing.lg),
              child: _content(context, state, own, loggedIn, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    DestinationReviewsState state,
    Set<int> own,
    bool loggedIn,
    ThemeData theme,
  ) {
    if (state.isLoading && state.summary == null) {
      return const SizedBox(
        height: DbookSizes.loadingMd,
        child: DbookLoadingIndicator(),
      );
    }
    if (state.error != null && state.summary == null) {
      return DbookStatusPlaceholder(
        icon: Icons.error_outline,
        title: 'Não deu para carregar as avaliações',
        message: _message(state.error!),
        actionLabel: 'Tentar de novo',
        onAction: _notifier.refresh,
      );
    }
    final summary = state.summary!;
    if (summary.total == 0) {
      return const DbookStatusPlaceholder(
        icon: Icons.rate_review_outlined,
        title: 'Ainda sem avaliações',
        message: 'Quem viajar para cá e avaliar a viagem aparece nesta lista.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryBlock(summary: summary),
        const SizedBox(height: DbookSpacing.lg),
        SegmentedButton<ReviewSort>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: ReviewSort.recent,
              label: Text('Mais recentes'),
            ),
            ButtonSegment(
              value: ReviewSort.rating,
              label: Text('Melhores notas'),
            ),
          ],
          selected: {state.sort},
          onSelectionChanged: (s) => _notifier.setSort(s.first),
        ),
        const SizedBox(height: DbookSpacing.md),
        for (final review in state.items)
          _ReviewTile(
            review: review,
            isMine: own.contains(review.id),
            loggedIn: loggedIn,
            onEdit: () => _edit(review),
            onDelete: () => _delete(review),
            onReport: () => _report(review),
          ),
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(DbookSpacing.lg),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (state.loadMoreError != null)
          Center(
            child: TextButton(
              onPressed: _notifier.loadMore,
              child: const Text('Não deu para carregar mais. Tentar de novo'),
            ),
          ),
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars(this.rating);

  final int rating;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Semantics(
      label: '$rating de 5 estrelas',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 1; i <= 5; i++)
              Icon(
                i <= rating ? Icons.star : Icons.star_border,
                size: 16,
                color: color,
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({required this.summary});

  final ReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final average = summary.average;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              average == null ? '—' : average.toStringAsFixed(1),
              style: theme.textTheme.displaySmall,
            ),
            _Stars(average?.round() ?? 0),
            const SizedBox(height: DbookSpacing.xs),
            Text(
              '${summary.total} avaliações',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(width: DbookSpacing.xl),
        Expanded(
          child: Column(
            children: [
              for (var stars = 5; stars >= 1; stars--)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: DbookSpacing.xxs,
                  ),
                  child: Semantics(
                    label:
                        '${summary.countFor(stars)} avaliações com $stars estrelas',
                    excludeSemantics: true,
                    child: Row(
                      children: [
                        SizedBox(
                          width: DbookSizes.labelColumn,
                          child: Text('$stars'),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(DbookRadius.xs),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value: summary.total == 0
                                  ? 0
                                  : summary.countFor(stars) / summary.total,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${summary.countFor(stars)}',
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.review,
    required this.isMine,
    required this.loggedIn,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
  });

  final PublicReview review;
  final bool isMine;
  final bool loggedIn;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = review.createdAt == null
        ? ''
        : DateFormat('dd/MM/yyyy').format(review.createdAt!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DbookSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Stars(review.rating),
                    const SizedBox(width: DbookSpacing.sm),
                    Flexible(
                      child: Text(
                        '${isMine ? 'Você' : review.author}${date.isEmpty ? '' : ' · $date'}'
                        '${review.edited ? ' · editada' : ''}',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DbookSpacing.xs),
                // sempre como texto: nada do que o cliente escreve é HTML
                Text(review.comment),
              ],
            ),
          ),
          if (loggedIn)
            PopupMenuButton<String>(
              tooltip: 'Mais ações',
              onSelected: (value) => switch (value) {
                'edit' => onEdit(),
                'delete' => onDelete(),
                _ => onReport(),
              },
              itemBuilder: (_) => isMine
                  ? const [
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'delete', child: Text('Apagar')),
                    ]
                  : const [
                      PopupMenuItem(value: 'report', child: Text('Denunciar')),
                    ],
            ),
        ],
      ),
    );
  }
}

class _EditReviewDialog extends StatefulWidget {
  const _EditReviewDialog({required this.review});

  final PublicReview review;

  @override
  State<_EditReviewDialog> createState() => _EditReviewDialogState();
}

class _EditReviewDialogState extends State<_EditReviewDialog> {
  late int _rating = widget.review.rating;
  late final _comment = TextEditingController(text: widget.review.comment);

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _comment.text.trim();
    return AlertDialog(
      title: const Text('Editar avaliação'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DbookRatingStars(
            rating: _rating,
            onRatingSelected: (v) => setState(() => _rating = v),
          ),
          TextField(
            controller: _comment,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Comentário'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        DbookButton(
          label: 'Salvar',
          onPressed: text.isEmpty || _rating == 0
              ? null
              : () =>
                    Navigator.of(context).pop((rating: _rating, comment: text)),
        ),
      ],
    );
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final length = _reason.text.trim().length;
    return AlertDialog(
      title: const Text('Denunciar avaliação'),
      content: TextField(
        controller: _reason,
        maxLines: 3,
        maxLength: 500,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          labelText: 'O que há de errado? (mínimo de 3 caracteres)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        DbookButton(
          label: 'Denunciar',
          onPressed: length < 3
              ? null
              : () => Navigator.of(context).pop(_reason.text.trim()),
        ),
      ],
    );
  }
}
