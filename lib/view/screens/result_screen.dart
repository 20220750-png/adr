import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routing/app_routes.dart';
import '../widgets/glass.dart';
import '../widgets/kinetic_shell.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.onNavigate});

  final void Function(String location) onNavigate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return KineticShell(
      location: AppRoutes.result,
      onNavigate: onNavigate,
      maxWidth: 1280,
      background: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.8, -0.6),
            radius: 1.2,
            colors: [
              scheme.primary.withValues(alpha: 0.12),
              scheme.surface,
            ],
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              GlassCard(
                borderRadius: 32,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: scheme.tertiary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.18)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars_rounded, size: 18, color: scheme.tertiary),
                          const SizedBox(width: 8),
                          Text(
                            'NEW RECORD!',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.6,
                              color: scheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Brilliant Logic!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 52,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You navigated the grid with electric precision.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, c) {
                        final twoCols = c.maxWidth >= 600;
                        return GridView.count(
                          crossAxisCount: twoCols ? 2 : 1,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: twoCols ? 2.6 : 3.0,
                          children: [
                            _StatCard(
                              label: 'COMPLETION TIME',
                              value: '04:12',
                              valueColor: scheme.primary,
                            ),
                            _StatCard(
                              label: 'DIFFICULTY LEVEL',
                              value: 'Expert',
                              valueColor: scheme.secondary,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        FilledButton(
                          onPressed: () => onNavigate(AppRoutes.difficulty),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Play Again',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.refresh_rounded),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => onNavigate(AppRoutes.home),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Back Home',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.home_rounded),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _MiniStat(value: '1,420', label: 'SCORE'),
                        SizedBox(width: 18),
                        _DividerV(),
                        SizedBox(width: 18),
                        _MiniStat(value: '98%', label: 'ACCURACY'),
                        SizedBox(width: 18),
                        _DividerV(),
                        SizedBox(width: 18),
                        _MiniStat(value: '12', label: 'STREAK'),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.04, end: 0),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                children: [
                  _RoundIconButton(icon: Icons.share_rounded, onPressed: () {}),
                  _RoundIconButton(icon: Icons.download_rounded, onPressed: () {}),
                ],
              ).animate().fadeIn(delay: 120.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.valueColor});

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  color: scheme.outline,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 34,
              height: 1.0,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6,
                color: scheme.outline,
              ),
        ),
      ],
    );
  }
}

class _DividerV extends StatelessWidget {
  const _DividerV();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(width: 1, height: 28, color: scheme.outlineVariant.withValues(alpha: 0.25));
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: scheme.onSurfaceVariant),
      ),
    );
  }
}

