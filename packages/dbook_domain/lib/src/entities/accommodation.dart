/// Quarto livre em todas as noites da estadia buscada, com o que a estadia
/// custa nele (`nightlyRate * noites`, calculado pelo servidor).
class RoomOffer {
  const RoomOffer({
    required this.roomTypeId,
    required this.name,
    required this.capacity,
    required this.nightlyRate,
    required this.totalPrice,
  });

  final int roomTypeId;
  final String name;
  final int capacity;
  final double nightlyRate;
  final double totalPrice;
}

/// Hotel no resultado de uma busca: só os quartos que cabem na estadia.
class AccommodationResult {
  const AccommodationResult({
    required this.id,
    required this.name,
    required this.city,
    required this.destinationIataCode,
    required this.address,
    required this.stars,
    required this.amenities,
    required this.rooms,
    this.photoUrl,
    this.averageRating,
    this.reviewCount = 0,
    this.fromPrice,
  });

  final int id;
  final String name;
  final String city;
  final String destinationIataCode;
  final String address;
  final int stars;
  final List<String> amenities;
  final List<RoomOffer> rooms;
  final String? photoUrl;
  final double? averageRating;
  final int reviewCount;

  /// Menor preço da estadia entre os quartos; `null` sem quarto livre.
  final double? fromPrice;
}

/// Tipo de quarto à venda no detalhe do hotel (sem datas, só a tarifa).
class RoomType {
  const RoomType({
    required this.id,
    required this.name,
    required this.capacity,
    required this.nightlyRate,
  });

  final int id;
  final String name;
  final int capacity;
  final double nightlyRate;
}

class AccommodationDetail {
  const AccommodationDetail({
    required this.id,
    required this.name,
    required this.city,
    required this.destinationIataCode,
    required this.address,
    required this.stars,
    required this.amenities,
    required this.roomTypes,
    this.description,
    this.photoUrl,
  });

  final int id;
  final String name;
  final String city;
  final String destinationIataCode;
  final String address;
  final int stars;
  final List<String> amenities;
  final List<RoomType> roomTypes;
  final String? description;
  final String? photoUrl;
}

/// Parâmetros de uma busca de hotel. Igualdade por valor: é a chave do
/// provider de resultados.
class StaySearch {
  const StaySearch({
    required this.destination,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
  });

  final String destination;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;

  int get nights => checkOut.difference(checkIn).inDays;

  @override
  bool operator ==(Object other) =>
      other is StaySearch &&
      other.destination == destination &&
      other.checkIn == checkIn &&
      other.checkOut == checkOut &&
      other.guests == guests;

  @override
  int get hashCode => Object.hash(destination, checkIn, checkOut, guests);
}

/// Reserva de hotel já feita (`stay` + `accommodation` de `GET /bookings`).
class StayBooking {
  const StayBooking({
    required this.bookingId,
    required this.status,
    required this.hotelName,
    required this.city,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.guests,
    required this.price,
  });

  final int bookingId;
  final String status;
  final String hotelName;
  final String city;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final int guests;
  final double price;
}
