import 'package:flutter/material.dart';

import '../tokens/dbook_motion.dart';
import '../tokens/dbook_radius.dart';

/// Barra cinza que pulsa enquanto o conteúdo real carrega. Com "reduzir
/// animações" ligado no sistema, fica parada: o esqueleto continua dizendo
/// "carregando" sem movimento. Decorativo para leitor de tela (quem anuncia o
/// carregamento é o componente que o usa).
class DbookSkeleton extends StatefulWidget {
  const DbookSkeleton({super.key, this.width, this.height = 14});

  final double? width;
  final double height;

  @override
  State<DbookSkeleton> createState() => _DbookSkeletonState();
}

class _DbookSkeletonState extends State<DbookSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: DbookMotion.slow * 3,
  );
  bool _animating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shouldAnimate = !MediaQuery.disableAnimationsOf(context);
    if (shouldAnimate == _animating) return;
    _animating = shouldAnimate;
    if (shouldAnimate) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              colorScheme.outlineVariant,
              colorScheme.outline,
              _controller.value * 0.6,
            ),
            borderRadius: BorderRadius.circular(DbookRadius.xs),
          ),
        ),
      ),
    );
  }
}
