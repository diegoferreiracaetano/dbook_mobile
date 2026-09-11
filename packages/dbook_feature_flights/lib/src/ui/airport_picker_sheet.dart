import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';

import '../data/known_airports.dart';

/// Abre a lista de aeroportos conhecidos num bottom sheet; devolve o
/// [KnownAirport] escolhido, ou `null` se o usuário fechar sem escolher.
Future<KnownAirport?> showAirportPickerSheet(BuildContext context) {
  return showModalBottomSheet<KnownAirport>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(DbookSpacing.md),
              child: DbookSectionLabel(text: 'SELECIONE O AEROPORTO'),
            ),
            for (final airport in knownAirports)
              ListTile(
                leading: const Icon(Icons.flight_outlined),
                title: Text(airport.label),
                subtitle: Text(airport.country),
                onTap: () => Navigator.of(context).pop(airport),
              ),
            const SizedBox(height: DbookSpacing.sm),
          ],
        ),
      );
    },
  );
}
