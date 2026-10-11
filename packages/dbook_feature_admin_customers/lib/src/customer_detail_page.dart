import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'customer_dialogs.dart';
import 'customer_tabs.dart';
import 'customers_providers.dart';

/// A visão 360º de um cliente: cabeçalho, indicadores, ações de moderação e
/// abas (reservas, pagamentos, avaliações, notas, histórico). Cada aba só
/// busca quando é aberta.
class CustomerDetailPage extends ConsumerStatefulWidget {
  const CustomerDetailPage({super.key, required this.id, required this.onBack});

  final int id;
  final VoidCallback onBack;

  @override
  ConsumerState<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends ConsumerState<CustomerDetailPage>
    with SingleTickerProviderStateMixin {
  late final bool _showHistory = ref.read(canProvider(Permission.auditRead));
  late final TabController _tabs = TabController(
    length: _showHistory ? 5 : 4,
    vsync: this,
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _block(CustomerDetail customer) async {
    final done = await showDialog<bool>(
      context: context,
      builder: (_) => BlockCustomerDialog(customer: customer),
    );
    if ((done ?? false) && mounted) {
      ref.invalidate(customerDetailProvider(widget.id));
      showDbookToast(
        context,
        context.l10n.customerBlocked,
        tone: DbookToastTone.success,
      );
    }
  }

  Future<void> _unblock(CustomerDetail customer) async {
    final l10n = context.l10n;
    final confirmed = await showDbookConfirmationDialog(
      context,
      title: l10n.customerUnblockTitle(customer.name),
      message: l10n.customerUnblockMessage,
      confirmLabel: l10n.customerUnblock,
      cancelLabel: l10n.commonCancel,
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(customersApiProvider).unblock(customer.id);
      ref.invalidate(customerDetailProvider(widget.id));
      if (mounted) {
        showDbookToast(
          context,
          l10n.customerUnblocked,
          tone: DbookToastTone.success,
        );
      }
    } on Object catch (error) {
      if (mounted) {
        showDbookToast(
          context,
          portalErrorMessage(l10n, error),
          tone: DbookToastTone.danger,
        );
      }
    }
  }

  Future<void> _anonymize(CustomerDetail customer) async {
    final done = await showDialog<bool>(
      context: context,
      builder: (_) => AnonymizeCustomerDialog(customer: customer),
    );
    if ((done ?? false) && mounted) {
      ref.invalidate(customerDetailProvider(widget.id));
      showDbookToast(
        context,
        context.l10n.customerAnonymizedDone,
        tone: DbookToastTone.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = ref.watch(customerDetailProvider(widget.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DbookSpacing.xl),
      child: detail.when(
        loading: () => const SizedBox(
          height: DbookSizes.loadingLg,
          child: DbookLoadingIndicator(),
        ),
        error: (error, _) => SizedBox(
          height: 320,
          child: DbookErrorState(
            message: portalErrorMessage(l10n, error),
            onRetry: () => ref.invalidate(customerDetailProvider(widget.id)),
          ),
        ),
        data: _content,
      ),
    );
  }

  Widget _content(CustomerDetail customer) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final canNote = ref.watch(canProvider(Permission.customerNote));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DbookBreadcrumbs(
          items: [
            DbookBreadcrumbItem(
              label: l10n.customerBackToList,
              onTap: widget.onBack,
            ),
            DbookBreadcrumbItem(label: customer.name),
          ],
        ),
        const SizedBox(height: DbookSpacing.md),
        Wrap(
          spacing: DbookSpacing.md,
          runSpacing: DbookSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(customer.name, style: theme.textTheme.headlineSmall),
            DbookStatusBadge(
              status: customer.isBlocked
                  ? DbookStatus.cancelled
                  : DbookStatus.confirmed,
              label: customer.isAnonymized
                  ? l10n.customerAnonymizedBadge
                  : (customer.isBlocked
                        ? l10n.customerStatusBlocked
                        : l10n.customerStatusActive),
              showIcon: true,
            ),
          ],
        ),
        Text(
          [
            customer.email,
            if (customer.createdAt != null)
              l10n.customerSince(PortalFormats.date(customer.createdAt!)),
            customer.lastLoginAt == null
                ? l10n.customerNeverAccessed
                : l10n.customerLastAccess(
                    PortalFormats.dateTime(customer.lastLoginAt!),
                  ),
          ].join(' · '),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (customer.isBlocked) ...[
          const SizedBox(height: DbookSpacing.md),
          SizedBox(
            width: double.infinity,
            child: DbookInlineStatusBanner(
              tone: DbookBannerTone.warning,
              icon: Icons.block,
              message: l10n.customerBlockedBanner(
                customer.blockedAt == null
                    ? l10n.commonNone
                    : PortalFormats.date(customer.blockedAt!),
                customer.blockedReason ?? l10n.commonNone,
              ),
            ),
          ),
        ],
        if (customer.isAnonymized) ...[
          const SizedBox(height: DbookSpacing.md),
          SizedBox(
            width: double.infinity,
            child: DbookInlineStatusBanner(
              tone: DbookBannerTone.info,
              icon: Icons.privacy_tip_outlined,
              message: l10n.customerAnonymizedBanner(
                PortalFormats.date(customer.anonymizedAt!),
              ),
            ),
          ),
        ],
        const SizedBox(height: DbookSpacing.lg),
        Wrap(
          spacing: DbookSpacing.md,
          runSpacing: DbookSpacing.md,
          children: [
            SizedBox(
              width: 220,
              child: DbookKpiCard(
                label: l10n.kpiBookings,
                value: PortalFormats.integer(customer.bookings.total),
              ),
            ),
            SizedBox(
              width: 220,
              child: DbookKpiCard(
                label: l10n.kpiTotalPaid,
                value: customer.totalPaid == null
                    ? null
                    : PortalFormats.money(customer.totalPaid!),
              ),
            ),
            SizedBox(
              width: 220,
              child: DbookKpiCard(
                label: l10n.kpiAverageRating,
                value: customer.averageRating == null
                    ? l10n.kpiNoRating
                    : '${customer.averageRating!.toStringAsFixed(1)} / 5',
              ),
            ),
          ],
        ),
        if (!customer.isAnonymized) ...[
          const SizedBox(height: DbookSpacing.lg),
          Wrap(
            spacing: DbookSpacing.sm,
            runSpacing: DbookSpacing.sm,
            children: [
              PermissionGate(
                permission: Permission.customerBlock,
                child: customer.isBlocked
                    ? DbookButton(
                        label: l10n.customerUnblock,
                        variant: DbookButtonVariant.secondary,
                        onPressed: () => _unblock(customer),
                      )
                    : DbookButton(
                        label: l10n.customerBlock,
                        icon: Icons.block,
                        variant: DbookButtonVariant.secondary,
                        onPressed: () => _block(customer),
                      ),
              ),
              PermissionGate(
                permission: Permission.customerErase,
                child: DbookButton(
                  label: l10n.customerAnonymize,
                  icon: Icons.delete_forever_outlined,
                  variant: DbookButtonVariant.secondary,
                  onPressed: () => _anonymize(customer),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: DbookSpacing.xl),
        TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: l10n.tabBookings),
            Tab(text: l10n.tabPayments),
            Tab(text: l10n.tabReviews),
            Tab(text: l10n.tabNotes),
            if (_showHistory) Tab(text: l10n.tabHistory),
          ],
        ),
        const SizedBox(height: DbookSpacing.md),
        SizedBox(
          height: 480,
          child: ListenableBuilder(
            listenable: _tabs,
            builder: (context, _) => switch (_tabs.index) {
              0 => BookingsTab(customerId: customer.id),
              1 => PaymentsTab(customerId: customer.id),
              2 => ReviewsTab(customerId: customer.id),
              3 => NotesTab(customerId: customer.id, canWrite: canNote),
              _ => HistoryTab(customerId: customer.id),
            },
          ),
        ),
      ],
    );
  }
}
