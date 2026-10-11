import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Folha de identidade: tipografia, cor, botões, campo, cartão e estados. É a
/// referência visual do tema; qualquer mudança em token ou em `DbookTheme`
/// aparece aqui como diferença de imagem e precisa ser decidida de propósito.
Widget _sheet(ThemeData theme) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: theme,
  home: Scaffold(
    body: RepaintBoundary(
      key: const ValueKey('golden'),
      child: Builder(
        builder: (context) {
          final text = Theme.of(context).textTheme;
          final status = Theme.of(context).extension<DbookStatusColors>()!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(DbookSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Para onde vamos?', style: text.headlineLarge),
                  const SizedBox(height: DbookSpacing.xs),
                  Text('Voos e hotéis em um só lugar', style: text.bodyLarge),
                  const SizedBox(height: DbookSpacing.lg),
                  Text('Título de seção', style: text.titleLarge),
                  Text('R\$ 1.284,90   R\$ 987,00', style: text.titleMedium),
                  Text(
                    'GRU 08:15 → LIS 21:40   1234567890',
                    style: DbookTypography.tabular(text.bodyMedium!),
                  ),
                  Text('Rótulo pequeno', style: text.labelMedium),
                  const SizedBox(height: DbookSpacing.lg),
                  Wrap(
                    spacing: DbookSpacing.sm,
                    runSpacing: DbookSpacing.sm,
                    children: [
                      DbookButton(label: 'Reservar', onPressed: () {}),
                      DbookButton(
                        label: 'Ver detalhes',
                        variant: DbookButtonVariant.secondary,
                        onPressed: () {},
                      ),
                      DbookButton(
                        label: 'Cancelar',
                        variant: DbookButtonVariant.text,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: DbookSpacing.lg),
                  const TextField(
                    decoration: InputDecoration(labelText: 'E-mail'),
                  ),
                  const SizedBox(height: DbookSpacing.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(DbookSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('São Paulo para Lisboa', style: text.titleSmall),
                          Text('1 parada, 11h 25min', style: text.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: DbookSpacing.lg),
                  Row(
                    children: [
                      for (final color in [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                        status.success,
                        status.warning,
                        status.danger,
                        status.info,
                      ])
                        Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: DbookSpacing.sm),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(DbookRadius.sm),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  ),
);

void main() {
  for (final entry in {
    'light': DbookTheme.light,
    'dark': DbookTheme.dark,
  }.entries) {
    testWidgets(
      'given the ${entry.key} theme when the identity sheet is drawn then it '
      'matches the golden',
      (tester) async {
        tester.view.physicalSize = const Size(480, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_sheet(entry.value));
        await tester.pumpAndSettle();

        await expectLater(
          find.byKey(const ValueKey('golden')),
          matchesGoldenFile('goldens/identity_${entry.key}.png'),
        );
      },
    );
  }
}
