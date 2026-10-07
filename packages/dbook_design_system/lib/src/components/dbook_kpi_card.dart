import 'package:flutter/material.dart';

import '../tokens/dbook_colors.dart';
import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';
import 'dbook_skeleton.dart';

/// Direção da variação de um indicador.
enum DbookTrend { up, down, flat }

/// Cartão de indicador do painel: rótulo, valor grande e variação. Tem os
/// três estados de um dado remoto: pronto, carregando ([isLoading]) e erro
/// ([errorMessage], com "Tentar de novo" quando há [onRetry]).
///
/// A variação nunca depende só da cor: leva seta e texto. [trendIsGood] diz se
/// subir é bom (receita) ou ruim (cancelamentos); `null` deixa neutra. Quem
/// formata o valor e a variação é quem chama (o app não calcula nem inventa
/// número: vem pronto do backend).
class DbookKpiCard extends StatelessWidget {
  const DbookKpiCard({
    super.key,
    required this.label,
    this.value,
    this.delta,
    this.trend = DbookTrend.flat,
    this.trendIsGood,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  final String label;
  final String? value;
  final String? delta;
  final DbookTrend trend;
  final bool? trendIsGood;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(DbookRadius.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DbookSpacing.sm),
            _body(context),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (errorMessage != null) return _error(context);
    if (isLoading) return _loading();
    return _ready(context);
  }

  Widget _loading() {
    return Semantics(
      label: 'Carregando $label',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DbookSkeleton(width: 96, height: 28),
          SizedBox(height: DbookSpacing.sm),
          DbookSkeleton(width: 56),
        ],
      ),
    );
  }

  Widget _error(BuildContext context) {
    final theme = Theme.of(context);
    final danger = theme.extension<DbookStatusColors>()!.danger;

    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, size: 18, color: danger),
              const SizedBox(width: DbookSpacing.xs),
              Flexible(
                child: Text(
                  errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(color: danger),
                ),
              ),
            ],
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Tentar de novo')),
        ],
      ),
    );
  }

  Widget _ready(BuildContext context) {
    final theme = Theme.of(context);
    final shown = value ?? '—';

    return Semantics(
      label: [label, shown, ?delta].join(', '),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shown,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (delta != null) ...[
            const SizedBox(height: DbookSpacing.xs),
            _deltaRow(context),
          ],
        ],
      ),
    );
  }

  Widget _deltaRow(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<DbookStatusColors>()!;
    final color = switch (trendIsGood) {
      true => statusColors.success,
      false => statusColors.danger,
      null => theme.colorScheme.onSurfaceVariant,
    };
    final icon = switch (trend) {
      DbookTrend.up => Icons.arrow_upward,
      DbookTrend.down => Icons.arrow_downward,
      DbookTrend.flat => Icons.remove,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: DbookSpacing.xxs),
        Text(
          delta!,
          style: theme.textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
