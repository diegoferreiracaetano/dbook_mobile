import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';

/// Fundo do card de destino — sempre uma foto real (`GET /destinations`
/// garante `photoUrl` em todo destino, ver
/// `docs/destination_photo_credits.md`).
Decoration destinationBackground(Destination destination) {
  return BoxDecoration(
    image: DecorationImage(
      image: NetworkImage(destination.photoUrl),
      fit: BoxFit.cover,
    ),
  );
}
