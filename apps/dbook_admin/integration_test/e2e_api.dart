import 'dart:math';

import 'package:dio/dio.dart';

/// Chamadas **diretas à API real** para montar o cenário de cada teste E2E
/// (cliente, voo, reserva paga) sem passar pela tela. Nada aqui é mock: o
/// backend está no ar (docker compose + bootRun) e os dados são de teste.
class E2eApi {
  E2eApi({required String baseUrl})
    : _dio = Dio(BaseOptions(baseUrl: baseUrl, validateStatus: (_) => true));

  final Dio _dio;
  final _random = Random();

  String uniqueSuffix() =>
      '${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(999)}';

  Map<String, dynamic> _ok(Response<dynamic> response, String what) {
    final status = response.statusCode ?? 0;
    if (status >= 300) {
      throw StateError('E2E: $what falhou ($status): ${response.data}');
    }
    final data = response.data;
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<String> adminToken(String email, String password) async {
    final response = await _dio.post<dynamic>(
      '/admin/auth/login',
      data: {'email': email, 'password': password},
    );
    return _ok(response, 'login do administrador')['accessToken'] as String;
  }

  Options _auth(String token, {Map<String, String>? headers}) =>
      Options(headers: {'Authorization': 'Bearer $token', ...?headers});

  /// Registra um cliente novo e devolve (id, e-mail, token de acesso).
  Future<({int id, String email, String token})> registerCustomer() async {
    final suffix = uniqueSuffix();
    final email = 'e2e$suffix@dbook.test';
    final created = _ok(
      await _dio.post<dynamic>(
        '/auth/register',
        data: {
          'name': 'Cliente E2E $suffix',
          'email': email,
          'password': 'senha-e2e-$suffix',
        },
      ),
      'cadastro do cliente',
    );
    final tokens = _ok(
      await _dio.post<dynamic>(
        '/auth/login',
        data: {'email': email, 'password': 'senha-e2e-$suffix'},
      ),
      'login do cliente',
    );
    return (
      id: (created['id'] as num).toInt(),
      email: email,
      token: tokens['accessToken'] as String,
    );
  }

  /// Cadastra um voo daqui a [daysAhead] dias e devolve o id.
  Future<int> createFlight(String adminToken, {int daysAhead = 10}) async {
    final departure = DateTime.now().add(Duration(days: daysAhead));
    String t(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}T'
        '${d.hour.toString().padLeft(2, '0')}:00:00';
    final created = _ok(
      await _dio.post<dynamic>(
        '/admin/flights',
        options: _auth(adminToken),
        data: {
          'flightNumber': 'E2${uniqueSuffix().substring(0, 6)}',
          'airlineIataCode': 'LA',
          'originIataCode': 'GRU',
          'destinationIataCode': 'GIG',
          'departureTime': t(departure),
          'arrivalTime': t(departure.add(const Duration(hours: 1))),
          'seatClass': 'ECONOMY',
          'price': 400,
          'totalCapacity': 12,
          'aircraftType': 'Airbus A320',
        },
      ),
      'cadastro do voo',
    );
    return (created['id'] as num).toInt();
  }

  /// Reserva o primeiro assento livre do voo e paga: devolve a reserva
  /// **confirmada** (o que o reembolso exige).
  Future<int> paidBooking({
    required String customerToken,
    required int flightId,
  }) async {
    final seats = await _dio.get<dynamic>('/bookables/$flightId/seats');
    final seat = (seats.data as List).cast<Map<String, dynamic>>().firstWhere(
      (s) => s['status'] == 'AVAILABLE',
    );
    final booking = _ok(
      await _dio.post<dynamic>(
        '/bookings',
        options: _auth(customerToken),
        data: {'bookableId': flightId, 'seatId': seat['id']},
      ),
      'reserva',
    );
    final bookingId = (booking['id'] as num).toInt();
    _ok(
      await _dio.post<dynamic>(
        '/payments',
        options: _auth(
          customerToken,
          headers: {'Idempotency-Key': 'e2e-${uniqueSuffix()}'},
        ),
        data: {
          'bookingIds': [bookingId],
          'cardLast4': '4242',
          'cardholderName': 'Cliente E2E',
        },
      ),
      'pagamento',
    );
    return bookingId;
  }

  /// Edita o preço de um voo pela API: depois disso, qualquer tela que leu o
  /// voo antes está com a `version` velha.
  Future<void> bumpFlightPrice(String adminToken, int flightId) async {
    final detail = _ok(
      await _dio.get<dynamic>(
        '/admin/flights/$flightId',
        options: _auth(adminToken),
      ),
      'leitura do voo',
    );
    final flight = detail['flight'] as Map<String, dynamic>;
    _ok(
      await _dio.put<dynamic>(
        '/admin/flights/$flightId',
        options: _auth(adminToken),
        data: {
          'version': flight['version'],
          'flightNumber': flight['flightNumber'],
          'airlineIataCode': flight['airlineIataCode'],
          'originIataCode': flight['origin'],
          'destinationIataCode': flight['destination'],
          'departureTime': flight['departureTime'],
          'arrivalTime': flight['arrivalTime'],
          'seatClass': flight['seatClass'],
          'price': (flight['price'] as num) + 11,
          'totalCapacity': flight['totalCapacity'],
          'aircraftType': flight['aircraftType'],
        },
      ),
      'edição do voo',
    );
  }
}
