import 'package:flutter/material.dart';

const airlinePalette = [
  Color(0xFFB23A2E),
  Color(0xFF1E4FA3),
  Color(0xFF1E7A34),
  Color(0xFF6A3FA0),
  Color(0xFFB35A00),
  Color(0xFF00838F),
];

/// Companhias reais seedadas no backend (`V12__seed_airlines.sql`) — cor
/// fixa por código, pra não trocar de tela pra tela, uma por posição na
/// paleta pra ficarem sempre distintas entre si. Compartilhado dentro desta
/// feature (`flight_results_page.dart`/`flight_detail_page.dart`) — cada
/// feature fora daqui mantém sua própria cópia (`my_bookings_page.dart` em
/// `dbook_feature_booking`), já que features não importam features.
const knownAirlineColors = {
  'LA': Color(0xFFB23A2E),
  'AD': Color(0xFF1E4FA3),
  'G3': Color(0xFF1E7A34),
  'AA': Color(0xFF6A3FA0),
  'DL': Color(0xFFB35A00),
  'UA': Color(0xFF00838F),
};

/// Companhia fora da lista conhecida (nova no backend, ou cenário de teste)
/// cai num hash — ainda determinístico, só sem a garantia de distinção da
/// tabela fixa acima.
Color airlineColorFor(String iataCode) =>
    knownAirlineColors[iataCode] ??
    airlinePalette[iataCode.hashCode.abs() % airlinePalette.length];
