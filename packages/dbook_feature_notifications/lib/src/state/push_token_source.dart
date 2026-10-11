import 'dart:math';

/// De onde vem o token do aparelho para *push*. A implementação real (FCM) é
/// uma evolução: precisa de conta e de configuração nativas. Enquanto isso, o
/// adaptador falso gera um token estável durante a vida do app, o que basta
/// para exercitar o registro (`POST /notifications/devices`) de ponta a ponta
/// com o backend local.
abstract interface class PushTokenSource {
  Future<String?> token();
}

class FakePushTokenSource implements PushTokenSource {
  FakePushTokenSource([Random? random])
    : _token =
          'local-${List.generate(16, (_) => (random ?? Random.secure()).nextInt(16).toRadixString(16)).join()}';

  final String _token;

  @override
  Future<String?> token() async => _token;
}
