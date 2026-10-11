import 'package:flutter/material.dart';

/// Foto de rede que preenche o espaço dado, com um quadro neutro e um ícone
/// quando não há URL ou a imagem falha ao carregar (nunca fica um buraco nem
/// uma exceção na tela).
class DbookPhoto extends StatelessWidget {
  const DbookPhoto({
    super.key,
    required this.url,
    this.icon = Icons.image_outlined,
    this.semanticLabel,
  });

  final String? url;
  final IconData icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fallback = ColoredBox(
      color: colorScheme.surfaceContainerHigh,
      child: Center(child: Icon(icon, color: colorScheme.onSurfaceVariant)),
    );
    final photo = url;
    if (photo == null || photo.isEmpty) return fallback;
    return Image.network(
      photo,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: semanticLabel,
      errorBuilder: (_, _, _) => fallback,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback,
    );
  }
}
