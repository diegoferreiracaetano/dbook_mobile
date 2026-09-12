/// Disponibilidade em tempo real do DBook — cliente STOMP mínimo sobre
/// WebSocket, só pra assinar `/topic/bookables/{id}/availability`.
library;

export 'src/data/dbook_realtime_socket.dart';
export 'src/data/stomp_availability_client.dart';
export 'src/data/stomp_frame.dart';
export 'src/state/availability_state.dart';
export 'src/ui/dbook_live_availability.dart';
