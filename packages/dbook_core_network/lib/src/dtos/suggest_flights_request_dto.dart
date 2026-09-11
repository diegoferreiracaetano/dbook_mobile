import 'package:freezed_annotation/freezed_annotation.dart';

part 'suggest_flights_request_dto.freezed.dart';
part 'suggest_flights_request_dto.g.dart';

/// Corpo de `POST /ai/suggestions`.
@freezed
abstract class SuggestFlightsRequestDto with _$SuggestFlightsRequestDto {
  const factory SuggestFlightsRequestDto({required String query}) =
      _SuggestFlightsRequestDto;

  factory SuggestFlightsRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SuggestFlightsRequestDtoFromJson(json);
}
