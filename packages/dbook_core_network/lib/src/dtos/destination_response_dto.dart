import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'destination_response_dto.freezed.dart';
part 'destination_response_dto.g.dart';

/// Item de `GET /destinations`.
@freezed
abstract class DestinationResponseDto with _$DestinationResponseDto {
  const DestinationResponseDto._();

  const factory DestinationResponseDto({
    required String iataCode,
    required String city,
    required String country,
    required String photoUrl,
    double? lowestPrice,
  }) = _DestinationResponseDto;

  factory DestinationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DestinationResponseDtoFromJson(json);

  Destination toDomain() {
    return Destination(
      iataCode: iataCode,
      city: city,
      country: country,
      photoUrl: photoUrl,
      lowestPrice: lowestPrice,
    );
  }
}
