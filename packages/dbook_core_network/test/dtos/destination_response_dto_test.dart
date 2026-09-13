import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:test/test.dart';

void main() {
  test('given the API JSON when parsed then every field maps correctly', () {
    final dto = DestinationResponseDto.fromJson({
      'iataCode': 'GIG',
      'city': 'Rio de Janeiro',
      'country': 'Brasil',
      'photoUrl': 'https://example.com/gig.jpg',
      'lowestPrice': 305.0,
    });

    expect(dto.iataCode, 'GIG');
    expect(dto.city, 'Rio de Janeiro');
    expect(dto.lowestPrice, 305.0);
  });

  test(
    'given a null lowestPrice when parsed then the domain destination has '
    'no price',
    () {
      final destination = DestinationResponseDto.fromJson({
        'iataCode': 'LHR',
        'city': 'Londres',
        'country': 'Reino Unido',
        'photoUrl': 'https://example.com/lhr.jpg',
        'lowestPrice': null,
      }).toDomain();

      expect(destination.iataCode, 'LHR');
      expect(destination.lowestPrice, isNull);
    },
  );
}
