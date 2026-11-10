import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/life_state.dart';
import '../../data/services/api_care_service.dart';
import '../../data/services/service_locator.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: careService,
        builder: (_, __) {
          final s = careService;
          Future<void> pick(bool sleep) async {
            final t = await showTimePicker(context: context, initialTime: sleep ? s.sleepAt : s.wakeAt);
            if (t != null) { sleep ? s.setSleepAt(t) : s.setWakeAt(t); }
          }

          Widget row(String t, Widget trailing, {VoidCallback? onTap}) => InkWell(
                onTap: onTap,
                child: Container(
                  height: 60,
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
                  child: Row(children: [Text(t, style: const TextStyle(fontSize: 15.5)), const Spacer(), trailing]),
                ),
              );

          return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
            const Text('설정', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.6)),
            const SizedBox(height: 14),
            if (s is ApiCareService) _ServerUrlCard(service: s),
            row('취침 시간', Text(s.sleepAt.format(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), onTap: () => pick(true)),
            row('기상 시간', Text(s.wakeAt.format(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), onTap: () => pick(false)),
            row('외출 모드', Switch(value: s.life == Life.away, onChanged: s.toggleAway, activeColor: AppColors.pri)),
            row('보호자 연락처', const Text('010-1234-5678', style: TextStyle(fontSize: 15, color: AppColors.sub))),
            const SizedBox(height: 22),
            const Text('알림 민감도', style: TextStyle(fontSize: 15.5)),
            Slider(value: s.sensitivity, onChanged: s.setSensitivity, activeColor: AppColors.pri),
          ]);
        },
      );
}

/// 서버 주소 입력. 비우면 데모 모드, 채우면 서버 모드로 전환됩니다.
class _ServerUrlCard extends StatefulWidget {
  final ApiCareService service;
  const _ServerUrlCard({required this.service});
  @override
  State<_ServerUrlCard> createState() => _ServerUrlCardState();
}

class _ServerUrlCardState extends State<_ServerUrlCard> {
  late final TextEditingController _c = TextEditingController(text: widget.service.baseUrl);

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final demo = s.demoMode;
    final lost = s.error != null;
    final (label, color) = demo ? ('데모', AppColors.away) : (lost ? ('연결 안 됨', AppColors.red) : ('연결됨', AppColors.teal));
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.card(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('서버', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _c,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: 'http://서버IP:8000',
            isDense: true,
            filled: true,
            fillColor: AppColors.base,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onSubmitted: s.setBaseUrl,
        ),
        const SizedBox(height: 10),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.ink, minimumSize: const Size.fromHeight(46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          onPressed: () {
            s.setBaseUrl(_c.text);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_c.text.trim().isEmpty ? '데모 모드로 바꿨어요' : '서버에 연결합니다')));
          },
          child: const Text('적용', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}
