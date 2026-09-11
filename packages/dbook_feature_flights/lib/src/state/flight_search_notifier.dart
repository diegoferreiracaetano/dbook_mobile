import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'flight_providers.dart';
import 'flight_search_state.dart';

class FlightSearchNotifier extends Notifier<FlightSearchState> {
  @override
  FlightSearchState build() => const FlightSearchState.idle();

  Future<void> search({
    required String originIataCode,
    required String destinationIataCode,
    required DateTime date,
  }) async {
    state = const FlightSearchState.loading();
    try {
      final flights = await ref
          .read(flightRepositoryProvider)
          .search(
            originIataCode: originIataCode,
            destinationIataCode: destinationIataCode,
            date: date,
          );
      state = FlightSearchState.success(flights);
    } on DbookNetworkException catch (error) {
      state = FlightSearchState.error(error.message);
    }
  }
}
