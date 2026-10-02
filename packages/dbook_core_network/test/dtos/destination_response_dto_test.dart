import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:test/test.dart';

void main() {
  test('given the API JSON when parsed then every field maps correctly', () {
    final dto = DestinationResponseDto.fromJson({
      'iataCode': 'GIG',
      'city': 'Rio de Janeiro',
      'country': 'Brasil',
      'photoUrl': 'https://example.com/gig.jpg',
      'region': 'América do Sul',
      'isPopular': true,
      'lowestPrice': 305.0,
    });

    expect(dto.iataCode, 'GIG');
    expect(dto.city, 'Rio de Janeiro');
    expect(dto.region, 'América do Sul');
    expect(dto.isPopular, true);
    expect(dto.lowestPrice, 305.0);
  });

  test('given a null lowestPrice when parsed then the domain destination has '
      'no price', () {
    final destination = DestinationResponseDto.fromJson({
      'iataCode': 'LHR',
      'city': 'Londres',
      'country': 'Reino Unido',
      'photoUrl': 'https://example.com/lhr.jpg',
      'region': 'Europa',
      'isPopular': false,
      'lowestPrice': null,
    }).toDomain();

    expect(destination.iataCode, 'LHR');
    expect(destination.lowestPrice, isNull);
  });

  test(
    'given an averageRating when parsed then the domain destination keeps it, '
    'and a null one stays null',
    () {
      final rated = DestinationResponseDto.fromJson({
        'iataCode': 'GIG',
        'city': 'Rio de Janeiro',
        'country': 'Brasil',
        'photoUrl': 'https://example.com/gig.jpg',
        'region': 'América do Sul',
        'isPopular': true,
        'lowestPrice': 305.0,
        'averageRating': 4.5,
      }).toDomain();
      final unrated = DestinationResponseDto.fromJson({
        'iataCode': 'LHR',
        'city': 'Londres',
        'country': 'Reino Unido',
        'photoUrl': 'https://example.com/lhr.jpg',
        'region': 'Europa',
        'isPopular': false,
        'averageRating': null,
      }).toDomain();

      expect(rated.averageRating, 4.5);
      expect(unrated.averageRating, isNull);
    },
  );
}
