import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Um swatch por tom semântico: fundo, borda e a cor do texto como uma barra.
/// Sem texto de propósito — o golden não depende de fonte nem de plataforma, e
/// mudar qualquer cor (ou borda) de status aparece no diff da imagem.
void main() {
  testWidgets(
    'given the status colors when drawn as swatches then they match the golden',
    (tester) async {
      tester.view
        ..physicalSize = const Size(280, 168)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      const colors = DbookStatusColors.light;
      const key = ValueKey('swatches');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: key,
            child: ColoredBox(
              color: const Color(0xFFFFFFFF),
              child: Padding(
                padding: const EdgeInsets.all(DbookSpacing.sm),
                child: Column(
                  spacing: DbookSpacing.sm,
                  children: const [
                    _Swatch(
                      foreground: DbookPalette.success,
                      background: DbookPalette.successBg,
                      border: DbookPalette.successBorder,
                    ),
                    _Swatch(
                      foreground: DbookPalette.warning,
                      background: DbookPalette.warningBg,
                      border: DbookPalette.warningBorder,
                    ),
                    _Swatch(
                      foreground: DbookPalette.error,
                      background: DbookPalette.errorBg,
                      border: DbookPalette.errorBorder,
                    ),
                    _Swatch(
                      foreground: DbookPalette.info,
                      background: DbookPalette.infoBg,
                      border: DbookPalette.infoBorder,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/status_colors.png'),
      );

      // os swatches acima usam a paleta direto; isto garante que o tema
      // entrega exatamente os mesmos valores
      expect(colors.success, DbookPalette.success);
      expect(colors.warningContainer, DbookPalette.warningBg);
      expect(colors.dangerBorder, DbookPalette.errorBorder);
      expect(colors.infoContainer, DbookPalette.infoBg);
    },
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.foreground,
    required this.background,
    required this.border,
  });

  final Color foreground;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border, width: 2),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: DbookSpacing.sm),
            child: SizedBox(
              width: 48,
              height: 12,
              child: ColoredBox(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}
