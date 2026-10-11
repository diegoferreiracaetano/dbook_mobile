import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Conta bloqueada pela equipe: uma tela só, em vez de uma sequência de erros
/// soltos. Acontece no login (depois de a senha estar certa) ou no meio da
/// sessão. O app não tem um canal de contato próprio para inventar: orienta a
/// procurar o suporte do DBook pelos canais oficiais.
class AccountBlockedGate extends ConsumerWidget {
  const AccountBlockedGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(accountBlockedProvider)) return child;

    return Scaffold(
      body: SafeArea(
        child: DbookStatusPlaceholder(
          icon: Icons.block,
          iconColor: Theme.of(context).colorScheme.error,
          title: 'Conta bloqueada',
          message:
              'Sua conta foi bloqueada e por isso não dá para entrar nem reservar. '
              'Fale com o suporte do DBook pelos canais oficiais para entender o '
              'motivo e pedir a revisão.',
          actionLabel: 'Entendi',
          onAction: () {
            ref.read(authNotifierProvider.notifier).logout();
            ref.read(accountBlockedProvider.notifier).clear();
          },
        ),
      ),
    );
  }
}
