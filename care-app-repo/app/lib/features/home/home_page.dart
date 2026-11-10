import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/life_state.dart';
import '../../data/services/care_service.dart';
import '../../data/services/service_locator.dart';
import 'activity_trace.dart';
import 'day_ring.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: careService,
        builder: (_, __) {
          final s = careService;
          final l = s.life;
          return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
            _header(context, s),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: AppTheme.card().copyWith(
                gradient: RadialGradient(center: const Alignment(0, -.1), radius: .75, colors: [Color.alphaBlend(l.color.withOpacity(.16), Colors.white), Colors.white], stops: const [0, .66]),
              ),
              child: Center(child: DayRing(life: l, location: s.location)),
            ),
            const SizedBox(height: 10),
            Row(children: [
              _tile(Icons.bedtime_outlined, const Color(0xFF3A63D8), const Color(0xFFE8EEFB), '7.3', '시간'),
              const SizedBox(width: 9),
              _tile(Icons.show_chart, AppColors.teal, const Color(0xFFE2F5EC), '68', '%'),
              const SizedBox(width: 9),
              _tile(Icons.bolt, const Color(0xFFC98B1F), const Color(0xFFFDF1DE), '82', '%'),
            ]),
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
              decoration: AppTheme.card(22),
              child: Column(children: [
                ActivityTrace(life: l),
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('0', style: TextStyle(fontSize: 10, color: AppColors.sub)), Text('6', style: TextStyle(fontSize: 10, color: AppColors.sub)),
                    Text('12', style: TextStyle(fontSize: 10, color: AppColors.sub)), Text('18', style: TextStyle(fontSize: 10, color: AppColors.sub)), Text('24', style: TextStyle(fontSize: 10, color: AppColors.sub)),
                  ]),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _action(context, Icons.call_outlined, '전화', false),
                _action(context, Icons.mic_none, '말하기', false),
                _action(context, Icons.call, '119', true),
              ]),
            ),
          ]);
        },
      );

  Widget _header(BuildContext context, CareService s) => Row(children: [
        Stack(children: [
          Container(
            width: 42, height: 42, alignment: Alignment.center,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFD8E3F1), Color(0xFFB7C9E0)])),
            child: const Text('김', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.pri)),
          ),
          Positioned(right: 0, bottom: 0, child: AnimatedContainer(duration: const Duration(milliseconds: 500), width: 12, height: 12, decoration: BoxDecoration(color: s.life.color, shape: BoxShape.circle, border: Border.all(color: AppColors.base, width: 2.5)))),
        ]),
        const SizedBox(width: 11),
        const Text('김순자 님', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -.3)),
        const Spacer(),
        _circle(Icons.science_outlined, () => _demo(context, s)),
        const SizedBox(width: 8),
        _circle(Icons.notifications_none, () {}),
      ]);

  Widget _circle(IconData i, VoidCallback f) => InkWell(
        customBorder: const CircleBorder(),
        onTap: f,
        child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(i, size: 20)),
      );

  Widget _tile(IconData i, Color fg, Color bg, String v, String unit) => Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 11),
          decoration: AppTheme.card(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 30, height: 30, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Icon(i, size: 16, color: fg)),
            const SizedBox(height: 9),
            Text.rich(TextSpan(children: [
              TextSpan(text: v, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -.6)),
              TextSpan(text: unit, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.sub)),
            ])),
          ]),
        ),
      );

  Widget _action(BuildContext c, IconData i, String t, bool red) => InkWell(
        customBorder: const CircleBorder(),
        onTap: () => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text('$t (데모)'))),
        child: Column(children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(color: red ? AppColors.red : Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.ink.withOpacity(.14), blurRadius: 18, offset: const Offset(0, 8), spreadRadius: -10)]),
            child: Icon(i, size: 22, color: red ? Colors.white : AppColors.pri),
          ),
          const SizedBox(height: 5),
          Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.sub)),
        ]),
      );

  void _demo(BuildContext context, CareService s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          _chip(context, '활동', () => s.setLife(Life.active, '거실')),
          _chip(context, '휴식', () => s.setLife(Life.resting, '거실')),
          _chip(context, '수면', () => s.setLife(Life.sleeping, '침실')),
          _chip(context, '외출', () => s.setLife(Life.away, '현관')),
          _chip(context, '연결 끊김', s.simulateDisconnect),
          _chip(context, '낙상', s.triggerFall, red: true),
        ]),
      ),
    );
  }

  Widget _chip(BuildContext c, String t, VoidCallback f, {bool red = false}) => ActionChip(
        label: Text(t, style: TextStyle(fontWeight: FontWeight.w600, color: red ? AppColors.red : AppColors.ink)),
        backgroundColor: AppColors.base,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        onPressed: () { Navigator.pop(c); f(); },
      );
}
