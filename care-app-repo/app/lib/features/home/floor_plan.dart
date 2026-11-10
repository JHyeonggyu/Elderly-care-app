import 'package:flutter/material.dart';
import '../../data/models/life_state.dart';

/// 어르신 댁 평면도. 어르신 위치는 부드럽게 이동하고 로봇은 거실을 돕니다.
class FloorPlan extends StatefulWidget {
  final Life life;
  const FloorPlan({super.key, required this.life});
  @override
  State<FloorPlan> createState() => _FloorPlanState();
}

class _FloorPlanState extends State<FloorPlan> with TickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
  late final AnimationController _draw = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();
  static const _pos = {Life.active: Offset(180, 62), Life.resting: Offset(138, 107), Life.sleeping: Offset(50, 50), Life.away: Offset(212, 150)};

  @override
  void dispose() { _loop.dispose(); _draw.dispose(); super.dispose(); }

  Offset _robot(double t) {
    const x0 = 130.0, y0 = 44.0, w = 106.0, h = 42.0;
    var d = t * 2 * (w + h);
    if (d < w) return Offset(x0 + d, y0);
    d -= w;
    if (d < h) return Offset(x0 + w, y0 + d);
    d -= h;
    if (d < w) return Offset(x0 + w - d, y0 + h);
    d -= w;
    return Offset(x0, y0 + h - d);
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 260 / 150,
        child: LayoutBuilder(builder: (_, cs) {
          final k = cs.maxWidth / 260;
          final p = _pos[widget.life]!;
          return AnimatedBuilder(
            animation: Listenable.merge([_loop, _draw]),
            builder: (_, __) {
              final r = _robot(_loop.value);
              final ring = (_loop.value * 14 / 2.2) % 1;
              return Stack(children: [
                CustomPaint(size: Size.infinite, painter: _PlanPainter(widget.life, _draw.value)),
                Positioned(left: (r.dx - 4) * k, top: (r.dy - 4) * k, child: Container(width: 8 * k, height: 8 * k, decoration: const BoxDecoration(color: Color(0xFF9AA0A6), shape: BoxShape.circle))),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutCubic,
                  left: (p.dx - 16) * k,
                  top: (p.dy - 16) * k,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: widget.life == Life.away ? 0 : 1,
                    child: SizedBox(
                      width: 32 * k, height: 32 * k,
                      child: Stack(alignment: Alignment.center, children: [
                        Opacity(opacity: 1 - ring, child: Container(width: (10 + 22 * ring) * k, height: (10 + 22 * ring) * k, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white)))),
                        Container(width: 12 * k, height: 12 * k, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      ]),
                    ),
                  ),
                ),
              ]);
            },
          );
        }),
      );
}

class _PlanPainter extends CustomPainter {
  final Life life;
  final double progress;
  _PlanPainter(this.life, this.progress);

  void _stroke(Canvas c, Path path, Paint paint) {
    for (final m in path.computeMetrics()) { c.drawPath(m.extractPath(0, m.length * progress), paint); }
  }

  void _label(Canvas c, String t, Offset o) {
    (TextPainter(text: TextSpan(text: t, style: const TextStyle(fontSize: 7, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: Color(0xFF8B9197))), textDirection: TextDirection.ltr)..layout()).paint(c, o);
  }

  @override
  void paint(Canvas c, Size s) {
    c.scale(s.width / 260);
    final hl = life == Life.sleeping ? const Rect.fromLTWH(10, 10, 90, 70) : (life == Life.away ? null : const Rect.fromLTWH(100, 10, 150, 130));
    if (hl != null) c.drawRect(hl, Paint()..color = Colors.white.withOpacity(.09));
    final wall = Paint()..color = const Color(0xFFE9EAEB)..style = PaintingStyle.stroke..strokeWidth = 1.2;
    final inner = Paint()..color = const Color(0xFF6F757A)..style = PaintingStyle.stroke..strokeWidth = 1;
    _stroke(c, Path()..addRect(const Rect.fromLTWH(10, 10, 240, 130)), wall);
    _stroke(c, Path()..moveTo(100, 10)..lineTo(100, 140)..moveTo(10, 80)..lineTo(100, 80), inner);
    c.drawLine(const Offset(200, 140), const Offset(224, 140), Paint()..color = const Color(0xFF111111)..strokeWidth = 3);
    final f = Paint()..color = const Color(0xFF6F757A)..style = PaintingStyle.stroke..strokeWidth = 1;
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(112, 96, 52, 22), const Radius.circular(3)), f);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(26, 34, 46, 32), const Radius.circular(3)), f);
    _label(c, 'BEDROOM', const Offset(16, 15));
    _label(c, 'BATH', const Offset(16, 85));
    _label(c, 'LIVING ROOM', const Offset(108, 15));
    _label(c, 'ENTRY', const Offset(204, 126));
  }

  @override
  bool shouldRepaint(_PlanPainter o) => o.life != life || o.progress != progress;
}
