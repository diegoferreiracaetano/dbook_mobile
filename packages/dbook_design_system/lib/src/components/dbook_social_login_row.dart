import 'package:flutter/material.dart';

import '../tokens/dbook_spacing.dart';

/// Botão circular de login social — ícone genérico do Material como
/// placeholder; troque por um asset de marca de verdade (respeitando as
/// diretrizes de marca de cada provedor) quando o login social for ligado
/// de fato (M2).
class DbookSocialLoginButton extends StatelessWidget {
  const DbookSocialLoginButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton.outlined(
      onPressed: onPressed,
      tooltip: label,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        side: BorderSide(color: colorScheme.outline),
        shape: const CircleBorder(),
        minimumSize: const Size(48, 48),
      ),
    );
  }
}

/// Linha "ou continue com" + botões de login social — usada no
/// Login/Cadastro.
class DbookSocialLoginRow extends StatelessWidget {
  const DbookSocialLoginRow({
    super.key,
    required this.buttons,
    this.dividerLabel = 'ou continue com',
  });

  final List<DbookSocialLoginButton> buttons;
  final String dividerLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: colorScheme.outlineVariant)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DbookSpacing.sm),
              child: Text(
                dividerLabel,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(child: Divider(color: colorScheme.outlineVariant)),
          ],
        ),
        const SizedBox(height: DbookSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < buttons.length; i++) ...[
              if (i > 0) const SizedBox(width: DbookSpacing.md),
              buttons[i],
            ],
          ],
        ),
      ],
    );
  }
}
