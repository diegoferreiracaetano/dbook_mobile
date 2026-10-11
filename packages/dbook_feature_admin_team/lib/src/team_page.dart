import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'team_dialogs.dart';
import 'team_providers.dart';

/// Equipe e convites. O que cada pessoa pode fazer com quem aparece aqui é
/// decidido pelo servidor; a tela só **explica** (em vez de esconder) por que
/// uma ação está desligada: o próprio usuário e o último acesso total.
class TeamPage extends ConsumerWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(DbookSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.teamTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                DbookButton(
                  label: l10n.teamInvite,
                  icon: Icons.person_add_alt,
                  onPressed: () => _invite(context, ref),
                ),
              ],
            ),
            const SizedBox(height: DbookSpacing.md),
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: l10n.teamTabStaff),
                Tab(text: l10n.teamTabInvitations),
              ],
            ),
            const Expanded(
              child: TabBarView(children: [_StaffTable(), _InvitationsTable()]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => const InviteDialog(),
    );
    if (sent ?? false) {
      ref.invalidate(invitationsProvider);
      if (context.mounted) {
        showDbookToast(
          context,
          context.l10n.inviteSent,
          tone: DbookToastTone.success,
        );
      }
    }
  }
}

/// Roda uma ação do servidor e avisa o resultado; recarrega a lista se der
/// certo.
Future<void> _perform(
  BuildContext context,
  WidgetRef ref, {
  required Future<void> Function() action,
  required String success,
  required VoidCallback reload,
}) async {
  final l10n = context.l10n;
  try {
    await action();
    reload();
    if (context.mounted) {
      showDbookToast(context, success, tone: DbookToastTone.success);
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

class _StaffTable extends ConsumerWidget {
  const _StaffTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final staff = ref.watch(staffProvider);
    final me = ref.watch(staffProfileProvider);
    final members = staff.value ?? const <StaffMember>[];
    final activeSuperAdmins = members
        .where((m) => m.role == Role.superAdmin && !m.isBlocked)
        .toList();

    String? blockedReason(StaffMember member) {
      if (member.id == me?.id) return l10n.teamSelfReason;
      if (member.role == Role.superAdmin &&
          !member.isBlocked &&
          activeSuperAdmins.length == 1) {
        return l10n.teamLastSuperAdminReason;
      }
      return null;
    }

    return DbookDataTable<StaffMember>(
      semanticLabel: l10n.teamTitle,
      columns: [
        DbookColumn(
          id: 'name',
          label: l10n.teamColName,
          width: 260,
          cellBuilder: (m) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                m.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        DbookColumn(
          id: 'role',
          label: l10n.teamColRole,
          width: 150,
          cellBuilder: (m) => Text(roleLabel(l10n, m.role)),
        ),
        DbookColumn(
          id: 'status',
          label: l10n.teamColStatus,
          width: 130,
          cellBuilder: (m) => DbookStatusBadge(
            status: switch (m.status) {
              StaffStatus.active => DbookStatus.confirmed,
              StaffStatus.blocked => DbookStatus.cancelled,
              StaffStatus.unknown => DbookStatus.unknown,
            },
            label: switch (m.status) {
              StaffStatus.active => l10n.teamStatusActive,
              StaffStatus.blocked => l10n.teamStatusBlocked,
              StaffStatus.unknown => l10n.teamStatusUnknown,
            },
            showIcon: true,
          ),
        ),
        DbookColumn(
          id: 'last',
          label: l10n.teamColLastAccess,
          width: 170,
          cellBuilder: (m) => Text(
            m.lastLoginAt == null
                ? l10n.teamNeverAccessed
                : PortalFormats.dateTime(m.lastLoginAt!),
          ),
        ),
        DbookColumn(
          id: 'actions',
          label: l10n.teamColActions,
          width: 90,
          canHide: false,
          cellBuilder: (m) =>
              _RowMenu(member: m, blockedReason: blockedReason(m)),
        ),
      ],
      rows: members,
      rowKey: (m) => m.id,
      isLoading: staff.isLoading && !staff.hasValue,
      errorMessage: staff.hasError
          ? portalErrorMessage(l10n, staff.error!)
          : null,
      onRetry: () => ref.invalidate(staffProvider),
      emptyTitle: l10n.teamEmpty,
      emptyMessage: l10n.teamEmptyMessage,
    );
  }
}

class _RowMenu extends ConsumerWidget {
  const _RowMenu({required this.member, required this.blockedReason});

  final StaffMember member;
  final String? blockedReason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final disabled = blockedReason != null;

    return PopupMenuButton<String>(
      tooltip: l10n.teamActionsFor(member.name),
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => _onSelected(context, ref, value),
      itemBuilder: (context) => [
        if (disabled)
          PopupMenuItem<String>(
            enabled: false,
            child: SizedBox(
              width: DbookSizes.tooltipText,
              child: Text(blockedReason!),
            ),
          ),
        PopupMenuItem(
          value: 'role',
          enabled: !disabled,
          child: Text(l10n.teamChangeRole),
        ),
        PopupMenuItem(
          value: member.isBlocked ? 'unblock' : 'block',
          enabled: !disabled || member.isBlocked,
          child: Text(member.isBlocked ? l10n.teamUnblock : l10n.teamBlock),
        ),
      ],
    );
  }

  Future<void> _onSelected(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    final l10n = context.l10n;
    switch (value) {
      case 'role':
        final changed = await showDialog<bool>(
          context: context,
          builder: (_) => ChangeRoleDialog(member: member),
        );
        if ((changed ?? false) && context.mounted) {
          ref.invalidate(staffProvider);
          showDbookToast(
            context,
            l10n.teamRoleChanged,
            tone: DbookToastTone.success,
          );
        }
      case 'block':
        final blocked = await showDialog<bool>(
          context: context,
          builder: (_) => BlockDialog(member: member),
        );
        if ((blocked ?? false) && context.mounted) {
          ref.invalidate(staffProvider);
          showDbookToast(
            context,
            l10n.teamBlocked,
            tone: DbookToastTone.success,
          );
        }
      case 'unblock':
        final confirmed = await showDbookConfirmationDialog(
          context,
          title: l10n.teamUnblockTitle(member.name),
          message: l10n.teamUnblockMessage(member.name),
          confirmLabel: l10n.teamUnblock,
          cancelLabel: l10n.commonCancel,
        );
        if (confirmed && context.mounted) {
          await _perform(
            context,
            ref,
            action: () => ref.read(teamApiProvider).unblock(member.id),
            success: l10n.teamUnblocked,
            reload: () => ref.invalidate(staffProvider),
          );
        }
    }
  }
}

class _InvitationsTable extends ConsumerWidget {
  const _InvitationsTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final invitations = ref.watch(invitationsProvider);

    String statusLabel(InvitationStatus status) => switch (status) {
      InvitationStatus.pending => l10n.inviteStatusPending,
      InvitationStatus.accepted => l10n.inviteStatusAccepted,
      InvitationStatus.expired => l10n.inviteStatusExpired,
      InvitationStatus.revoked => l10n.inviteStatusRevoked,
      InvitationStatus.unknown => l10n.inviteStatusUnknown,
    };

    return DbookDataTable<Invitation>(
      semanticLabel: l10n.teamTabInvitations,
      columns: [
        DbookColumn(
          id: 'email',
          label: l10n.inviteColEmail,
          width: 260,
          cellBuilder: (i) =>
              Text(i.email, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        DbookColumn(
          id: 'role',
          label: l10n.inviteColRole,
          width: 150,
          cellBuilder: (i) => Text(roleLabel(l10n, i.role)),
        ),
        DbookColumn(
          id: 'status',
          label: l10n.inviteColStatus,
          width: 130,
          cellBuilder: (i) => DbookStatusBadge(
            status: switch (i.status) {
              InvitationStatus.pending => DbookStatus.pending,
              InvitationStatus.accepted => DbookStatus.confirmed,
              InvitationStatus.expired ||
              InvitationStatus.revoked => DbookStatus.cancelled,
              InvitationStatus.unknown => DbookStatus.unknown,
            },
            label: statusLabel(i.status),
            showIcon: true,
          ),
        ),
        DbookColumn(
          id: 'expires',
          label: l10n.inviteColExpires,
          width: 170,
          cellBuilder: (i) => Text(
            i.expiresAt == null
                ? l10n.commonNone
                : PortalFormats.dateTime(i.expiresAt!),
          ),
        ),
        DbookColumn(
          id: 'actions',
          label: l10n.teamColActions,
          width: 90,
          canHide: false,
          cellBuilder: (i) => i.isOpen
              ? _InvitationMenu(invitation: i)
              : const SizedBox.shrink(),
        ),
      ],
      rows: invitations.value ?? const [],
      rowKey: (i) => i.id,
      isLoading: invitations.isLoading && !invitations.hasValue,
      errorMessage: invitations.hasError
          ? portalErrorMessage(l10n, invitations.error!)
          : null,
      onRetry: () => ref.invalidate(invitationsProvider),
      emptyTitle: l10n.inviteEmpty,
      emptyMessage: l10n.inviteEmptyMessage,
    );
  }
}

class _InvitationMenu extends ConsumerWidget {
  const _InvitationMenu({required this.invitation});

  final Invitation invitation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return PopupMenuButton<String>(
      tooltip: l10n.teamActionsFor(invitation.email),
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        final api = ref.read(teamApiProvider);
        if (value == 'resend') {
          await _perform(
            context,
            ref,
            action: () => api.resendInvitation(invitation.id),
            success: l10n.inviteResent,
            reload: () => ref.invalidate(invitationsProvider),
          );
          return;
        }
        final confirmed = await showDbookConfirmationDialog(
          context,
          title: l10n.inviteRevokeTitle(invitation.email),
          message: l10n.inviteRevokeMessage,
          confirmLabel: l10n.inviteRevoke,
          cancelLabel: l10n.commonCancel,
          level: DbookConfirmLevel.destructive,
        );
        if (confirmed && context.mounted) {
          await _perform(
            context,
            ref,
            action: () => api.revokeInvitation(invitation.id),
            success: l10n.inviteRevoked,
            reload: () => ref.invalidate(invitationsProvider),
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'resend', child: Text(l10n.inviteResend)),
        PopupMenuItem(value: 'revoke', child: Text(l10n.inviteRevoke)),
      ],
    );
  }
}
