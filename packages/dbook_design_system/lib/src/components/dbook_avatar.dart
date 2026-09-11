import 'package:flutter/material.dart';

/// Tamanhos disponíveis do [DbookAvatar].
enum DbookAvatarSize { small, medium, large }

/// Avatar circular — foto (via [image]) ou iniciais (via [initials]),
/// nos tamanhos padrão do design system. Composição em cima de
/// [CircleAvatar]; a cor de fallback vem do `ColorScheme` do tema.
class DbookAvatar extends StatelessWidget {
  const DbookAvatar({
    super.key,
    this.image,
    this.initials,
    this.size = DbookAvatarSize.medium,
  }) : assert(image != null || initials != null, 'Informe image ou initials.');

  final ImageProvider? image;
  final String? initials;
  final DbookAvatarSize size;

  double get _radius => switch (size) {
    DbookAvatarSize.small => 16,
    DbookAvatarSize.medium => 22,
    DbookAvatarSize.large => 28,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: _radius,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      backgroundImage: image,
      child: image == null && initials != null ? Text(initials!) : null,
    );
  }
}
