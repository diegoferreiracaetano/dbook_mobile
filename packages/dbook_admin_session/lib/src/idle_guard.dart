import 'dart:async';

import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_config.dart';
import 'session_providers.dart';
import 'session_state.dart';

/// Encerra a sessão depois de [idleTimeoutProvider] sem atividade, avisando
/// [idleWarningProvider] antes (com contagem regressiva e "Continuar
/// conectado"). Atividade é mouse, toque, rolagem ou tecla. Enquanto o aviso
/// está aberto, só o botão renova: mexer o mouse não esconde o aviso.
class IdleGuard extends ConsumerStatefulWidget {
  const IdleGuard({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<IdleGuard> createState() => _IdleGuardState();
}

class _IdleGuardState extends ConsumerState<IdleGuard> {
  Timer? _warnTimer;
  Timer? _expireTimer;
  Timer? _tick;
  final _remaining = ValueNotifier<int>(0);
  bool _warning = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    _restart();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _cancelTimers();
    _remaining.dispose();
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    _activity();
    return false;
  }

  void _cancelTimers() {
    _warnTimer?.cancel();
    _expireTimer?.cancel();
    _tick?.cancel();
  }

  void _activity() {
    if (_warning) return;
    _restart();
  }

  void _restart() {
    _cancelTimers();
    final timeout = ref.read(idleTimeoutProvider);
    final warning = ref.read(idleWarningProvider);
    final untilWarning = timeout - warning;
    _warnTimer = Timer(
      untilWarning.isNegative ? Duration.zero : untilWarning,
      _showWarning,
    );
    _expireTimer = Timer(timeout, _expire);
  }

  void _showWarning() {
    if (!mounted) return;
    setState(() => _warning = true);
    _remaining.value = ref.read(idleWarningProvider).inSeconds;
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.value > 0) _remaining.value -= 1;
    });
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _IdleDialog(
        remaining: _remaining,
        onStay: () {
          Navigator.of(dialogContext).pop();
          setState(() => _warning = false);
          _restart();
        },
        onLogout: () {
          Navigator.of(dialogContext).pop();
          _expire(userChoice: true);
        },
      ),
    );
  }

  void _expire({bool userChoice = false}) {
    if (!mounted) return;
    _cancelTimers();
    final notifier = ref.read(adminSessionProvider.notifier);
    if (userChoice) {
      notifier.logout();
    } else {
      if (_warning) {
        Navigator.of(context, rootNavigator: true).maybePop();
      }
      notifier.expire(SessionEndReason.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _activity(),
      onPointerMove: (_) => _activity(),
      onPointerSignal: (_) => _activity(),
      child: widget.child,
    );
  }
}

class _IdleDialog extends StatelessWidget {
  const _IdleDialog({
    required this.remaining,
    required this.onStay,
    required this.onLogout,
  });

  final ValueListenable<int> remaining;
  final VoidCallback onStay;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.idleTitle),
      content: ValueListenableBuilder<int>(
        valueListenable: remaining,
        builder: (context, seconds, _) =>
            Semantics(liveRegion: true, child: Text(l10n.idleMessage(seconds))),
      ),
      actions: [
        TextButton(onPressed: onLogout, child: Text(l10n.idleLogout)),
        ElevatedButton(onPressed: onStay, child: Text(l10n.idleStay)),
      ],
    );
  }
}
