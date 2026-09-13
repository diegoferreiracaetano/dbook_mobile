import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';

/// Abre a lista de destinos conhecidos (já carregada por quem chama, via
/// `featuredDestinationsProvider`) num bottom sheet; devolve o
/// [Destination] escolhido, ou `null` se o usuário fechar sem escolher.
/// Não busca nada sozinho — só renderiza a lista recebida.
Future<Destination?> showAirportPickerSheet(
  BuildContext context,
  List<Destination> destinations,
) {
  return showModalBottomSheet<Destination>(
    context: context,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.7,
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(DbookSpacing.md),
              child: DbookSectionLabel(text: 'SELECIONE O AEROPORTO'),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  return ListTile(
                    leading: const Icon(Icons.flight_outlined),
                    title: Text(destination.label),
                    subtitle: Text(destination.country),
                    onTap: () => Navigator.of(context).pop(destination),
                  );
                },
              ),
            ),
            const SizedBox(height: DbookSpacing.sm),
          ],
        ),
      );
    },
  );
}
