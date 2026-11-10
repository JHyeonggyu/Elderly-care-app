import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/service_locator.dart';
import '../../shared/widgets/pulse.dart';

class FallScreen extends StatelessWidget {
  final VoidCallback onWatch;
  const FallScreen({super.key, required this.onWatch});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: careService,
        builder: (_, __) {
          final s = careService;
          final no = s.noResponse;
          return Material(
            color: AppColors.dark,
            child: Stack(children: [
              // 붉은 빛이 숨 쉬듯 번짐
              IgnorePointer(
                child: Align(
                  alignment: const Alignment(0, -.45),
                  child: Pulse(
                    min: .55,
                    duration: const Duration(seconds: 2),
                    child: Container(width: 420, height: 420, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.red.withOpacity(.55), AppColors.red.withOpacity(0)], stops: const [0, .62]))),
                  ),
                ),
              ),
              SafeArea(
                child: Column(children: [
                  const Spacer(flex: 2),
                  SizedBox(
                    width: 176, height: 176,
                    child: Stack(alignment: Alignment.center, children: [
                      const _Ripple(),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1, end: no ? 0 : s.countdown / 15),
                        duration: const Duration(milliseconds: 900),
                        builder: (_, v, __) => SizedBox(width: 172, height: 172, child: CircularProgressIndicator(value: v, strokeWidth: 5, color: AppColors.red, backgroundColor: Colors.white12)),
                      ),
                      no ? const Icon(Icons.call_missed, color: Colors.white, size: 54) : Text('${s.countdown}', style: const TextStyle(color: Colors.white, fontSize: 66, fontWeight: FontWeight.w700, letterSpacing: -3)),
                    ]),
                  ),
                  const SizedBox(height: 26),
                  const Text('낙상 감지', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700, letterSpacing: -.6)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.place_outlined, size: 15, color: Color(0xFFC9D5E2)),
                      const SizedBox(width: 6),
                      Text(no ? '응답 없음' : '거실 · 확인 중', style: const TextStyle(color: Color(0xFFC9D5E2), fontSize: 13)),
                    ]),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                    child: Column(children: [
                      Container(width: 38, height: 4, margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: const Color(0xFFD3DBE4), borderRadius: BorderRadius.circular(2))),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.red, minimumSize: const Size.fromHeight(56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                        // TODO: url_launcher 패키지로 실제 119 전화 연결
                        onPressed: () => showDialog(context: context, builder: (_) => const AlertDialog(title: Text('119 연결 (데모)'), content: Text('실제 앱에서는 119 전화 화면으로 연결됩니다.'))),
                        icon: const Icon(Icons.call),
                        label: const Text('119', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 9),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.base, foregroundColor: AppColors.ink, minimumSize: const Size.fromHeight(56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                        onPressed: onWatch,
                        icon: const Icon(Icons.videocam_outlined),
                        label: const Text('영상', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      ),
                      TextButton(onPressed: s.resolveFall, child: const Text('괜찮아요', style: TextStyle(color: AppColors.sub, fontSize: 14, fontWeight: FontWeight.w600))),
                    ]),
                  ),
                ]),
              ),
            ]),
          );
        },
      );
}

/// 퍼져 나가는 붉은 파동
class _Ripple extends StatefulWidget {
  const _Ripple();
  @override
  State<_Ripple> createState() => _RippleState();
}

class _RippleState extends State<_Ripple> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Stack(alignment: Alignment.center, children: [
          for (final d in [0.0, .33, .66])
            Builder(builder: (_) {
              final t = (_c.value + d) % 1;
              return Opacity(opacity: .9 * (1 - t), child: Transform.scale(scale: .8 + 1.1 * t, child: Container(width: 176, height: 176, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.red, width: 1.5)))));
            }),
        ]),
      );
}
