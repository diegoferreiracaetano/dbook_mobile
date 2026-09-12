import 'package:freezed_annotation/freezed_annotation.dart';

part 'availability_state.freezed.dart';

/// Estado da disponibilidade ao vivo de um `bookable` (voo). O backend não
/// dá garantia de entrega nem replay (broker em memória, sem fila) — se a
/// conexão cair no meio de uma atualização, ela é só perdida; por isso
/// [AvailabilityState.reconnecting] guarda o último valor conhecido em vez
/// de zerar a tela enquanto tenta reconectar.
@freezed
sealed class AvailabilityState with _$AvailabilityState {
  const factory AvailabilityState.connecting() = AvailabilityConnecting;
  const factory AvailabilityState.live(int availableCapacity) =
      AvailabilityLive;
  const factory AvailabilityState.reconnecting(int? lastKnownCapacity) =
      AvailabilityReconnecting;
  const factory AvailabilityState.unavailable(String message) =
      AvailabilityUnavailable;
}
