import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/life_state.dart';

/// 하루 24시간을 고리로 보여주고, 가운데에 현재 상태를 표시
class DayRing extends StatefulWidget {
  final Life life;
  final String location;
  const DayRing({super.key, required this.life, required this.location});

  // (시작시, 끝시, 톤) 톤: 0 수면, 1 활동, 2 외출, 3 휴식
  static const bands = {
    Life.active: [(0, 7, 0), (7, 10, 1), (10, 12, 2), (12, 15, 3), (15, 24, 0)],
    Life.resting: [(0, 7, 0), (7, 10, 1), (10, 12, 2), (12, 24, 3)],
    Life.sleeping: [(0, 24, 0)],
    Life.away: [(0, 7, 0), (7, 10, 1), (10, 24, 2)],
  };
  @override
  State<DayRing> createState() => _DayRingState();
}

class _DayRingState extends State<DayRing> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat();
  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  static const tones = [Color(0xFFCFD9E6), AppColors.pri, Color(0xFF9FB3C8), Color(0xFF5B8DEF)];

  @override
  Widget build(BuildContext context) {
    final l = widget.life;
    return SizedBox(
      width: 236, height: 236,
      child: Stack(alignment: Alignment.center, children: [
        TweenAnimationBuilder<double>(
          key: ValueKey(l),
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
          builder: (_, v, __) => CustomPaint(size: const Size(236, 236), painter: _RingPainter(DayRing.bands[l]!, v, l.color)),
        ),
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Stack(alignment: Alignment.center, children: [
            for (final k in [0.0, .5])
              Builder(builder: (_) {
                final t = (_pulse.value + k) % 1;
                return Opacity(opacity: .5 * (1 - t), child: Transform.scale(scale: .8 + .7 * t, child: Container(width: 126, height: 126, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: l.color, width: 1.5)))));
              }),
          ]),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 46, height: 46,
            decoration: BoxDecoration(color: l.color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: l.color.withOpacity(.4), blurRadius: 18, offset: const Offset(0, 8), spreadRadius: -6)]),
            child: Icon(l.icon, color: Colors.white, size: 23),
          ),
          const SizedBox(height: 7),
          AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: Text(l.label, key: ValueKey(l), style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700, letterSpacing: -.6))),
          Text(widget.location, style: const TextStyle(fontSize: 12.5, color: AppColors.sub)),
        ]),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  final List<(int, int, int)> bands;
  final double progress;
  final Color accent;
  _RingPainter(this.bands, this.progress, this.accent);

  @override
  void paint(Canvas c, Size s) {
    final k = s.width / 240, ctr = Offset(s.width / 2, s.height / 2), r = 104 * k;
    double ang(double h) => h * 2 * math.pi / 24 - math.pi / 2;
    for (var i = 0; i < bands.length; i++) {
      final (a, b, t) = bands[i];
      final f = (progress * bands.length - i).clamp(0.0, 1.0);
      const gap = .28;
      final sweep = (b - a - gap * 2) * 2 * math.pi / 24 * f;
      if (sweep <= 0) continue;
      c.drawArc(Rect.fromCircle(center: ctr, radius: r), ang(a + gap), sweep, false, Paint()..color = _DayRingTones.at(t)..style = PaintingStyle.stroke..strokeWidth = 11 * k..strokeCap = StrokeCap.round);
    }
    final np = ctr + Offset(math.cos(ang(14.33)), math.sin(ang(14.33))) * r;
    c.drawCircle(np, 9 * k, Paint()..color = Colors.white);
    c.drawCircle(np, 9 * k, Paint()..color = accent..style = PaintingStyle.stroke..strokeWidth = 4 * k);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.progress != progress || o.bands != bands || o.accent != accent;
}

class _DayRingTones {
  static Color at(int t) => _DayRingState.tones[t];
}
