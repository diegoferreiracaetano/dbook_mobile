import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dbook_realtime_socket.dart';
import '../data/stomp_availability_client.dart';
import '../state/availability_state.dart';

/// Deriva a URL do WebSocket (`ws://`/`wss://` + `/ws`) a partir da URL
/// base HTTP da API — mesmo host/porta, protocolo trocado.
Uri _toWsUri(String baseUrl) {
  final httpUri = Uri.parse(baseUrl);
  final scheme = httpUri.scheme == 'https' ? 'wss' : 'ws';
  return httpUri.replace(scheme: scheme, path: '/ws');
}

/// Mostra a disponibilidade de assentos ao vivo pra um voo (`bookableId`
/// = `Flight.id`) — assina ao montar, cancela a assinatura ao desmontar.
/// Enquanto conecta ou reconecta, mostra o último valor conhecido (ou
/// [fallbackCapacity], vindo do resultado de busca) em vez de piscar vazio.
class DbookLiveAvailability extends ConsumerStatefulWidget {
  const DbookLiveAvailability({
    super.key,
    required this.bookableId,
    required this.fallbackCapacity,
    @visibleForTesting this.socketFactory,
  });

  final int bookableId;
  final int fallbackCapacity;

  /// Só pra teste — troca o `WebSocketChannel` real por um fake.
  final DbookRealtimeSocket Function(Uri uri)? socketFactory;

  @override
  ConsumerState<DbookLiveAvailability> createState() =>
      _DbookLiveAvailabilityState();
}

class _DbookLiveAvailabilityState extends ConsumerState<DbookLiveAvailability> {
  StompAvailabilityClient? _client;
  AvailabilityState _state = const AvailabilityState.connecting();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  Future<void> _connect() async {
    final tokens = await ref.read(tokenStorageProvider).readTokens();
    if (!mounted || tokens == null) return;

    final client = StompAvailabilityClient(
      wsUri: _toWsUri(ref.read(baseUrlProvider)),
      accessToken: tokens.accessToken,
      socketFactory: widget.socketFactory,
    );
    _client = client;
    client.connect(widget.bookableId).listen((state) {
      if (mounted) setState(() => _state = state);
    });
  }

  @override
  void dispose() {
    _client?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final capacity = switch (_state) {
      AvailabilityLive(:final availableCapacity) => availableCapacity,
      AvailabilityReconnecting(:final lastKnownCapacity) =>
        lastKnownCapacity ?? widget.fallbackCapacity,
      AvailabilityConnecting() ||
      AvailabilityUnavailable() => widget.fallbackCapacity,
    };

    final (dotColor, label) = switch (_state) {
      AvailabilityLive() => (Colors.green, 'Ao vivo'),
      AvailabilityConnecting() => (colorScheme.outline, 'Conectando...'),
      AvailabilityReconnecting() => (colorScheme.outline, 'Reconectando...'),
      AvailabilityUnavailable() => (colorScheme.error, 'Indisponível'),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$capacity', style: textTheme.bodyMedium),
        const SizedBox(width: DbookSpacing.xs),
        Container(
          width: DbookSpacing.sm,
          height: DbookSpacing.sm,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: DbookSpacing.xs),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
