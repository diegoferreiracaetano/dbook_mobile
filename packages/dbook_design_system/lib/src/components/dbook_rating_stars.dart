import 'package:flutter/material.dart';

/// Seletor de nota por estrelas (1 a 5) — usado pra avaliar uma reserva.
/// Sem estado próprio: [rating] é a nota atual (0 = nenhuma escolhida
/// ainda), tocar uma estrela chama [onRatingSelected] com o novo valor —
/// mesmo padrão de seleção controlada do [DbookChipRow].
class DbookRatingStars extends StatelessWidget {
  const DbookRatingStars({
    super.key,
    required this.rating,
    required this.onRatingSelected,
  });

  final int rating;
  final ValueChanged<int> onRatingSelected;

  static const _starCount = 5;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_starCount, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= rating;

        return IconButton(
          onPressed: () => onRatingSelected(starValue),
          icon: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: colorScheme.primary,
          ),
        );
      }),
    );
  }
}
