import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HoverScale extends StatefulWidget {
  const HoverScale({
    super.key,
    required this.child,
    this.scale = 1.02,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOut,
  });

  final Widget child;
  final double scale;
  final Duration duration;
  final Curve curve;

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final enabled = kIsWeb || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows;

    Widget child = AnimatedScale(
      scale: _hover ? widget.scale : 1.0,
      duration: widget.duration,
      curve: widget.curve,
      child: widget.child,
    );

    if (!enabled) return child;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: child,
    );
  }
}

