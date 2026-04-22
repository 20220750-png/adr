import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routing/app_routes.dart';
import '../../core/assets/remote_images.dart';
import '../widgets/glass.dart';
import '../widgets/hover_scale.dart';
import '../widgets/kinetic_shell.dart';
import '../widgets/kinetic_image.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.onNavigate});

  final void Function(String location) onNavigate;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _paused = false;

  void _setPaused(bool v) => setState(() => _paused = v);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    // Tránh RenderFlex overflow (vệt vàng/đen) khi màn hình chưa đủ rộng cho 3 cột.
    // (Board + 2 side panels + padding có thể vượt 1240 tuỳ zoom/font → để ngưỡng an toàn hơn.)
    final useThreeColumns = width >= 1500;
    final isWide = width >= 800;

    return KineticShell(
      location: AppRoutes.game,
      onNavigate: widget.onNavigate,
      background: DecoratedBox(
        decoration: BoxDecoration(color: scheme.surface),
        child: CustomPaint(
          painter: _DotGridPainter(color: scheme.surfaceVariant.withValues(alpha: 0.75)),
          child: const SizedBox.expand(),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16, vertical: 18),
            child: useThreeColumns
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 320, child: _LeftPanel(onPause: () => _setPaused(true))),
                      const SizedBox(width: 16),
                      Expanded(child: _Board()),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 320,
                        child: _RightPanel(onCheck: () => widget.onNavigate(AppRoutes.result)),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      // Không dùng Expanded trong SingleChildScrollView (dễ crash -> màn trắng/overflow).
                      _Board(),
                      const SizedBox(height: 12),
                      _NumberPad(),
                      const SizedBox(height: 12),
                      _ActionRow(onCheck: () => widget.onNavigate(AppRoutes.result)),
                      const SizedBox(height: 12),
                      _Mistakes(),
                    ],
                  ),
          ),
          if (_paused) ...[
            Positioned.fill(
              child: Container(color: scheme.onSurface.withValues(alpha: 0.12))
                  .animate()
                  .fadeIn(duration: 180.ms),
            ),
            Positioned.fill(
              child: Center(
                child: _PauseModal(
                  onContinue: () => _setPaused(false),
                  onRestart: () => _setPaused(false),
                  onExit: () => widget.onNavigate(AppRoutes.home),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LeftPanel extends StatelessWidget {
  const _LeftPanel({required this.onPause});

  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          borderRadius: 18,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DIFFICULTY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w900,
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: scheme.secondary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'EXPERT',
                      style: GoogleFonts.plusJakartaSans(
                        color: scheme.onSecondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      _Dot(color: scheme.secondary),
                      _Dot(color: scheme.secondary),
                      _Dot(color: scheme.secondary),
                      _Dot(color: scheme.secondary.withValues(alpha: 0.30)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'ELAPSED TIME',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w900,
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '12:45',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 44,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 16),
              _MenuButton(
                icon: Icons.pause_circle_filled_rounded,
                label: 'Pause Game',
                kbd: 'ESC',
                onPressed: onPause,
              ),
              const SizedBox(height: 10),
              _MenuButton(icon: Icons.new_label_rounded, label: 'New Puzzle', onPressed: () {}),
              const SizedBox(height: 10),
              _MenuButton(icon: Icons.lightbulb_rounded, label: 'Daily Challenge', onPressed: () {}),
            ],
          ),
        ),
        const SizedBox(height: 12),
        HoverScale(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: const KineticImage(
                    url: RemoteImages.gameTip,
                    assetFallback: 'assets/images/game_tip.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          scheme.secondary.withValues(alpha: 0.82),
                          scheme.secondary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 14,
                  bottom: 12,
                  right: 14,
                  child: Text(
                    'PRO TIP: Use Notes for Expert Mode',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({required this.onCheck});

  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NumberPad(),
        const SizedBox(height: 12),
        _ActionRow(onCheck: onCheck),
        const SizedBox(height: 12),
        _Mistakes(),
      ],
    );
  }
}

class _Board extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, c) {
        // Board phải co giãn theo bề ngang thực tế (tránh RenderFlex overflow -> sọc vàng/đen).
        // Kích thước tính theo "grid + gaps" thay vì dựa vào MediaQuery screen width.
        const outerPad = 8.0;
        const innerPad = 2.0;
        const gapThin = 1.0;
        const gapThick = 3.0;
        const targetCell = 56.0;
        const minCell = 34.0;

        // Có 8 khe giữa 9 ô: 6 khe mỏng + 2 khe dày (sau c=2 và c=5).
        const gapsPerRow = gapThin * 6 + gapThick * 2;
        final availableForGrid = (c.maxWidth - (outerPad * 2) - (innerPad * 2)).clamp(0.0, double.infinity);
        final computed = ((availableForGrid - gapsPerRow) / 9).floorToDouble();
        final cellSize = computed.clamp(minCell, targetCell);

        final isWideText = cellSize >= 48;

        return Center(
          child: Container(
            padding: const EdgeInsets.all(outerPad),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: scheme.onSurface.withValues(alpha: 0.10),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(innerPad),
              decoration: BoxDecoration(
                color: scheme.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(9, (r) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(9, (cIdx) {
                      final thickRight = (cIdx == 2 || cIdx == 5);
                      final thickBottom = (r == 2 || r == 5);
                      final isLastCol = cIdx == 8;
                      final isLastRow = r == 8;
                      final isSelected = (r == 4 && cIdx == 4);
                      final isPrimaryChip = (r == 2 && cIdx == 4);

                      final bg = isSelected ? scheme.primary.withValues(alpha: 0.22) : scheme.surfaceContainerHigh;

                      return Container(
                        width: cellSize,
                        height: cellSize,
                        margin: EdgeInsets.only(
                          right: isLastCol ? 0 : (thickRight ? gapThick : gapThin),
                          bottom: isLastRow ? 0 : (thickBottom ? gapThick : gapThin),
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          duration: 220.ms,
                          width: isPrimaryChip ? (cellSize - 8).clamp(0.0, cellSize) : cellSize,
                          height: isPrimaryChip ? (cellSize - 8).clamp(0.0, cellSize) : cellSize,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isPrimaryChip ? scheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isPrimaryChip
                                ? [
                                    BoxShadow(
                                      color: scheme.primary.withValues(alpha: 0.22),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            (r == 0 && cIdx == 0) ? '5' : (isPrimaryChip ? '7' : ''),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: isWideText ? 26 : 20,
                              fontWeight: FontWeight.w900,
                              color: isPrimaryChip ? scheme.onPrimary : scheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NumberPad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'INPUT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: isWide ? 1.2 : 2.4,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(9, (i) {
              final n = i + 1;
              final selected = n == 7;
              return HoverScale(
                scale: 1.03,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: selected ? scheme.secondary : scheme.surfaceVariant,
                    foregroundColor: selected ? scheme.onSecondary : scheme.onSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    '$n',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 22),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: scheme.surfaceVariant,
            ),
            icon: const Icon(Icons.backspace_rounded),
            label: Text(
              'Clear Cell',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.onCheck});

  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () {},
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: const Icon(Icons.auto_fix_high_rounded),
          label: Text('Hint (3 left)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: scheme.surfaceContainerHigh,
                ),
                icon: const Icon(Icons.restart_alt_rounded),
                label: Text('Reset', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCheck,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: scheme.surfaceContainerHigh,
                ),
                icon: const Icon(Icons.done_all_rounded),
                label: Text('Check', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Mistakes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.30), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'MISTAKES',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: scheme.onSurfaceVariant,
                ),
          ),
          Row(
            children: [
              Icon(Icons.close_rounded, color: scheme.error),
              Icon(Icons.close_rounded, color: scheme.error),
              Icon(Icons.close_rounded, color: scheme.outlineVariant),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.icon, required this.label, required this.onPressed, this.kbd});

  final IconData icon;
  final String label;
  final String? kbd;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return HoverScale(
      scale: 1.01,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (kbd != null)
                Text(
                  kbd!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _PauseModal extends StatelessWidget {
  const _PauseModal({required this.onContinue, required this.onRestart, required this.onExit});

  final VoidCallback onContinue;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      opacity: 0.90,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ).animate().fadeIn(duration: 180.ms).blurXY(begin: 14, end: 22),
                Transform.rotate(
                  angle: -0.05,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [scheme.primary, scheme.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.22),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Icon(Icons.pause_rounded, color: scheme.onPrimary, size: 44),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Game Paused',
              style: GoogleFonts.plusJakartaSans(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1.0),
            ),
            const SizedBox(height: 8),
            Text(
              "Logic doesn't stop, but you can. Take a breath and dive back in.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text('Continue', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRestart,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      backgroundColor: scheme.surfaceVariant,
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text('Restart', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onExit,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      backgroundColor: scheme.surfaceVariant,
                      foregroundColor: scheme.tertiary,
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: Text('Exit Game', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Dot(color: scheme.primary.withValues(alpha: 0.25)),
                _Dot(color: scheme.secondary.withValues(alpha: 0.25)),
                _Dot(color: scheme.tertiary.withValues(alpha: 0.25)),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 220.ms).scale(begin: const Offset(0.97, 0.97), end: const Offset(1.05, 1.05));
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const step = 40.0;
    const r = 1.0;
    for (double y = 2; y < size.height; y += step) {
      for (double x = 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) => oldDelegate.color != color;
}

