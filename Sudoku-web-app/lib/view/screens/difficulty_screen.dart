import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routing/app_routes.dart';
import '../../core/assets/remote_images.dart';
import '../widgets/hover_scale.dart';
import '../widgets/kinetic_shell.dart';
import '../widgets/kinetic_image.dart';

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key, required this.onNavigate});

  final void Function(String location) onNavigate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return KineticShell(
      location: AppRoutes.difficulty,
      onNavigate: onNavigate,
      maxWidth: 1280,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'SELECT YOUR PRECISION',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isWide ? 56 : 42,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
          ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.03, end: 0),
          const SizedBox(height: 10),
          Text(
            'The grid is primed. Choose your level of engagement and dive into the flow state.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth >= 900 ? 3 : 1;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: cols == 3 ? 1.15 : 2.35,
                children: [
                  _DifficultyCard(
                    title: 'Easy',
                    subtitle: 'Perfect for warming up the neurons.',
                    icon: Icons.child_care_rounded,
                    accent: scheme.primary,
                    badge: null,
                    onTap: () => onNavigate(AppRoutes.game),
                  ),
                  _DifficultyCard(
                    title: 'Medium',
                    subtitle: 'The sweet spot. Recommended.',
                    icon: Icons.psychology_rounded,
                    accent: scheme.secondary,
                    badge: 'Recommended',
                    onTap: () => onNavigate(AppRoutes.game),
                    hero: true,
                  ),
                  _DifficultyCard(
                    title: 'Hard',
                    subtitle: 'For the logic masters. No mercy.',
                    icon: Icons.grid_view_rounded,
                    accent: scheme.tertiary,
                    badge: null,
                    onTap: () => onNavigate(AppRoutes.game),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final twoCols = c.maxWidth >= 900;
              return GridView.count(
                crossAxisCount: twoCols ? 4 : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: twoCols ? 2.8 : 3.0,
                children: [
                  _StatTile(
                    title: 'Daily Streak',
                    value: '14 DAYS',
                    subtitle: 'Global Rank #1,204',
                    tone: scheme.primary,
                    wide: twoCols,
                    span2: true,
                  ),
                  _MetricTile(label: 'Total Solved', value: '342'),
                  _MetricTile(label: 'Fastest Time', value: '4:12', tone: scheme.primary.withValues(alpha: 0.18)),
                ],
              );
            },
          ).animate().fadeIn(delay: 120.ms),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.badge,
    this.hero = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final String? badge;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = hero ? accent.withValues(alpha: 0.08) : scheme.surfaceContainerLow;

    return HoverScale(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: hero ? 0.22 : 0.18)),
            boxShadow: hero
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.14),
                      blurRadius: 40,
                      offset: const Offset(0, 18),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge!,
                      style: GoogleFonts.inter(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: accent, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      'START SESSION',
                      style: GoogleFonts.inter(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: accent),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accent, accent.withValues(alpha: 0.35)]),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.tone,
    required this.wide,
    required this.span2,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color tone;
  final bool wide;
  final bool span2;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: const KineticImage(
              url: RemoteImages.difficultyArt,
              assetFallback: 'assets/images/difficulty_art.jpg',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                        color: tone,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 22),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value, this.tone});

  final String label;
  final String value;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone ?? scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.8),
          ),
        ],
      ),
    );
  }
}

