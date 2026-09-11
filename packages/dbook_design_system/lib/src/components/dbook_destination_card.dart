import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

/// Card de destino — imagem de fundo com um degradê escuro embaixo e
/// título/subtítulo sobrepostos (usado em "Explorar destinos").
class DbookDestinationCard extends StatelessWidget {
  const DbookDestinationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.background,
    this.onTap,
  });

  final String title;
  final String subtitle;

  /// Gradiente ou imagem de fundo — quem chama decide (nem toda tela tem
  /// foto real disponível; um `LinearGradient` também é válido aqui).
  final Decoration background;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DbookRadius.lg),
      child: Material(
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: background,
            child: Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(DbookSpacing.md),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0x99000000), Color(0x00000000)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
