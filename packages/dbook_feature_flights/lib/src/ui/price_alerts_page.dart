import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/price_providers.dart';

final _money = NumberFormat.currency(symbol: r'$');
final _date = DateFormat('dd/MM/yyyy');

/// Os alertas de preço: ligar e desligar, mudar o valor e apagar. Cada
/// mudança aparece na hora e volta atrás, com aviso, se o servidor recusar.
class PriceAlertsPage extends ConsumerWidget {
  const PriceAlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(priceAlertsNotifierProvider);
    final notifier = ref.read(priceAlertsNotifierProvider.notifier);

    void tell(Object error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(priceAlertErrorMessage(error))));
    }

    Future<void> editTarget(PriceAlert alert) async {
      final controller = TextEditingController(
        text: alert.targetPrice.toStringAsFixed(2),
      );
      final value = await showDialog<double>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Mudar o valor do alerta'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Avisar quando custar até',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            DbookButton(
              label: 'Salvar',
              onPressed: () {
                final parsed = double.tryParse(
                  controller.text.replaceAll(',', '.'),
                );
                if (parsed != null && parsed > 0) {
                  Navigator.of(dialogContext).pop(parsed);
                }
              },
            ),
          ],
        ),
      );
      controller.dispose();
      if (value == null) return;
      try {
        await notifier.setTarget(alert, value);
      } on DbookNetworkException catch (error) {
        tell(error);
      }
    }

    return Scaffold(
      appBar: const DbookAppBar(title: 'Alertas de preço'),
      body: alerts.when(
        loading: () => const DbookLoadingIndicator(),
        error: (error, _) => DbookStatusPlaceholder(
          icon: Icons.error_outline,
          title: 'Não deu para carregar',
          message: error is DbookNetworkException
              ? error.message
              : 'Tente de novo.',
          actionLabel: 'Tentar de novo',
          onAction: () => ref.invalidate(priceAlertsNotifierProvider),
        ),
        data: (list) => list.isEmpty
            ? const DbookStatusPlaceholder(
                icon: Icons.notifications_none,
                title: 'Nenhum alerta ainda',
                message:
                    'Abra um voo e toque em "Criar alerta de preço": avisamos quando '
                    'a rota e a data chegarem ao valor que você escolher.',
              )
            : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final alert = list[index];
                  return ListTile(
                    title: Text(
                      '${alert.origin} → ${alert.destination} · ${_date.format(alert.date)}',
                    ),
                    subtitle: Text(
                      'Avisar até ${_money.format(alert.targetPrice)}',
                    ),
                    onTap: () => editTarget(alert),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: alert.active,
                          onChanged: (value) async {
                            try {
                              await notifier.setActive(alert, active: value);
                            } on DbookNetworkException catch (error) {
                              tell(error);
                            }
                          },
                        ),
                        IconButton(
                          tooltip: 'Apagar alerta',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final confirmed = await showDbookConfirmationDialog(
                              context,
                              title: 'Apagar este alerta?',
                              message: 'Você deixa de ser avisado sobre esta rota e data.',
                              confirmLabel: 'Apagar',
                              level: DbookConfirmLevel.destructive,
                            );
                            if (!confirmed) return;
                            try {
                              await notifier.delete(alert);
                            } on DbookNetworkException catch (error) {
                              tell(error);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
