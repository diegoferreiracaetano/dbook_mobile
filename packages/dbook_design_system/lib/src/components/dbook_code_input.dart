import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

/// Campo de código numérico em caixas separadas (código de 6 dígitos do
/// autenticador). Avança sozinho ao digitar, volta com Backspace numa caixa
/// vazia e **aceita colar** o código inteiro em qualquer caixa. [onCompleted]
/// dispara quando todas as caixas estão preenchidas.
class DbookCodeInput extends StatefulWidget {
  const DbookCodeInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.enabled = true,
    this.autofocus = true,
    this.errorText,
    this.semanticLabel = 'Código',
  });

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;
  final String? errorText;
  final String semanticLabel;

  @override
  State<DbookCodeInput> createState() => DbookCodeInputState();
}

class DbookCodeInputState extends State<DbookCodeInput> {
  late final List<TextEditingController> _controllers = List.generate(
    widget.length,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _nodes = List.generate(
    widget.length,
    (index) => FocusNode(onKeyEvent: (node, event) => _onKey(index, event)),
  );

  String get value => _controllers.map((c) => c.text).join();

  /// Apaga tudo e volta ao primeiro dígito (depois de um código recusado).
  void clear() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _nodes.first.requestFocus();
    widget.onChanged?.call('');
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _nodes[index - 1].requestFocus();
      widget.onChanged?.call(value);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onChanged(int index, String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      _controllers[index].text = '';
      widget.onChanged?.call(value);
      return;
    }
    // Colar espalha os dígitos a partir desta caixa; digitar um preenche só ela.
    var cursor = index;
    for (final digit in digits.split('')) {
      if (cursor >= widget.length) break;
      _controllers[cursor].text = digit;
      cursor++;
    }
    if (cursor < widget.length) {
      _nodes[cursor].requestFocus();
    } else {
      _nodes[widget.length - 1].requestFocus();
    }
    widget.onChanged?.call(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.length; i++) ...[
                if (i > 0) const SizedBox(width: DbookSpacing.sm),
                SizedBox(
                  width: 44,
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _nodes[i],
                    enabled: widget.enabled,
                    autofocus: widget.autofocus && i == 0,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: theme.textTheme.titleLarge,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    onChanged: (text) => _onChanged(i, text),
                    decoration: InputDecoration(
                      isDense: true,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: DbookSpacing.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DbookRadius.sm),
                        borderSide: BorderSide(
                          color: hasError
                              ? theme.colorScheme.error
                              : theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (hasError) ...[
            const SizedBox(height: DbookSpacing.xs),
            Semantics(
              liveRegion: true,
              child: Text(
                widget.errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
