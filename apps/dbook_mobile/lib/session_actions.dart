import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:dbook_feature_notifications/dbook_feature_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sair da conta. O aparelho é removido do servidor **antes** de a sessão ser
/// limpa (depois, a chamada não teria token): sem isso, um celular que muda
/// de dono continuaria recebendo os avisos da conta anterior.
Future<void> signOut(WidgetRef ref) async {
  await ref.read(deviceRegistrarProvider).unregister();
  await ref.read(authNotifierProvider.notifier).logout();
}
