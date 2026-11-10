import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/section_title.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  static const _days = [('월', 2), ('화', 3), ('수', 4), ('목', 5), ('금', 6), ('토', 7), ('일', 8)];
  static const _week = [52.0, 64.0, 48.0, 68.0, 0.0, 0.0, 0.0];
  // (시각, 제목, 태그, 주의 여부)
  static const _ledger = [
    ('11:42', '소파에서 휴식', null, false),
    ('09:40', '귀가', null, false),
    ('08:12', '기상', null, false),
    ('03:10', '새벽 화장실', '확인했어요', true),
    ('어제 20:12', '낙상 의심 · 괜찮음', '오탐 방지', false),
  ];

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 40), children: [
        const Text('기록', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.8)),
        const Text('11월', style: TextStyle(fontSize: 12.5, color: AppColors.sub)),
        const SizedBox(height: 14),
        Row(children: [
          for (var i = 0; i < _days.length; i++)
            Expanded(
              child: Column(children: [
                Text(_days[i].$1, style: const TextStyle(fontSize: 11, color: AppColors.sub)),
                const SizedBox(height: 4),
                Container(
                  width: 34, height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: i == 3 ? AppColors.ink : Colors.transparent, shape: BoxShape.circle),
                  child: Text('${_days[i].$2}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: i == 3 ? Colors.white : (i > 3 ? const Color(0xFFB3B7BB) : AppColors.ink))),
                ),
                const SizedBox(height: 4),
                if (i <= 3) Container(width: 4, height: 4, decoration: BoxDecoration(color: i == 3 ? AppColors.red : const Color(0xFFC5C9CF), shape: BoxShape.circle)),
              ]),
            ),
        ]),
        Container(
          margin: const EdgeInsets.only(top: 16),
          decoration: const BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: AppColors.line))),
          child: IntrinsicHeight(child: Row(children: [_m('수면', '7h 20m', false), _m('외출', '2h', true), _m('낙상', '0건', true)])),
        ),
        const SectionTitle('이번 주'),
        const SizedBox(height: 8),
        SizedBox(
          height: 88,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (var i = 0; i < _week.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: _week[i]),
                      duration: Duration(milliseconds: 600 + i * 70),
                      curve: Curves.easeOutBack,
                      builder: (_, v, __) => Container(height: v < 0 ? 0 : v, decoration: BoxDecoration(color: i == 3 ? AppColors.ink : const Color(0xFFC5C9CF), borderRadius: const BorderRadius.vertical(top: Radius.circular(2)))),
                    ),
                    const SizedBox(height: 5),
                    Text(_days[i].$1, style: const TextStyle(fontSize: 10, color: AppColors.sub)),
                  ]),
                ),
              ),
          ]),
        ),
        const SectionTitle('오늘'),
        const SizedBox(height: 6),
        Stack(children: [
          Positioned(left: 4, top: 8, bottom: 8, child: Container(width: 1, color: AppColors.ink.withOpacity(.25))),
          Column(children: [for (final e in _ledger) _event(e.$1, e.$2, e.$3, e.$4)]),
        ]),
      ]);

  Widget _m(String l, String v, bool left) => Expanded(
        child: Container(
          padding: EdgeInsets.fromLTRB(left ? 12 : 0, 10, 0, 10),
          decoration: left ? const BoxDecoration(border: Border(left: BorderSide(color: AppColors.line))) : null,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l, style: const TextStyle(fontSize: 11, color: AppColors.sub)),
            const SizedBox(height: 2),
            Text(v, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
        ),
      );

  Widget _event(String t, String title, String? tag, bool warn) {
    final c = warn ? const Color(0xFFA8730F) : AppColors.teal;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 22,
        child: Padding(
          padding: const EdgeInsets.only(top: 13),
          child: Container(width: 9, height: 9, decoration: BoxDecoration(color: warn ? AppColors.amber : AppColors.base, shape: BoxShape.circle, border: Border.all(color: warn ? AppColors.amber : AppColors.ink, width: 2))),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 13),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t, style: const TextStyle(fontSize: 12, color: AppColors.sub)),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            if (tag != null)
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(border: Border.all(color: c), borderRadius: BorderRadius.circular(4)),
                child: Text(tag, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c)),
              ),
          ]),
        ),
      ),
    ]);
  }
}
