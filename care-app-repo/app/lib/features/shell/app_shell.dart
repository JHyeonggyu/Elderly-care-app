import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/service_locator.dart';
import '../../shared/widgets/error_banner.dart';
import '../alert/fall_screen.dart';
import '../home/home_page.dart';
import '../live/live_page.dart';
import '../settings/settings_page.dart';
import '../timeline/timeline_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  static const _pages = [HomePage(), LivePage(), TimelinePage(), SettingsPage()];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: careService,
        builder: (_, __) {
          final bg = _index == 1 ? AppColors.dark : AppColors.base;
          return Stack(children: [
            Scaffold(
              backgroundColor: bg,
              body: Column(children: [
                if (careService.error != null) ErrorBanner(error: careService.error!, onRetry: careService.reconnect),
                Expanded(child: SafeArea(top: careService.error == null, bottom: false, child: _pages[_index])),
              ]),
              bottomNavigationBar: ColoredBox(
                color: bg,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 6, 0, 10),
                    child: Center(heightFactor: 1, child: _Pill(index: _index, onTap: (v) => setState(() => _index = v))),
                  ),
                ),
              ),
            ),
            if (careService.fall) FallScreen(onWatch: () => setState(() => _index = 1)),
          ]);
        },
      );
}

/// 아이콘만 보이고, 선택된 탭만 글자가 펼쳐지는 알약형 탭바
class _Pill extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _Pill({required this.index, required this.onTap});
  static const _items = [(Icons.home_outlined, '홈'), (Icons.videocam_outlined, '실시간'), (Icons.bar_chart_rounded, '기록'), (Icons.tune, '설정')];

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: AppColors.ink.withOpacity(.22), blurRadius: 26, offset: const Offset(0, 10), spreadRadius: -8)]),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < _items.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                height: 44,
                padding: EdgeInsets.symmetric(horizontal: i == index ? 16 : 12),
                decoration: BoxDecoration(color: i == index ? AppColors.ink : Colors.transparent, borderRadius: BorderRadius.circular(24)),
                child: Row(children: [
                  Icon(_items[i].$1, size: 21, color: i == index ? Colors.white : const Color(0xFF7A8898)),
                  if (i == index) ...[const SizedBox(width: 6), Text(_items[i].$2, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))],
                ]),
              ),
            ),
        ]),
      );
}
