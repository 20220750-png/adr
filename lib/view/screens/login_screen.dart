import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routing/app_routes.dart';
import '../../core/assets/remote_images.dart';
import '../widgets/glass.dart';
import '../widgets/kinetic_shell.dart';
import '../widgets/kinetic_image.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onNavigate});

  final void Function(String location) onNavigate;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return KineticShell(
      location: AppRoutes.login,
      onNavigate: widget.onNavigate,
      maxWidth: 1080,
      contentPadding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.12),
                blurRadius: 60,
                offset: const Offset(0, 26),
              ),
            ],
          ),
          // Quan trọng: trong KineticShell có SingleChildScrollView nên phải "bound" chiều cao
          // để tránh Row/Expanded bị unbounded height (gây màn trắng).
          child: isWide
              ? SizedBox(
                  height: 680,
                  child: Row(
                    children: [
                      Expanded(child: _VisualSide()),
                      Expanded(child: _FormSide(emailCtrl: _emailCtrl, passCtrl: _passCtrl)),
                    ],
                  ),
                )
              : _FormSide(emailCtrl: _emailCtrl, passCtrl: _passCtrl),
        ).animate().fadeIn(duration: 420.ms).scale(begin: const Offset(0.98, 0.98)),
      ),
    );
  }
}

class _VisualSide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, const Color(0xFF2170E4)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.10,
              child: Transform.rotate(
                angle: 0.2,
                child: GridView.count(
                  crossAxisCount: 9,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(9 * 12, (i) {
                    final selected = i == 13;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                        borderRadius: BorderRadius.circular(4),
                        color: selected ? Colors.white.withValues(alpha: 0.40) : Colors.transparent,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Text(
                  'SEASON 04 ACTIVE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.92),
                    letterSpacing: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'MASTER THE\nDIGITAL GRID.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 40,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Join over 50,000 solvers in the world\'s most high-octane logic environment.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
              const Spacer(),
              _FeatureRow(icon: Icons.bolt_rounded, title: 'Instant Sync', subtitle: 'Across all your devices'),
              const SizedBox(height: 12),
              _FeatureRow(icon: Icons.emoji_events_rounded, title: 'Global Rankings', subtitle: 'Climb the leaderboard today'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
            Text(subtitle, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.70), fontWeight: FontWeight.w600, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

class _FormSide extends StatelessWidget {
  const _FormSide({required this.emailCtrl, required this.passCtrl});

  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.surfaceContainerLowest,
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome Back',
                style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.6),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter your credentials to access your dashboard',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),
              Text(
                'EMAIL ADDRESS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              _Input(
                controller: emailCtrl,
                icon: Icons.mail_rounded,
                hint: 'name@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PASSWORD',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.6,
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    'Forgot?',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _Input(
                controller: passCtrl,
                icon: Icons.lock_rounded,
                hint: '••••••••',
                obscureText: true,
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: scheme.primary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('SIGN IN', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, letterSpacing: 0.6)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Stack(
                alignment: Alignment.center,
                children: [
                  Divider(color: scheme.outlineVariant.withValues(alpha: 0.35)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const KineticImage(
                            url: RemoteImages.googleG,
                            assetFallback: 'assets/images/google_g.png',
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10),
                          Text('Google', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.apple),
                          const SizedBox(width: 10),
                          Text('Apple', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GlassCard(
                opacity: 0.0,
                borderRadius: 0,
                padding: EdgeInsets.zero,
                child: Text(
                  "Don't have an account? Create an account",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: scheme.outline),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

