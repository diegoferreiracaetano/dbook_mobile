import 'package:flutter/material.dart';

import '../tokens/dbook_colors.dart';

Widget _liveError(BuildContext context, String error) {
  final danger = Theme.of(context).extension<DbookStatusColors>()!.danger;
  return Semantics(
    liveRegion: true,
    child: Text(error, style: TextStyle(color: danger)),
  );
}

/// Campo de texto com rótulo, ajuda e validação **em linha**: o erro aparece
/// logo depois que o usuário mexe no campo (não só ao enviar) e é anunciado
/// pelo leitor de tela. Composição sobre [TextFormField]; o visual vem do
/// `inputDecorationTheme`.
class DbookTextField extends StatelessWidget {
  const DbookTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.helperText,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.autofocus = false,
    this.onSubmitted,
    this.textInputAction,
    this.autofillHints,
    this.focusNode,
    this.suffix,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? helperText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final AutovalidateMode autovalidateMode;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;

  /// Controle à direita do campo (ex.: mostrar/ocultar senha).
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      autofocus: autofocus,
      onFieldSubmitted: onSubmitted,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      focusNode: focusNode,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      autovalidateMode: autovalidateMode,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        suffixIcon: suffix,
      ),
      errorBuilder: _liveError,
    );
  }
}

/// Texto de várias linhas com contador de caracteres ("12/500") quando há
/// [maxLength]. É um [DbookTextField] com mais linhas.
class DbookTextArea extends StatelessWidget {
  const DbookTextArea({
    super.key,
    required this.label,
    this.controller,
    this.helperText,
    this.validator,
    this.onChanged,
    this.maxLength,
    this.minLines = 3,
    this.enabled = true,
  });

  final String label;
  final TextEditingController? controller;
  final String? helperText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final int minLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      minLines: minLines,
      maxLines: minLines + 3,
      maxLength: maxLength,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        alignLabelWithHint: true,
      ),
      errorBuilder: _liveError,
    );
  }
}

/// Opção de um [DbookSelect].
class DbookSelectOption<T> {
  const DbookSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Lista de escolha única com a mesma validação em linha dos outros campos.
class DbookSelect<T> extends StatelessWidget {
  const DbookSelect({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.validator,
    this.enabled = true,
  });

  final String label;
  final List<DbookSelectOption<T>> options;
  final ValueChanged<T?> onChanged;
  final T? value;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final option in options)
          DropdownMenuItem(value: option.value, child: Text(option.label)),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}

/// Campo de período: mostra "01/10/2026 – 07/10/2026" e abre o seletor de
/// intervalo do Material ao tocar. Sem [value] mostra o [label] como dica.
class DbookDateRange extends StatelessWidget {
  const DbookDateRange({
    super.key,
    required this.label,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.value,
    this.validator,
  });

  final String label;
  final DateTimeRange? value;
  final ValueChanged<DateTimeRange> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final FormFieldValidator<DateTimeRange>? validator;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTimeRange>(
      initialValue: value,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        final current = value ?? state.value;
        return InkWell(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: firstDate,
              lastDate: lastDate,
              initialDateRange: current,
            );
            if (picked == null) return;
            state.didChange(picked);
            onChanged(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              suffixIcon: const Icon(Icons.date_range_outlined),
              error: state.errorText == null
                  ? null
                  : _liveError(context, state.errorText!),
            ),
            child: Text(
              current == null ? ' ' : _format(current),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        );
      },
    );
  }

  static String _format(DateTimeRange range) {
    String day(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
    return '${day(range.start)} – ${day(range.end)}';
  }
}
