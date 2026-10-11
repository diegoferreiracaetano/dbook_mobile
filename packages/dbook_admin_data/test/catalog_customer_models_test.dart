import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:test/test.dart';

AdminFlight _flight({double price = 450, String number = 'DB1001'}) =>
    AdminFlight.fromJson({
      'id': 1,
      'flightNumber': number,
      'airlineIataCode': 'LA',
      'origin': 'GRU',
      'destination': 'GIG',
      'departureTime': '2027-01-15T08:00:00',
      'arrivalTime': '2027-01-15T09:10:00',
      'seatClass': 'ECONOMY',
      'price': price,
      'totalCapacity': 60,
      'aircraftType': 'Airbus A320',
      'status': 'SCHEDULED',
      'version': 2,
    });

void main() {
  group('flight status and seat class on the wire', () {
    test('given each flight status when converting then round trips', () {
      expect(flightStatusFromWire('SCHEDULED'), FlightStatus.scheduled);
      expect(flightStatusFromWire('CANCELLED'), FlightStatus.cancelled);
      expect(flightStatusFromWire('OUTRO'), FlightStatus.unknown);
      expect(flightStatusToWire(FlightStatus.cancelled), 'CANCELLED');
      expect(flightStatusToWire(FlightStatus.unknown), 'UNKNOWN');
    });

    test('given each seat class when converting then uses the wire value', () {
      expect(seatClassToWire(SeatClass.economy), 'ECONOMY');
      expect(seatClassToWire(SeatClass.premiumEconomy), 'PREMIUM_ECONOMY');
      expect(seatClassToWire(SeatClass.business), 'BUSINESS');
      expect(seatClassToWire(SeatClass.first), 'FIRST');
      expect(seatClassToWire(SeatClass.unknown), 'ECONOMY');
    });
  });

  group('flight form', () {
    test('given a flight when making a form then copies every field', () {
      final form = FlightForm.fromFlight(_flight());

      expect(form.flightNumber, 'DB1001');
      expect(form.price, 450);
      expect(form.totalCapacity, 60);
      expect(form.seatClass, SeatClass.economy);
    });

    test(
      'given a form when serialising then trims and upper cases the codes',
      () {
        final json = FlightForm(
          flightNumber: ' db2000 ',
          airlineIataCode: ' la ',
          originIataCode: 'gru',
          destinationIataCode: 'gig',
          departureTime: DateTime(2027, 2, 1, 8),
          arrivalTime: DateTime(2027, 2, 1, 9, 10),
          seatClass: SeatClass.business,
          price: 700,
          totalCapacity: 100,
          aircraftType: 'Airbus A320',
        ).toJson();

        expect(json['airlineIataCode'], 'LA');
        expect(json['originIataCode'], 'GRU');
        expect(json['seatClass'], 'BUSINESS');
        expect(json['departureTime'], startsWith('2027-02-01T08:00'));
      },
    );
  });

  group('concurrent edit differences', () {
    test('given my form equal to the server then there is no difference', () {
      final theirs = _flight();

      expect(flightDifferences(FlightForm.fromFlight(theirs), theirs), isEmpty);
    });

    test('given a changed price and number when comparing then lists just '
        'those fields', () {
      final theirs = _flight(price: 500, number: 'DB9999');
      final mine = FlightForm.fromFlight(_flight());

      final diff = flightDifferences(mine, theirs);

      expect(diff.map((d) => d.field), ['flightNumber', 'price']);
      expect(diff.last.mine, '450.00');
      expect(diff.last.theirs, '500.00');
    });
  });

  group('catalog models', () {
    test('given an airport when serialising then trims the text and keeps '
        'the popular flag', () {
      final json = const Airport(
        iataCode: 'cwb',
        name: ' Afonso Pena ',
        city: ' Curitiba ',
        country: 'Brasil',
        photoUrl: ' https://x/y.jpg ',
        region: 'América do Sul',
        isPopular: true,
      ).toJson();

      expect(json['iataCode'], 'CWB');
      expect(json['city'], 'Curitiba');
      expect(json['isPopular'], isTrue);
    });

    test('given an aircraft model json when parsing then reads the layout '
        'and ignores junk', () {
      final model = AircraftModel.fromJson({
        'name': 'Airbus A320',
        'seatsPerRow': 6,
        'seatLayout': [3, 3, 'x', null],
      });

      expect(model.seatLayout, [3, 3]);
      expect(model.seatsPerRow, 6);
    });

    test('given an import report with errors when asking then reports '
        'errors', () {
      final report = ImportReport.fromJson({
        'dryRun': false,
        'totalRows': 5,
        'toCreate': 3,
        'alreadyExisting': 1,
        'created': 3,
        'errors': [
          {'line': 3, 'message': 'preço inválido'},
        ],
      });

      expect(report.hasErrors, isTrue);
      expect(report.errors.single.line, 3);
    });
  });

  group('customer models', () {
    test('given a payment json with junk ids when parsing then keeps only '
        'numbers', () {
      final payment = CustomerPayment.fromJson({
        'id': 1,
        'amount': 1050,
        'cardLast4': '4242',
        'createdAt': '2026-10-09T20:28:34',
        'bookingIds': [2, 'x', 3.0],
      });

      expect(payment.bookingIds, [2, 3]);
      expect(payment.amount, 1050);
    });

    test('given a review json when parsing then reads rating and comment', () {
      final review = CustomerReview.fromJson({
        'id': 4,
        'bookingId': 2,
        'rating': 5,
        'comment': 'Ótimo',
        'createdAt': '2026-10-09T20:28:34Z',
      });

      expect(review.rating, 5);
      expect(review.createdAt, isNotNull);
    });

    test('given booking totals json when parsing then reads each bucket and '
        'tolerates null', () {
      final totals = BookingTotals.fromJson({
        'total': 5,
        'pending': 1,
        'confirmed': 3,
        'cancelled': 1,
      });

      expect(totals.confirmed, 3);
      expect(BookingTotals.fromJson(null).total, 0);
    });
  });
}
