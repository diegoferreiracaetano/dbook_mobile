import 'package:flutter/material.dart';

/// Paleta de degradês usada como fundo dos cards de destino enquanto não
/// há foto real (ver `DbookDestinationCard.background`) — uma por
/// aeroporto conhecido, ciclando se a lista crescer.
const _destinationGradients = [
  [Color(0xFF1E3A5F), Color(0xFF4A90A4)],
  [Color(0xFF2D5F3E), Color(0xFF7BAE7F)],
  [Color(0xFF5F3A1E), Color(0xFFAE8A7B)],
];

LinearGradient destinationGradient(int index) {
  final colors = _destinationGradients[index % _destinationGradients.length];
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: colors,
  );
}
