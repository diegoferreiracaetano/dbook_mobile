import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';

/// Um cartão de seção do painel (título e conteúdo).
class DashboardSection extends StatelessWidget {
  const DashboardSection({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final Widget? actions;

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
          children: [
            Wrap(
              spacing: DbookSpacing.md,
              runSpacing: DbookSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                ?actions,
              ],
            ),
            const SizedBox(height: DbookSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

String metricLabel(AppLocalizations l10n, DashboardMetric metric) =>
    switch (metric) {
      DashboardMetric.revenue => l10n.metricRevenue,
      DashboardMetric.bookings => l10n.metricBookings,
      DashboardMetric.newCustomers => l10n.metricNewCustomers,
    };

String formatMetric(DashboardMetric metric, double value) =>
    metric == DashboardMetric.revenue
    ? PortalFormats.money(value)
    : PortalFormats.integer(value.round());
