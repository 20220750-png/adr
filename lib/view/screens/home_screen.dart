import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routing/app_routes.dart';
import '../../core/assets/remote_images.dart';
import '../widgets/glass.dart';
import '../widgets/hover_scale.dart';
import '../widgets/kinetic_shell.dart';
import '../widgets/kinetic_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final void Function(String location) onNavigate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return KineticShell(
      location: AppRoutes.home,
      onNavigate: onNavigate,
      maxWidth: 1280,
      background: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: 0.08),
                    scheme.secondary.withValues(alpha: 0.06),
                    scheme.tertiary.withValues(alpha: 0.06),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -80,
            child: _Glow(color: scheme.primary.withValues(alpha: 0.08), size: 600),
          ),
          Positioned(
            bottom: -120,
            left: -120,
            child: _Glow(color: scheme.secondary.withValues(alpha: 0.08), size: 520),
          ),
          Positioned(
            top: 220,
            left: 280,
            child: _Glow(color: scheme.tertiary.withValues(alpha: 0.05), size: 720),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ).animate().fadeIn(duration: 300.ms).then().fadeOut(duration: 300.ms).then().fadeIn(duration: 300.ms),
                const SizedBox(width: 10),
                Text(
                  'DAILY CHALLENGE LIVE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.03, end: 0),
          const SizedBox(height: 16),
          Text(
            'Play\nSudoku',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isWide ? 96 : 64,
              height: 0.92,
              fontWeight: FontWeight.w900,
              letterSpacing: -2.2,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              'Experience the next evolution of logic. A high-octane grid interface designed for speed, precision, and cognitive dominance.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(
                onPressed: () => onNavigate(AppRoutes.difficulty),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text('Start Game', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18)),
              ),
              OutlinedButton(
                onPressed: () => onNavigate(AppRoutes.game),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text('Quick Play', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18)),
              ),
            ],
          ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.03, end: 0),
          const SizedBox(height: 20),
          _FloatingGrid().animate().fadeIn(delay: 140.ms).slideY(begin: 0.05, end: 0),
          const SizedBox(height: 24),
          _BentoGrid(onNavigate: onNavigate),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
    ).animate().blurXY(begin: 80, end: 120, duration: 600.ms);
  }
}

