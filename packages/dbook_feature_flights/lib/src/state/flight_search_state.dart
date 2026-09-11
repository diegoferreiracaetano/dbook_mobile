import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'flight_search_state.freezed.dart';

@freezed
sealed class FlightSearchState with _$FlightSearchState {
  const factory FlightSearchState.idle() = FlightSearchIdle;
  const factory FlightSearchState.loading() = FlightSearchLoading;
  const factory FlightSearchState.success(List<Flight> flights) =
      FlightSearchSuccess;
  const factory FlightSearchState.error(String message) = FlightSearchError;
}
