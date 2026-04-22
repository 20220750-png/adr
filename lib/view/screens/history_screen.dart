import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routing/app_routes.dart';
import '../widgets/glass.dart';
import '../widgets/hover_scale.dart';
import '../widgets/kinetic_shell.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.onNavigate});

  final void Function(String location) onNavigate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    final rows = <_HistoryRowData>[
      const _HistoryRowData(date: 'Oct 24, 2024', time: '10:45 AM', difficulty: 'Expert', completion: '06:42', note: '-12s Personal Best', tone: _RowTone.expert),
      const _HistoryRowData(date: 'Oct 23, 2024', time: '09:12 PM', difficulty: 'Hard', completion: '04:15', note: 'Avg Performance', tone: _RowTone.hard),
      const _HistoryRowData(date: 'Oct 23, 2024', time: '04:30 PM', difficulty: 'Medium', completion: 'FAILED', note: '3 Errors Limit', tone: _RowTone.failed),
      const _HistoryRowData(date: 'Oct 22, 2024', time: '08:00 AM', difficulty: 'Medium', completion: '02:55', note: 'Daily Challenge', tone: _RowTone.medium),
    ];

    return KineticShell(
      location: AppRoutes.history,
      onNavigate: onNavigate,
      maxWidth: 1440,
      background: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: scheme.surface),
            ),
          ),
          Positioned(top: -80, left: -80, child: _Glow(color: scheme.primary.withValues(alpha: 0.06), size: 520)),
          Positioned(bottom: -120, right: -120, child: _Glow(color: scheme.secondary.withValues(alpha: 0.06), size: 560)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Game History',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tracking your path to logical mastery.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: const [
                  _MiniBento(label: 'TOTAL SOLVED', value: '1,284', strong: false),
                  SizedBox(width: 12),
                  _StreakBento(),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.02, end: 0),
          const SizedBox(height: 18),
          if (isWide)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Expanded(flex: 3, child: _HeaderCell('Date & Time')),
                  Expanded(flex: 3, child: _HeaderCell('Difficulty', center: true)),
                  Expanded(flex: 3, child: _HeaderCell('Completion', center: true)),
                  Expanded(flex: 3, child: _HeaderCell('Action', right: true)),
                ],
              ),
            ),
          const SizedBox(height: 10),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HistoryRow(row: r, wide: isWide),
              )),
          const SizedBox(height: 18),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              icon: const Icon(Icons.expand_more_rounded),
              label: const Text('Show Older Games'),
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
    ).animate().blurXY(begin: 90, end: 130, duration: 700.ms);
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text, {this.center = false, this.right = false});
  final String text;
  final bool center;
  final bool right;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      textAlign: right ? TextAlign.right : (center ? TextAlign.center : TextAlign.left),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.4,
            color: scheme.outline,
          ),
    );
  }
}

class _MiniBento extends StatelessWidget {
  const _MiniBento({required this.label, required this.value, required this.strong});
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: scheme.primary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _StreakBento extends StatelessWidget {
  const _StreakBento();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT STREAK',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: scheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '12',
                style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 8),
              Icon(Icons.local_fire_department_rounded, color: scheme.tertiary.withValues(alpha: 0.8), size: 22),
            ],
          ),
        ],
      ),
    );
  }
}

enum _RowTone { expert, hard, medium, failed }

class _HistoryRowData {
  const _HistoryRowData({
    required this.date,
    required this.time,
    required this.difficulty,
    required this.completion,
    required this.note,
    required this.tone,
  });

  final String date;
  final String time;
  final String difficulty;
  final String completion;
  final String note;
  final _RowTone tone;
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.row, required this.wide});

  final _HistoryRowData row;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (pillBg, pillFg) = switch (row.tone) {
      _RowTone.expert => (scheme.tertiary.withValues(alpha: 0.10), scheme.tertiary),
      _RowTone.hard => (scheme.secondary.withValues(alpha: 0.10), scheme.secondary),
      _RowTone.medium => (scheme.primary.withValues(alpha: 0.10), scheme.primary),
      _RowTone.failed => (scheme.primary.withValues(alpha: 0.10), scheme.primary),
    };

    final completionColor = row.tone == _RowTone.failed ? scheme.error : scheme.onSurface;
    final noteColor = row.tone == _RowTone.failed ? scheme.error : (row.note.startsWith('-') ? scheme.primary : scheme.onSurfaceVariant);

    return HoverScale(
      child: GlassCard(
        opacity: 0.55,
        borderRadius: 18,
        padding: const EdgeInsets.all(18),
        child: wide
            ? Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.date, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        Text(row.time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: pillFg.withValues(alpha: 0.20)),
                        ),
                        child: Text(
                          row.difficulty.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: pillFg,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.6,
                              ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Text(row.completion, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: completionColor)),
                        const SizedBox(height: 2),
                        Text(row.note, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: noteColor, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.surfaceContainerHighest,
                          foregroundColor: scheme.onSurface,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(row.tone == _RowTone.failed ? 'Retry Seed' : 'View Grid', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
                            const SizedBox(width: 8),
                            Icon(row.tone == _RowTone.failed ? Icons.refresh_rounded : Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(row.date, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(row.time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: pillFg.withValues(alpha: 0.20)),
                        ),
                        child: Text(
                          row.difficulty.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: pillFg,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.6,
                              ),
                        ),
                      ),
                      const Spacer(),
                      Text(row.completion, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: completionColor)),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

