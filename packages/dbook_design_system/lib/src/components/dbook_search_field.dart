import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';

/// Campo de busca com botão circular de enviar — padrão usado nas
/// Sugestões por IA. Composição em cima de [TextField]; toda a aparência
/// de base (cor, borda, tipografia) vem do [InputDecorationTheme] do tema.
class DbookSearchField extends StatelessWidget {
  const DbookSearchField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DbookRadius.lg),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DbookRadius.lg),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
        suffixIcon: IconButton.filled(
          icon: const Icon(Icons.send),
          onPressed: () => onSubmitted(controller.text),
        ),
      ),
    );
  }
}
