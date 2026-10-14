import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';
import 'dbook_skeleton.dart';

/// Carregamento padrão de tela/lista: linhas de esqueleto (shimmer) com o
/// formato do conteúdo que vai chegar. Em espaço pequeno (diálogos, faixas
/// inline) cai para o círculo, que cabe em qualquer lugar.
class DbookLoadingIndicator extends StatelessWidget {
  const DbookLoadingIndicator({super.key, this.message});

  final String? message;

  /// Abaixo dessa altura disponível não há espaço para linhas de esqueleto.
  static const double _minSkeletonHeight = 200;
  static const double _rowHeight = 88;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        if (height.isFinite && height < _minSkeletonHeight) {
          return _Spinner(message: message);
        }
        final rows = height.isFinite
            ? ((height - 48) / (_rowHeight + DbookSpacing.md)).floor().clamp(
                2,
                6,
              )
            : 3;
        return Semantics(
          label: message ?? 'Carregando',
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.all(DbookSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message != null) ...[
                  Text(message!, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: DbookSpacing.md),
                ],
                for (var i = 0; i < rows; i++) ...[
                  const _SkeletonRow(),
                  if (i < rows - 1) const SizedBox(height: DbookSpacing.md),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DbookLoadingIndicator._rowHeight,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(DbookRadius.md),
            child: const DbookSkeleton(width: 88, height: 88),
          ),
          const SizedBox(width: DbookSpacing.md),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DbookSkeleton(height: 16),
                SizedBox(height: DbookSpacing.sm),
                DbookSkeleton(width: 140),
                SizedBox(height: DbookSpacing.sm),
                DbookSkeleton(width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: DbookSpacing.md),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
