import 'package:flutter/painting.dart';

/// Razão de contraste da WCAG: de 1 (iguais) a 21 (preto sobre branco).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}
