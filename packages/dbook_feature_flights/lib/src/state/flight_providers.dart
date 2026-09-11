import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'flight_search_notifier.dart';
import 'flight_search_state.dart';

/// Usa o `dioProvider` de `dbook_core_session` — o mesmo Dio autenticado
/// (token + refresh automático) compartilhado com toda outra feature.
final flightRepositoryProvider = Provider<FlightRepository>(
  (ref) => FlightRepositoryImpl(ref.watch(dioProvider)),
);

final flightSearchNotifierProvider =
    NotifierProvider<FlightSearchNotifier, FlightSearchState>(
      FlightSearchNotifier.new,
    );
