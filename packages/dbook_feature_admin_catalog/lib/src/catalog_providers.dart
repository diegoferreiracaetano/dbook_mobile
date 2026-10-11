import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final catalogApiProvider = Provider<CatalogApi>(
  (ref) => DioCatalogApi(ref.watch(adminDioProvider)),
);

final flightsProvider = FutureProvider.autoDispose
    .family<PageOf<AdminFlight>, FlightQuery>(
      (ref, query) => ref.watch(catalogApiProvider).listFlights(query),
    );

final flightDetailProvider = FutureProvider.autoDispose
    .family<AdminFlightDetail, int>(
      (ref, id) => ref.watch(catalogApiProvider).getFlight(id),
    );

final airlinesProvider = FutureProvider.autoDispose<List<Airline>>(
  (ref) => ref.watch(catalogApiProvider).airlines(),
);

final airportsProvider = FutureProvider.autoDispose<List<Airport>>(
  (ref) => ref.watch(catalogApiProvider).airports(),
);

final aircraftModelsProvider = FutureProvider.autoDispose<List<AircraftModel>>(
  (ref) => ref.watch(catalogApiProvider).aircraftModels(),
);
