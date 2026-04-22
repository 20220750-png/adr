import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routing/app_routes.dart';
import '../widgets/glass.dart';
import '../widgets/kinetic_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onNavigate});

  final void Function(String location) onNavigate;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _orbit;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      widget.onNavigate(AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return KineticShell(
      location: AppRoutes.splash,
      onNavigate: widget.onNavigate,
      maxWidth: 1100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      background: _MeshBackground(),
      child: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: GlassCard(
                borderRadius: 32,
                opacity: 0.20,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.rotate(
                          angle: 0.22,
                          child: Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [scheme.primary, scheme.secondary],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withValues(alpha: 0.22),
                                  blurRadius: 30,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Icon(Icons.grid_view_rounded, color: scheme.onPrimary, size: 56),
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CustomPaint(
                            painter: _OrbitPainter(
                              progress: _orbit,
                              ringColor: scheme.primary.withValues(alpha: 0.18),
                              dotColor: scheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Sudoku Kinetic',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.6,
                        height: 1.0,
                      ),
                    ).animate().fadeIn(duration: 420.ms),
                    const SizedBox(height: 10),
                    Text(
                      'ELECTRIC PRECISION LOGIC',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3.0,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: SizedBox(
                              height: 8,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Container(color: scheme.surfaceContainerHigh),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: 0.67,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [scheme.secondary, scheme.primary],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'INITIALIZING MODULES',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.8,
                                    ),
                              ),
                              Text(
                                '67%',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.8,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 380.ms).scale(begin: const Offset(0.98, 0.98)),
            ),
          ),
          Positioned(
            top: 120,
            right: 90,
            child: Opacity(
              opacity: 0.18,
              child: Transform.rotate(
                angle: -0.2,
                child: Text(
                  '9',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    color: scheme.primary.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 60,
            child: Opacity(
              opacity: 0.18,
              child: Transform.rotate(
                angle: 0.8,
                child: Text(
                  '4',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 110,
                    fontWeight: FontWeight.w900,
                    color: scheme.secondary.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 340,
            right: 20,
            child: Opacity(
              opacity: 0.10,
              child: Transform.rotate(
                angle: -0.2,
                child: Text(
                  '2',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    color: scheme.tertiary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeshBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        gradient: RadialGradient(
          center: const Alignment(-1, -1),
          radius: 1.6,
          colors: [
            scheme.primary.withValues(alpha: 0.16),
            scheme.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 140,
            left: -80,
            child: _Glow(color: scheme.secondary.withValues(alpha: 0.10), size: 420),
          ),
          Positioned(
            bottom: 160,
            right: -80,
            child: _Glow(color: scheme.primary.withValues(alpha: 0.10), size: 380),
          ),
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

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({
    required this.progress,
    required this.ringColor,
    required this.dotColor,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color ringColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, size.width / 2 - 8, ringPaint);

    final angle = progress.value * 2 * 3.141592653589793;
    final radius = size.width / 2 - 8;
    final dot = Offset(center.dx + radius * 0.25 * (cos(angle)), center.dy + radius * 0.25 * (sin(angle)));
    final dotPaint = Paint()..color = dotColor;
    canvas.drawCircle(dot, 6, dotPaint);
    canvas.drawCircle(dot, 14, Paint()..color = dotColor.withValues(alpha: 0.18));
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.ringColor != ringColor || oldDelegate.dotColor != dotColor;
  }
}

