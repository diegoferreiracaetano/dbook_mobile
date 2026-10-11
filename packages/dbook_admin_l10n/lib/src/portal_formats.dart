import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Formatação de data, valor e número do portal, num lugar só: nenhuma tela
/// monta `DateFormat`/`NumberFormat` por conta própria (o formato muda aqui,
/// não em 40 telas).
abstract final class PortalFormats {
  static const locale = 'pt_BR';

  /// Carrega os dados de formato de pt-BR. O `main` chama uma vez; os testes
  /// de widget chamam no `setUpAll`.
  static Future<void> init() => initializeDateFormatting(locale);

  static String date(DateTime value) =>
      DateFormat('dd/MM/yyyy', locale).format(value);

  static String time(DateTime value) =>
      DateFormat('HH:mm', locale).format(value);

  static String dateTime(DateTime value) =>
      DateFormat('dd/MM/yyyy HH:mm', locale).format(value);

  /// "R$ 1.234,50". O valor vem pronto do backend: aqui só se formata.
  static String money(num value) =>
      NumberFormat.currency(locale: locale, symbol: r'R$').format(value);

  /// Número curto para eixo de gráfico ("1,2 mil", "3 mi").
  static String compact(num value) =>
      NumberFormat.compact(locale: locale).format(value);

  static String integer(num value) =>
      NumberFormat.decimalPattern(locale).format(value);

  /// Razão de 0 a 1 como porcentagem ("12,5%").
  static String percent(double ratio) => NumberFormat.decimalPercentPattern(
    locale: locale,
    decimalDigits: 1,
  ).format(ratio);

  /// Variação com sinal ("+12,5%" / "-3,0%").
  static String signedPercent(double ratio) {
    final text = percent(ratio.abs());
    if (ratio > 0) return '+$text';
    if (ratio < 0) return '-$text';
    return text;
  }

  /// "agora", "há 5 min", "há 2 h", "há 3 dias".
  static String ago(DateTime then, DateTime now) {
    final diff = now.difference(then);
    if (diff.inSeconds < 60) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours} h';
    final days = diff.inDays;
    return days == 1 ? 'há 1 dia' : 'há $days dias';
  }
}
