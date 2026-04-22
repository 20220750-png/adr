import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/routing/app_routes.dart';
import '../../viewmodel/notifiers/settings_notifier.dart';
import '../widgets/glass.dart';
import '../widgets/hover_scale.dart';
import '../widgets/kinetic_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onNavigate});

  final void Function(String location) onNavigate;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return KineticShell(
      location: AppRoutes.settings,
      onNavigate: onNavigate,
      maxWidth: 1100,
      background: Stack(
        children: [
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(color: scheme.surface))),
          Positioned(top: 80, right: 140, child: _Glow(color: scheme.primary.withValues(alpha: 0.10), size: 420)),
          Positioned(bottom: 120, left: 80, child: _Glow(color: scheme.secondary.withValues(alpha: 0.06), size: 560)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Settings',
            style: GoogleFonts.plusJakartaSans(fontSize: 46, fontWeight: FontWeight.w900, letterSpacing: -1.2),
          ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.02, end: 0),
          const SizedBox(height: 6),
          Text(
            'Fine-tune your kinetic experience.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: isWide ? 2 : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: isWide ? 1.35 : 1.15,
            children: [
              GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(icon: Icons.palette_rounded, color: scheme.primary, title: 'Appearance'),
                    const SizedBox(height: 14),
                    _ToggleRow(
                      title: 'Dark Mode',
                      subtitle: 'Switch to high-contrast nocturnal mode',
                      value: settings.themeMode == ThemeMode.dark,
                      onChanged: (v) => settings.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
                      onColor: scheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    Text('Theme Color', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _ColorDot(color: scheme.primary, selected: true),
                        const SizedBox(width: 12),
                        _ColorDot(color: scheme.secondary),
                        const SizedBox(width: 12),
                        _ColorDot(color: scheme.tertiary),
                        const SizedBox(width: 12),
                        _ColorDot(color: const Color(0xFF00897B)),
                      ],
                    ),
                  ],
                ),
              ),
              GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(icon: Icons.sports_esports_rounded, color: scheme.secondary, title: 'Gameplay'),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Animation Speed', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: scheme.secondary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Fast', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.secondary, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      ),
                      child: Slider(
                        min: 1,
                        max: 3,
                        divisions: 2,
                        value: 3,
                        onChanged: (_) {},
                        activeColor: scheme.secondary,
                        inactiveColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _TinyLabel('Smooth'),
                          _TinyLabel('Standard'),
                          _TinyLabel('Kinetic'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ToggleRow(
                      title: 'Show Mistakes',
                      subtitle: 'Highlight invalid numbers immediately',
                      value: true,
                      onChanged: (_) {},
                      onColor: scheme.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(icon: Icons.volume_up_rounded, color: scheme.tertiary, title: 'Audio'),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: isWide ? 2 : 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 16,
                  childAspectRatio: isWide ? 3.4 : 3.0,
                  children: [
                    _ToggleRow(
                      title: 'Sound Effects',
                      subtitle: 'Tactile feedback on every move',
                      value: settings.soundEnabled,
                      onChanged: settings.setSoundEnabled,
                      onColor: scheme.tertiary,
                    ),
                    _ToggleRow(
                      title: 'Background Music',
                      subtitle: 'Ambient pulses for deep focus',
                      value: true,
                      onChanged: (_) {},
                      onColor: scheme.tertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Column(
              children: [
                Container(width: 90, height: 1, color: scheme.outlineVariant.withValues(alpha: 0.25)),
                const SizedBox(height: 16),
                HoverScale(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      foregroundColor: scheme.error,
                      side: BorderSide(color: scheme.error.withValues(alpha: 0.18), width: 2),
                    ),
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: Text('Reset All Progress', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    'Caution: This will permanently erase your high scores, levels unlocked, and statistics. This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600, height: 1.4),
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
    ).animate().blurXY(begin: 90, end: 140, duration: 700.ms);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.color, required this.title});
  final IconData icon;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 20)),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, this.selected = false});
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return HoverScale(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          border: selected ? Border.all(color: scheme.surfaceContainer, width: 4) : null,
          boxShadow: selected ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 6))] : null,
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.onColor,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _KineticSwitch(value: value, onChanged: onChanged, onColor: onColor),
      ],
    );
  }
}

class _KineticSwitch extends StatelessWidget {
  const _KineticSwitch({required this.value, required this.onChanged, required this.onColor});
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 56,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? onColor : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [BoxShadow(color: scheme.onSurface.withValues(alpha: 0.10), blurRadius: 8, offset: const Offset(0, 4))],
            ),
          ),
        ),
      ),
    );
  }
}

class _TinyLabel extends StatelessWidget {
  const _TinyLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
          ),
    );
  }
}

