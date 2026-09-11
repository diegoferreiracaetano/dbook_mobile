import 'package:freezed_annotation/freezed_annotation.dart';

part 'airport.freezed.dart';

/// Aeroporto — espelha `Airport` do backend.
@freezed
abstract class Airport with _$Airport {
  const factory Airport({
    int? id,
    required String iataCode,
    required String name,
    required String city,
    required String country,
  }) = _Airport;
}
