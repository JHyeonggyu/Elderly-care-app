import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// YOLO11 pose 결과 오버레이를 흉내 내는 그림 (실제 연동 시 keypoint 좌표로 교체)
class ScenePainter extends CustomPainter {
  final bool fall, lying, away;
  ScenePainter({required this.fall, required this.lying, required this.away});

  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    c.drawRect(Offset.zero & s, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1D2A36), Color(0xFF121B24)]).createShader(Offset.zero & s));
    c.drawRect(Rect.fromLTWH(0, h * .73, w, h * .27), Paint()..color = const Color(0xFF16212B));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .06, h * .53, w * .36, h * .2), const Radius.circular(10)), Paint()..color = const Color(0xFF223140));
    if (away) {
      (TextPainter(text: const TextSpan(text: '사람이 보이지 않아요', style: TextStyle(color: Colors.white54, fontSize: 14)), textDirection: TextDirection.ltr)..layout()).paint(c, Offset(w * .3, h * .45));
      return;
    }
    final down = fall || lying;
    final col = fall ? AppColors.red : Colors.white;
    final y = h * .78;
    final head = down ? Offset(w * .4, y) : Offset(w * .63, h * .28);
    final neck = down ? Offset(w * .46, y) : Offset(w * .63, h * .37);
    final hip = down ? Offset(w * .62, y + h * .01) : Offset(w * .63, h * .52);
    final hands = down ? [Offset(w * .52, y - h * .05), Offset(w * .54, y + h * .05)] : [Offset(w * .56, h * .46), Offset(w * .7, h * .46)];
    final feet = down ? [Offset(w * .78, y - h * .02), Offset(w * .78, y + h * .04)] : [Offset(w * .59, h * .72), Offset(w * .67, h * .72)];
    final p = Paint()..color = col..strokeWidth = 3..strokeCap = StrokeCap.round;
    for (final o in [hip, ...hands]) { c.drawLine(neck, o, p); }
    c.drawLine(neck, head, p);
    for (final f in feet) { c.drawLine(hip, f, p); }
    final pts = [head, neck, hip, ...hands, ...feet];
    for (final o in pts) { c.drawCircle(o, 5, Paint()..color = col); }
    // 사람 주위 모서리 괄호
    double x0 = pts.first.dx, x1 = x0, y0 = pts.first.dy, y1 = y0;
    for (final o in pts) {
      if (o.dx < x0) x0 = o.dx;
      if (o.dx > x1) x1 = o.dx;
      if (o.dy < y0) y0 = o.dy;
      if (o.dy > y1) y1 = o.dy;
    }
    final b = Rect.fromLTRB(x0 - 18, y0 - 20, x1 + 18, y1 + 16);
    final bp = Paint()..color = fall ? AppColors.red : AppColors.teal..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    for (final (o, dx, dy) in [(b.topLeft, 14.0, 14.0), (b.topRight, -14.0, 14.0), (b.bottomLeft, 14.0, -14.0), (b.bottomRight, -14.0, -14.0)]) {
      c.drawLine(o, o + Offset(dx, 0), bp);
      c.drawLine(o, o + Offset(0, dy), bp);
    }
  }

  @override
  bool shouldRepaint(ScenePainter o) => true;
}
