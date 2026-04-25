import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/routing/app_routes.dart';
import '../../core/assets/remote_images.dart';
import '../widgets/kinetic_image.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.onNavigate});

  final void Function(String location) onNavigate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => onNavigate(AppRoutes.home),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.secondary.withValues(alpha: 0.10),
              scheme.primary.withValues(alpha: 0.10),
              scheme.tertiary.withValues(alpha: 0.06),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [scheme.primary, scheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.25),
                            blurRadius: 40,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Icon(Icons.grid_view_rounded, color: scheme.onPrimary, size: 56),
                    ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.95, 0.95)),
                    const SizedBox(height: 18),
                    Text(
                      'The grid is alive.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.2,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sudoku Kinetic merges high-energy aesthetics with clinical precision.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 22),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 900;
                        return Flex(
                          direction: wide ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 8,
                              child: _GlassCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Our Philosophy',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Traditional Sudoku is clinical, static, and often cold. We believe logic should feel electric.',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            height: 1.4,
                                          ),
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(999),
                                          child: const KineticImage(
                                            url: RemoteImages.aboutFounder,
                                            assetFallback: 'assets/images/about_founder.jpg',
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Kinetic Labs',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                            ),
                                            Text(
                                              'Precision Engineering Team',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: scheme.onSurfaceVariant,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: wide ? 16 : 0, height: wide ? 0 : 16),
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  _GlassCard(
                                    child: Column(
                                      children: [
                                        Text(
                                          '60FPS',
                                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                                color: scheme.primary,
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                        Text(
                                          'Smooth Animations',
                                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 1.4,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: scheme.secondary,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: scheme.secondary.withValues(alpha: 0.25),
                                          blurRadius: 30,
                                          offset: const Offset(0, 14),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(Icons.vibration_rounded, color: scheme.onSecondary, size: 34),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Haptic Logic',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: scheme.onSecondary,
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tactile feedback on every move',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: scheme.onSecondary.withValues(alpha: 0.85),
                                                fontWeight: FontWeight.w600,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 5,
                            child: const KineticImage(
                              url: RemoteImages.aboutGrid,
                              assetFallback: 'assets/images/about_grid.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    scheme.onSurface.withValues(alpha: 0.75),
                                    scheme.onSurface.withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 18,
                            top: 18,
                            child: Text(
                              'Electric Precision.',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 420.ms),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: () => onNavigate(AppRoutes.difficulty),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Start Playing'),
                    ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.05, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.22)),
      ),
      child: child,
    );
  }
}