class _FloatingGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final w = MediaQuery.sizeOf(context).width;
    final showExtra = w >= 900;

    Widget cell({String? text, Color? bg, Color? fg}) {
      return Container(
        decoration: BoxDecoration(
          color: bg ?? scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: text == null
            ? const SizedBox.shrink()
            : Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: fg ?? scheme.onSurface.withValues(alpha: 0.22),
                ),
              ),
      );
    }

    final cells = <Widget>[
      cell(text: '5'),
      cell(text: '3', bg: scheme.primary.withValues(alpha: 0.12), fg: scheme.primary),
      cell(),
      cell(),
      cell(text: '7', bg: scheme.secondary.withValues(alpha: 0.12), fg: scheme.secondary),
      cell(),
      cell(),
      cell(),
      cell(),
      cell(text: '6'),
      cell(),
      cell(),
      cell(text: '1', bg: scheme.tertiary.withValues(alpha: 0.12), fg: scheme.tertiary),
      cell(text: '9', bg: scheme.primary.withValues(alpha: 0.20), fg: scheme.primary),
      cell(text: '5', bg: scheme.tertiary.withValues(alpha: 0.12), fg: scheme.tertiary),
      cell(),
      cell(),
      cell(),
    ];

    if (showExtra) {
      cells.addAll(List.generate(9, (_) => cell()));
      cells[19] = cell(text: '9', bg: scheme.secondary.withValues(alpha: 0.20), fg: scheme.secondary);
      cells[25] = cell(text: '8', bg: scheme.primary.withValues(alpha: 0.20), fg: scheme.primary);
    }

    return Transform.rotate(
      angle: 0.035,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withValues(alpha: 0.10),
              blurRadius: 50,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final cols = 9;
            final gap = showExtra ? 10.0 : 6.0;
            final cellSize = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: cells
                  .map(
                    (e) => SizedBox(width: cellSize, height: cellSize, child: e),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class _BentoGrid extends StatelessWidget {
  const _BentoGrid({required this.onNavigate});
  final void Function(String location) onNavigate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    if (!isWide) {
      return Column(
        children: [
          _ContinueCard(onPressed: () => onNavigate(AppRoutes.game)),
          const SizedBox(height: 16),
          _HistoryCard(onPressed: () => onNavigate(AppRoutes.history)),
          const SizedBox(height: 16),
          _SettingsCard(onPressed: () => onNavigate(AppRoutes.settings)),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: _ContinueCard(onPressed: () => onNavigate(AppRoutes.game))),
            const SizedBox(width: 16),
            Expanded(child: _HistoryCard(onPressed: () => onNavigate(AppRoutes.history))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _SettingsCard(onPressed: () => onNavigate(AppRoutes.settings))),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _DailyStreakCard(onPressed: () => onNavigate(AppRoutes.difficulty))),
          ],
        ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    return HoverScale(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: 320,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.22,
                  child: const KineticImage(
                    url: RemoteImages.homeContinue,
                    assetFallback: 'assets/images/home_continue.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.play_circle_rounded, color: scheme.primary),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'RESUME PLAY',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'Continue Session',
                      style: GoogleFonts.plusJakartaSans(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pick up exactly where you left off on your Master Level puzzle. 42% complete.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return HoverScale(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: 320,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.secondary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.history_rounded, color: scheme.secondary),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('248', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 22, color: scheme.secondary)),
                      Text('WINS', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2.0, fontWeight: FontWeight.w900, color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('History', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
              const SizedBox(height: 6),
              Text(
                'Analyze your past strategies and improve your solve times.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Bar(h: 0.5, c: scheme.secondary.withValues(alpha: 0.20)),
                    _Bar(h: 0.75, c: scheme.secondary.withValues(alpha: 0.40)),
                    _Bar(h: 0.66, c: scheme.secondary.withValues(alpha: 0.60)),
                    _Bar(h: 0.5, c: scheme.secondary.withValues(alpha: 0.30)),
                    _Bar(h: 1.0, c: scheme.secondary.withValues(alpha: 0.80)),
                    _Bar(h: 0.75, c: scheme.secondary.withValues(alpha: 0.50)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.h, required this.c});
  final double h;
  final Color c;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 52 * h,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return HoverScale(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: 320,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.transparent),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.tertiary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.settings_rounded, color: scheme.tertiary),
                  ),
                  const SizedBox(width: 10),
                  Text('Settings', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 14),
              _KV(k: 'Visual Theme', v: 'Vivid Grid', strong: true),
              _KV(k: 'Game Assist', v: 'Off'),
              _KV(k: 'Sound Effects', v: '80%', strong: true),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: scheme.onSurface.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 6)),
                  ],
                ),
                child: Text('Configure Profile', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KV extends StatelessWidget {
  const _KV({required this.k, required this.v, this.strong = false});
  final String k;
  final String v;
  final bool strong;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
          Text(
            v,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: strong ? scheme.primary : scheme.onSurface.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _DailyStreakCard extends StatelessWidget {
  const _DailyStreakCard({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return HoverScale(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: 320,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.secondary, scheme.secondaryContainer],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Streak',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                        color: scheme.onSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "You've solved the daily puzzle for 12 days straight. Don't break the cycle!",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSecondary.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Day 13 Puzzle',
                            style: GoogleFonts.plusJakartaSans(
                              color: scheme.onSecondary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Play Now',
                            style: GoogleFonts.plusJakartaSans(
                              color: scheme.secondary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '12',
                      style: GoogleFonts.plusJakartaSans(
                        color: scheme.onSecondary,
                        fontWeight: FontWeight.w900,
                        fontSize: 44,
                      ),
                    ),
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        value: 0.72,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


