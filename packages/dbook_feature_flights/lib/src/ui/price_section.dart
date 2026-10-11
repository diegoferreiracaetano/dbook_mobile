import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/destination_reviews_notifier.dart' show isLoggedInProvider;
import '../state/price_providers.dart';

final _money = NumberFormat.currency(symbol: r'$');
final _shortDate = DateFormat('dd/MM/yy');

/// O histórico de preço do voo (gráfico simples + alternativa em texto) e a
/// criação do alerta de preço da rota e data. Se o histórico não carrega, a
/// seção some em silêncio: o voo continua reservável sem ele.
class PriceSection extends ConsumerStatefulWidget {
  const PriceSection({super.key, required this.flight});

  final Flight flight;

  @override
  ConsumerState<PriceSection> createState() => _PriceSectionState();
}

class _PriceSectionState extends ConsumerState<PriceSection> {
  bool _asText = false;

  Future<void> _createAlert() async {
    if (!ref.read(isLoggedInProvider)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Entre na sua conta para criar alertas de preço.'),
          ),
        );
      return;
    }
    final flight = widget.flight;
    final target = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AlertSheet(flight: flight),
    );
    if (target == null || !mounted) return;
    try {
      await ref
          .read(priceAlertsNotifierProvider.notifier)
          .create(
            origin: flight.originIataCode,
            destination: flight.destinationIataCode,
            date: flight.departureTime,
            targetPrice: target,
          );
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Alerta criado. Avisamos quando o preço chegar lá.',
              ),
            ),
          );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(priceAlertErrorMessage(error))),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(priceHistoryProvider(widget.flight.id));
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Histórico de preço', style: theme.textTheme.titleMedium),
            const SizedBox(height: DbookSpacing.md),
            history.when(
              loading: () => const SizedBox(
                height: DbookSizes.loadingMd,
                child: DbookLoadingIndicator(),
              ),
              error: (_, _) => Text(
                'Não deu para carregar o histórico agora.',
                style: theme.textTheme.bodySmall,
              ),
              data: (data) => _content(context, data),
            ),
            const SizedBox(height: DbookSpacing.md),
            DbookButton(
              label: 'Criar alerta de preço',
              icon: Icons.notifications_active_outlined,
              variant: DbookButtonVariant.secondary,
              onPressed: _createAlert,
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, PriceHistory data) {
    final theme = Theme.of(context);
    final trendText = switch (data.trend) {
      PriceTrend.below => 'Abaixo da média do voo',
      PriceTrend.above => 'Acima da média do voo',
      PriceTrend.same => 'Na média do voo',
    };
    final trendIcon = switch (data.trend) {
      PriceTrend.below => Icons.trending_down,
      PriceTrend.above => Icons.trending_up,
      PriceTrend.same => Icons.trending_flat,
    };
    final summary =
        'Preço atual ${_money.format(data.current)}, o menor já visto '
        '${_money.format(data.lowest)} e o maior ${_money.format(data.highest)}. $trendText.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(trendIcon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: DbookSpacing.xs),
            Expanded(child: Text(trendText, style: theme.textTheme.labelLarge)),
          ],
        ),
        const SizedBox(height: DbookSpacing.sm),
        Text(
          'Menor ${_money.format(data.lowest)} · Maior ${_money.format(data.highest)}',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: DbookSpacing.md),
        if (data.points.length >= 2 && !_asText)
          Semantics(
            label: summary,
            child: ExcludeSemantics(
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: CustomPaint(
                  painter: _PriceLinePainter(
                    points: data.points,
                    line: theme.colorScheme.primary,
                    grid: theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
          )
        else
          for (final point in data.points.reversed.take(8))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: DbookSpacing.xxs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_shortDate.format(point.changedAt)),
                  Text(_money.format(point.price)),
                ],
              ),
            ),
        if (data.points.length >= 2)
          TextButton(
            onPressed: () => setState(() => _asText = !_asText),
            child: Text(_asText ? 'Ver gráfico' : 'Ver como lista'),
          ),
      ],
    );
  }
}

/// O preço "em degraus": vale até a próxima mudança.
class _PriceLinePainter extends CustomPainter {
  _PriceLinePainter({
    required this.points,
    required this.line,
    required this.grid,
  });

  final List<PricePoint> points;
  final Color line;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    final prices = points.map((p) => p.price);
    final min = prices.reduce((a, b) => a < b ? a : b);
    final max = prices.reduce((a, b) => a > b ? a : b);
    final range = (max - min) == 0 ? 1 : (max - min);
    final t0 = points.first.changedAt.millisecondsSinceEpoch;
    final span = (points.last.changedAt.millisecondsSinceEpoch - t0).clamp(
      1,
      1 << 62,
    );

    double x(PricePoint p) =>
        (p.changedAt.millisecondsSinceEpoch - t0) / span * size.width;
    double y(double price) =>
        size.height - 8 - ((price - min) / range) * (size.height - 16);

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    canvas
      ..drawLine(Offset(0, y(min)), Offset(size.width, y(min)), gridPaint)
      ..drawLine(Offset(0, y(max)), Offset(size.width, y(max)), gridPaint);

    final path = Path()..moveTo(x(points.first), y(points.first.price));
    for (var i = 1; i < points.length; i++) {
      path
        ..lineTo(x(points[i]), y(points[i - 1].price)) // degrau
        ..lineTo(x(points[i]), y(points[i].price));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
    final dot = Paint()..color = line;
    for (final p in points) {
      canvas.drawCircle(Offset(x(p), y(p.price)), 3, dot);
    }
  }

  @override
  bool shouldRepaint(_PriceLinePainter old) =>
      old.points != points || old.line != line;
}

/// Folha para escolher o valor-alvo do alerta (rota e data vêm do voo).
class _AlertSheet extends StatefulWidget {
  const _AlertSheet({required this.flight});

  final Flight flight;

  @override
  State<_AlertSheet> createState() => _AlertSheetState();
}

class _AlertSheetState extends State<_AlertSheet> {
  late final _target = TextEditingController(
    text: (widget.flight.price * 0.9).toStringAsFixed(2),
  );
  String? _error;

  @override
  void dispose() {
    _target.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_target.text.replaceAll(',', '.'));
    if (value == null || value <= 0) {
      setState(() => _error = 'Informe um valor maior que zero.');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        DbookSpacing.lg,
        DbookSpacing.lg,
        DbookSpacing.lg,
        MediaQuery.viewInsetsOf(context).bottom + DbookSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Alerta de preço',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: DbookSpacing.xs),
          Text(
            '${flight.originIataCode} → ${flight.destinationIataCode} em '
            '${_shortDate.format(flight.departureTime)}. Avisamos quando um voo '
            'dessa rota e data custar até o valor abaixo.',
          ),
          const SizedBox(height: DbookSpacing.md),
          TextField(
            controller: _target,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Avisar quando custar até',
              errorText: _error,
            ),
          ),
          const SizedBox(height: DbookSpacing.lg),
          DbookButton(label: 'Criar alerta', onPressed: _submit),
        ],
      ),
    );
  }
}
