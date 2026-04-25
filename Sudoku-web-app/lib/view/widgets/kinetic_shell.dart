import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routing/app_routes.dart';

class KineticShell extends StatelessWidget {
  const KineticShell({
    super.key,
    required this.location,
    required this.onNavigate,
    required this.child,
    this.background,
    this.maxWidth = 1280,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
    this.forcePortraitOnPhone = true,
  });

  final String location;
  final void Function(String location) onNavigate;
  final Widget child;
  final Widget? background;
  final double maxWidth;
  final EdgeInsets contentPadding;
  final bool forcePortraitOnPhone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      body: _ForcePortraitOnPhone(
        enabled: forcePortraitOnPhone,
        child: Stack(
          children: [
            Positioned.fill(
              child: background ??
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.primary.withValues(alpha: 0.08),
                          scheme.secondary.withValues(alpha: 0.06),
                          scheme.tertiary.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
            ),
            Positioned.fill(
              child: Column(
                children: [
                  _TopNav(
                    location: location,
                    onNavigate: onNavigate,
                    showNavLinks: isWide,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(top: 16 + (isWide ? 0 : 0)),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16, vertical: 24),
                            child: Padding(
                              padding: contentPadding.copyWith(
                                left: 0,
                                right: 0,
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const _Footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForcePortraitOnPhone extends StatelessWidget {
  const _ForcePortraitOnPhone({required this.child, required this.enabled});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final media = MediaQuery.of(context);
    final size = media.size;
    final isPhone = size.shortestSide < 600;
    final isLandscape = media.orientation == Orientation.landscape;

    if (!isPhone || !isLandscape) return child;

    // Trên web không thể ép OS xoay màn hình; ta "xoay UI" để luôn hiển thị dạng dọc
    // khi người dùng kéo cửa sổ về kích thước điện thoại ở chế độ ngang.
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: size.height,
          height: size.width,
          child: RotatedBox(quarterTurns: 1, child: child),
        ),
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav({
    required this.location,
    required this.onNavigate,
    required this.showNavLinks,
  });

  final String location;
  final void Function(String location) onNavigate;
  final bool showNavLinks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget navLink(String label, String route) {
      final selected = location == route;
      return InkWell(
        onTap: () => onNavigate(route),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 2,
                width: selected ? 26 : 0,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.80),
            boxShadow: [
              BoxShadow(
                color: scheme.onSurface.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border(
              bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.12)),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Row(
                children: [
                  Text(
                    'KINETIC GRID',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -0.9,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 24),
                  if (showNavLinks) ...[
                    navLink('Home', AppRoutes.home),
                    navLink('Play', AppRoutes.difficulty),
                    navLink('History', AppRoutes.history),
                    navLink('Settings', AppRoutes.settings),
                    navLink('About', AppRoutes.about),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: () => onNavigate(AppRoutes.login),
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.primary,
                      textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900),
                    ),
                    child: const Text('Login'),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => onNavigate(AppRoutes.login),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.account_circle_rounded,
                        color: scheme.onSurfaceVariant,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.72),
            border: Border(
              top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.12)),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'KINETIC GRID',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8, width: 8),
                  Text(
                    '© 2024 KINETIC GRID. ELECTRIC PRECISION.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

