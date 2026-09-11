import 'package:flutter/material.dart';

/// App bar do DBook — cor sólida (via `appBarTheme`) por padrão, ou
/// [transparent] pra sobrepor uma imagem (foreground branco, sem
/// elevação). Aceita [subtitle] opcional (ex. "Tue, Jan 13, 2026" sob o
/// nome do destino).
class DbookAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DbookAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.transparent = false,
    this.leading,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final bool transparent;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = transparent ? Colors.white : null;

    return AppBar(
      leading: leading,
      actions: actions,
      backgroundColor: transparent ? Colors.transparent : null,
      elevation: transparent ? 0 : null,
      foregroundColor: foreground,
      title: subtitle == null
          ? Text(title)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(color: foreground),
                ),
                Text(
                  subtitle!,
                  style: textTheme.bodySmall?.copyWith(
                    color: transparent
                        ? Colors.white70
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
