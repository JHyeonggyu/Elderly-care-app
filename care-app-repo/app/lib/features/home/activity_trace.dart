import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/life_state.dart';
import 'day_ring.dart';

/// 하루 활동 곡선 (현재 시각 이후는 흐리게)
class ActivityTrace extends StatelessWidget {
  final Life life;
  const ActivityTrace({super.key, required this.life});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        key: ValueKey(life),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeOut,
        builder: (_, v, __) => SizedBox(height: 84, width: double.infinity, child: CustomPaint(painter: _TracePainter(life, v))),
      );
}

class _TracePainter extends CustomPainter {
  final Life life;
  final double progress;
  _TracePainter(this.life, this.progress);
  static const _lv = [8.0, 72.0, 14.0, 30.0];

  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    final bands = _DayRingBands.of(life);
    final pts = <Offset>[];
    for (var x = 0; x <= 24; x++) {
      final b = bands.firstWhere((r) => x >= r.$1 && x < r.$2, orElse: () => bands.last);
      final lvl = _lv[b.$3] + math.sin(x * 2.3) * 5 * (b.$3 == 0 ? .3 : 1);
      pts.add(Offset(x / 24 * w, (76 - lvl * .9) / 84 * h));
    }
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final cx = (pts[i - 1].dx + pts[i].dx) / 2;
      line.cubicTo(cx, pts[i - 1].dy, cx, pts[i].dy, pts[i].dx, pts[i].dy);
    }
    final fill = Path.from(line)..lineTo(w, h)..lineTo(0, h)..close();
    c.drawPath(fill, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.pri.withOpacity(.16 * progress), AppColors.pri.withOpacity(0)]).createShader(Offset.zero & s));
    for (final m in line.computeMetrics()) {
      c.drawPath(m.extractPath(0, m.length * progress), Paint()..color = AppColors.pri..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round);
    }
    final nx = 14.33 / 24 * w;
    c.drawRect(Rect.fromLTRB(nx, -4, w, h + 4), Paint()..color = Colors.white.withOpacity(.72));
    for (var y = 0.0; y < h; y += 6) { c.drawLine(Offset(nx, y), Offset(nx, y + 3), Paint()..color = life.color..strokeWidth = 1.5); }
    final p = pts[14];
    c.drawCircle(p, 4.5, Paint()..color = Colors.white);
    c.drawCircle(p, 4.5, Paint()..color = life.color..style = PaintingStyle.stroke..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(_TracePainter o) => o.progress != progress || o.life != life;
}

class _DayRingBands {
  static List<(int, int, int)> of(Life l) => DayRing.bands[l]!;
}
