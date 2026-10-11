import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';

enum PasswordStrength { weak, medium, strong }

/// As regras de senha da equipe, espelhando o servidor (mínimo de 12
/// caracteres, no máximo 72 bytes, diferente do e-mail). A lista de senhas
/// comuns só o servidor conhece: ele é a autoridade; aqui só se mostra o que
/// dá para conferir antes de enviar.
class PasswordRules {
  const PasswordRules._();

  static const minLength = 12;
  static const maxBytes = 72;

  static bool longEnough(String password) => password.length >= minLength;

  static bool notTooLong(String password) =>
      password.codeUnits.length <= maxBytes;

  static bool differsFromEmail(String password, String email) =>
      password.isNotEmpty && password.toLowerCase() != email.toLowerCase();

  static bool acceptable(String password, String email) =>
      longEnough(password) &&
      notTooLong(password) &&
      differsFromEmail(password, email);

  /// Indicador de força (só orientação, não é regra do servidor).
  static PasswordStrength strength(String password) {
    if (password.length < minLength) return PasswordStrength.weak;
    final kinds = [
      RegExp('[a-z]'),
      RegExp('[A-Z]'),
      RegExp('[0-9]'),
      RegExp('[^A-Za-z0-9]'),
    ].where((pattern) => pattern.hasMatch(password)).length;
    if (password.length >= 16 && kinds >= 3) return PasswordStrength.strong;
    return kinds >= 3 ? PasswordStrength.medium : PasswordStrength.weak;
  }
}

/// Os requisitos **visíveis antes do erro**, cada um marcado quando cumprido,
/// mais o indicador de força.
class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({
    super.key,
    required this.password,
    required this.email,
  });

  final String password;
  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final strength = PasswordRules.strength(password);
    final (label, color) = switch (strength) {
      PasswordStrength.weak => (
        l10n.passwordStrengthWeak,
        theme.extension<DbookStatusColors>()!.danger,
      ),
      PasswordStrength.medium => (
        l10n.passwordStrengthMedium,
        theme.extension<DbookStatusColors>()!.warning,
      ),
      PasswordStrength.strong => (
        l10n.passwordStrengthStrong,
        theme.extension<DbookStatusColors>()!.success,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.passwordRequirementsTitle, style: theme.textTheme.labelLarge),
        const SizedBox(height: DbookSpacing.xs),
        _Rule(l10n.passwordReqLength, PasswordRules.longEnough(password)),
        _Rule(l10n.passwordReqMax, PasswordRules.notTooLong(password)),
        _Rule(
          l10n.passwordReqNotEmail,
          PasswordRules.differsFromEmail(password, email),
        ),
        _Rule(l10n.passwordReqNotCommon, null),
        if (password.isNotEmpty) ...[
          const SizedBox(height: DbookSpacing.sm),
          Semantics(
            liveRegion: true,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
          ),
        ],
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule(this.text, this.met);

  final String text;

  /// `null` = não dá para conferir aqui (o servidor confere).
  final bool? met;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final success = theme.extension<DbookStatusColors>()!.success;
    final (icon, color) = switch (met) {
      true => (Icons.check_circle, success),
      false => (
        Icons.radio_button_unchecked,
        theme.colorScheme.onSurfaceVariant,
      ),
      null => (Icons.info_outline, theme.colorScheme.onSurfaceVariant),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DbookSpacing.xxs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: DbookSpacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
