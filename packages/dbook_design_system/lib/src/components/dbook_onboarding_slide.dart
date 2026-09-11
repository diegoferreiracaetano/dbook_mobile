import 'package:flutter/material.dart';

import '../tokens/dbook_spacing.dart';
import 'dbook_page_indicator.dart';

/// Slide de onboarding — fundo (foto/gradiente) + degradê escuro no
/// rodapé + título/subtítulo + dots + ação primária, com "Skip" opcional
/// (some na última página).
class DbookOnboardingSlide extends StatelessWidget {
  const DbookOnboardingSlide({
    super.key,
    required this.background,
    required this.title,
    required this.subtitle,
    required this.pageCount,
    required this.currentIndex,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.onSkip,
  });

  final Decoration background;
  final String title;
  final String subtitle;
  final int pageCount;
  final int currentIndex;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: background,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC000000)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DbookSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: DbookSpacing.sm),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: DbookSpacing.xl),
                    DbookPageIndicator(
                      pageCount: pageCount,
                      currentIndex: currentIndex,
                    ),
                    const SizedBox(height: DbookSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (onSkip != null)
                          TextButton(
                            onPressed: onSkip,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Skip'),
                          )
                        else
                          const SizedBox.shrink(),
                        ElevatedButton(
                          onPressed: onPrimaryAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .primary,
                          ),
                          child: Text(primaryActionLabel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
