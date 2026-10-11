import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';

/// Logo da companhia aérea. Com [logoUrl] mostra a imagem sobre fundo claro
/// (logos são feitos para fundo branco, em qualquer tema); sem URL, ou se a
/// imagem falhar, cai no selo com o código IATA sobre [color], para nunca
/// ficar um buraco na linha do voo.
class DbookAirlineLogo extends StatelessWidget {
  const DbookAirlineLogo({
    super.key,
    required this.iataCode,
    required this.color,
    this.logoUrl,
    this.size = 36,
  });

  final String iataCode;
  final Color color;
  final String? logoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DbookRadius.sm),
      ),
      child: Text(
        iataCode,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
    final url = logoUrl;
    if (url == null || url.isEmpty) return badge;

    return ClipRRect(
      borderRadius: BorderRadius.circular(DbookRadius.sm),
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        padding: EdgeInsets.all(size * 0.08),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          semanticLabel: 'Logo da companhia $iataCode',
          errorBuilder: (_, _, _) => badge,
        ),
      ),
    );
  }
}
