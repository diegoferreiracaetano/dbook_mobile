import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'team_providers.dart';

/// Escolha de papel com a descrição do que cada um pode fazer.
class _RolePicker extends StatelessWidget {
  const _RolePicker({
    required this.roles,
    required this.value,
    required this.onChanged,
  });

  final List<Role> roles;
  final Role? value;
  final ValueChanged<Role?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RadioGroup<Role>(
      groupValue: value,
      onChanged: onChanged,
      child: Column(
        children: [
          for (final role in roles)
            RadioListTile<Role>(
              contentPadding: EdgeInsets.zero,
              value: role,
              title: Text(roleLabel(l10n, role)),
              subtitle: Text(roleDescription(l10n, role)),
            ),
        ],
      ),
    );
  }
}

class InviteDialog extends ConsumerStatefulWidget {
  const InviteDialog({super.key});

  @override
  ConsumerState<InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends ConsumerState<InviteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  Role? _role = Role.support;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
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
          .read(teamApiProvider)
          .invite(email: _email.text.trim(), role: _role!);
      if (mounted) Navigator.of(context).pop(true);
    } on DbookNetworkException catch (error) {
      if (!mounted) return;
      final l10n = context.l10n;
      setState(() {
        _error = error is DbookConflictException
            ? l10n.inviteAlreadyHasAccount
            : portalErrorMessage(l10n, error);
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.inviteTitle),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  label: l10n.inviteEmail,
                  controller: _email,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? l10n.inviteInvalidEmail
                      : null,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: DbookSpacing.lg),
                Text(
                  l10n.inviteRole,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                _RolePicker(
                  roles: invitableRoles,
                  value: _role,
                  onChanged: (role) => setState(() => _role = role),
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
          label: l10n.inviteSubmit,
          isLoading: _busy,
          onPressed: _submit,
        ),
      ],
    );
  }
}

class ChangeRoleDialog extends ConsumerStatefulWidget {
  const ChangeRoleDialog({super.key, required this.member});

  final StaffMember member;

  @override
  ConsumerState<ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends ConsumerState<ChangeRoleDialog> {
  Role? _role;
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    final role = _role;
    if (_busy || role == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(teamApiProvider)
          .changeRole(id: widget.member.id, role: role);
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
    final name = widget.member.name;
    return AlertDialog(
      title: Text(l10n.teamChangeRoleTitle(name)),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.teamChangeRoleConsequence(name)),
              const SizedBox(height: DbookSpacing.md),
              if (_error != null) ...[
                DbookFieldError(_error!),
                const SizedBox(height: DbookSpacing.md),
              ],
              _RolePicker(
                roles: [
                  for (final role in invitableRoles)
                    if (role != widget.member.role) role,
                ],
                value: _role,
                onChanged: (role) => setState(() => _role = role),
              ),
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
          label: l10n.teamChangeRoleSubmit,
          isLoading: _busy,
          onPressed: _role == null ? null : _submit,
        ),
      ],
    );
  }
}

class BlockDialog extends ConsumerStatefulWidget {
  const BlockDialog({super.key, required this.member});

  final StaffMember member;

  @override
  ConsumerState<BlockDialog> createState() => _BlockDialogState();
}

class _BlockDialogState extends ConsumerState<BlockDialog> {
  final _reason = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reason.text.trim();
    if (_busy || reason.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(teamApiProvider)
          .block(id: widget.member.id, reason: reason);
      ref
          .read(draftStoreProvider.notifier)
          .clear('team-block-${widget.member.id}');
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
    final name = widget.member.name;
    final danger = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l10n.teamBlockTitle(name)),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.teamBlockConsequence(name)),
              const SizedBox(height: DbookSpacing.md),
              if (_error != null) ...[
                DbookFieldError(_error!),
                const SizedBox(height: DbookSpacing.md),
              ],
              DraftGuard(
                draftKey: 'team-block-${widget.member.id}',
                controller: _reason,
                child: DbookTextArea(
                  label: l10n.teamBlockReason,
                  controller: _reason,
                  maxLength: 200,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: danger.error,
            foregroundColor: danger.onError,
          ),
          onPressed: _busy ? null : _submit,
          child: Text(l10n.teamBlock),
        ),
      ],
    );
  }
}
