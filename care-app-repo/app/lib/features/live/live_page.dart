import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/life_state.dart';
import '../../data/services/service_locator.dart';
import '../../shared/widgets/pulse.dart';
import 'scene_painter.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: careService,
        builder: (_, __) {
          final s = careService;
          return ListView(padding: EdgeInsets.zero, children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
              child: AspectRatio(
                aspectRatio: 1 / 1.05,
                // TODO: 서버 연결 시 WebRTC/HLS 영상 위젯으로 교체하고 스켈레톤을 위에 겹치기
                child: Stack(children: [
                  Positioned.fill(child: CustomPaint(painter: ScenePainter(fall: s.fall, lying: s.life == Life.sleeping, away: s.life == Life.away))),
                  Positioned(left: 14, top: 14, child: _glass(Row(mainAxisSize: MainAxisSize.min, children: [
                    const Pulse(child: Icon(Icons.circle, color: AppColors.red, size: 7)),
                    const SizedBox(width: 6),
                    Text(s.location, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ]))),
                  Positioned(right: 14, top: 14, child: _glass(const Icon(Icons.lock_outline, size: 15, color: Colors.white))),
                  Positioned(
                    bottom: 16, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(color: s.fall ? AppColors.red : AppColors.teal, borderRadius: BorderRadius.circular(20)),
                        child: Text(s.fall ? '위험' : '정상', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              child: Column(children: [
                const _Scrubber(),
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _ctl(Icons.volume_up_outlined, '듣기', s.listening, 62, s.toggleListening),
                  _ctl(Icons.mic_none, '말하기', true, 70, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('누르고 있는 동안 로봇 스피커로 전달됩니다 (데모)')))),
                  _ctl(Icons.camera_alt_outlined, '저장', false, 62, () {}),
                ]),
                const SizedBox(height: 20),
                const _Wave(),
              ]),
            ),
          ]);
        },
      );

  Widget _glass(Widget child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: Colors.black.withOpacity(.5), borderRadius: BorderRadius.circular(20)),
        child: child,
      );

  Widget _ctl(IconData i, String t, bool on, double size, VoidCallback f) => GestureDetector(
        onTap: f,
        child: Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size, height: size,
            decoration: BoxDecoration(color: on ? Colors.white : const Color(0xFF17232F), shape: BoxShape.circle),
            child: Icon(i, size: 24, color: on ? AppColors.ink : Colors.white),
          ),
          const SizedBox(height: 7),
          Text(t, style: const TextStyle(fontSize: 11.5, color: Color(0xFF8EA0B3))),
        ]),
      );
}

/// 최근 10분 타임라인 (붉은 선 = 이벤트)
class _Scrubber extends StatelessWidget {
  const _Scrubber();
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 26,
        child: LayoutBuilder(builder: (_, cs) {
          final w = cs.maxWidth;
          Widget tick(double f, {bool ev = false}) => Positioned(left: w * f, top: ev ? 4 : 7, child: Container(width: 4, height: ev ? 18 : 12, decoration: BoxDecoration(color: ev ? AppColors.red : const Color(0xFF4A5B6C), borderRadius: BorderRadius.circular(2))));
          return Stack(children: [
            Positioned(left: 0, right: 0, top: 11, child: Container(height: 4, decoration: BoxDecoration(color: const Color(0xFF25323F), borderRadius: BorderRadius.circular(2)))),
            tick(.12), tick(.38, ev: true), tick(.63),
            Positioned(right: 0, top: 6, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white.withOpacity(.18), spreadRadius: 4)]))),
          ]);
        }),
      );
}

class _Wave extends StatefulWidget {
  const _Wave();
  @override
  State<_Wave> createState() => _WaveState();
}

class _WaveState extends State<_Wave> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 22,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => Row(children: [
            for (var i = 0; i < 40; i++)
              Expanded(child: Center(child: Container(margin: const EdgeInsets.symmetric(horizontal: 1.2), height: 3 + math.sin(i * 1.9 + _c.value * 2 * math.pi).abs() * 16, decoration: BoxDecoration(color: const Color(0xFF3A4B5C), borderRadius: BorderRadius.circular(2))))),
          ]),
        ),
      );
}
