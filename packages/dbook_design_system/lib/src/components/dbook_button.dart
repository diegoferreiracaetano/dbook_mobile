import 'package:flutter/material.dart';

import '../tokens/dbook_spacing.dart';

/// Variante visual do [DbookButton] — mapeia direto pro widget Material
/// correspondente (`ElevatedButton`/`OutlinedButton`/`TextButton`), que já
/// vem estilizado pelo [DbookTheme].
enum DbookButtonVariant { primary, secondary, text }

/// Botão do design system. É uma composição fina em cima dos botões nativos
/// do Material 3 — a aparência (cor, formato, tipografia) vem inteira do
/// tema; este widget só resolve o estado de **loading**, que o Material não
/// tem nativamente, pra nenhuma feature reimplementar esse padrão sozinha.
class DbookButton extends StatelessWidget {
  const DbookButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = DbookButtonVariant.primary,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final DbookButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final child = _buildChild(context);

    return switch (variant) {
      DbookButtonVariant.primary => ElevatedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      DbookButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      DbookButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
    };
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _loadingColor(context),
        ),
      );
    }

    if (icon == null) {
      return Text(label);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: DbookSpacing.sm),
        Text(label),
      ],
    );
  }

  Color _loadingColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (variant) {
      DbookButtonVariant.primary => colorScheme.onPrimary,
      DbookButtonVariant.secondary ||
      DbookButtonVariant.text => colorScheme.primary,
    };
  }
}
