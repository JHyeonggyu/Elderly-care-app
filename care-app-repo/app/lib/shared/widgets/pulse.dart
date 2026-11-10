import 'package:flutter/material.dart';

/// 자식을 부드럽게 깜빡이게 함 (LIVE 점, 경고 표시 등)
class Pulse extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double min;
  const Pulse({super.key, required this.child, this.duration = const Duration(milliseconds: 900), this.min = .25});
  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(opacity: Tween(begin: widget.min, end: 1.0).animate(_c), child: widget.child);
}
