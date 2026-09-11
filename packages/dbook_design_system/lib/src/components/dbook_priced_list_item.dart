import 'package:flutter/material.dart';

/// Item de lista com preço em destaque à direita — ex. extras opcionais
/// (seleção de assento, bagagem) em Passageiro & Extras.
class DbookPricedListItem extends StatelessWidget {
  const DbookPricedListItem({
    super.key,
    required this.icon,
    required this.title,
    required this.price,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String price;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Text(
        price,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: colorScheme.primary),
      ),
    );
  }
}
