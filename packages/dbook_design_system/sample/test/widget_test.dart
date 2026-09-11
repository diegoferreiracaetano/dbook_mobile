import 'package:dbook_design_system_sample/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given the showcase app when built then every section title renders',
    (tester) async {
      await tester.pumpWidget(const DbookDesignSystemShowcase());
      await tester.pump();

      expect(find.text('DBook Design System'), findsOneWidget);
      expect(find.text('Cores'), findsOneWidget);
      expect(find.text('Tipografia'), findsOneWidget);
      expect(find.text('Botões'), findsOneWidget);
      expect(find.text('Formulário'), findsOneWidget);
      expect(find.text('Avatar'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Cards'), findsOneWidget);
      expect(find.text('Faixa de data e preço'), findsOneWidget);
      expect(find.text('Mapa de assento'), findsOneWidget);
      expect(find.text('Código QR (placeholder)'), findsOneWidget);
      expect(find.text('Feedback'), findsOneWidget);
      expect(find.text('Tela de sucesso'), findsOneWidget);
    },
  );

  testWidgets('given the theme toggle when tapped then dark theme applies', (
    tester,
  ) async {
    await tester.pumpWidget(const DbookDesignSystemShowcase());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
  });
}
