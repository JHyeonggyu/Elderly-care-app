import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/errors/app_error.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../models/care_event.dart';
import '../models/life_state.dart';
import 'care_service.dart';

class MockCareService extends CareService {
  Life _life = Life.active;
  String _location = '거실';
  DateTime _since = DateTime.now();
  bool _fall = false, _noResponse = false, _skeletonOnly = false, _listening = false;
  int _countdown = 0;
  String? _soundTag;
  AppError? _error;
  Timer? _timer;
  TimeOfDay _sleepAt = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wakeAt = const TimeOfDay(hour: 6, minute: 30);
  double _sensitivity = 0.6;
  final List<CareEvent> _events = [
    const CareEvent('08:12', '기상 · 활동 시작', AppColors.teal),
    const CareEvent('09:40', '외출 · 귀가 완료', AppColors.away),
    const CareEvent('11:42', '소파에서 휴식', AppColors.amber),
  ];

  @override Life get life => _life;
  @override String get location => _location;
  @override DateTime get since => _since;
  @override bool get fall => _fall;
  @override bool get noResponse => _noResponse;
  @override int get countdown => _countdown;
  @override String? get soundTag => _soundTag;
  @override List<CareEvent> get events => List.unmodifiable(_events);
  @override AppError? get error => _error;
  @override bool get skeletonOnly => _skeletonOnly;
  @override bool get listening => _listening;
  @override TimeOfDay get sleepAt => _sleepAt;
  @override TimeOfDay get wakeAt => _wakeAt;
  @override double get sensitivity => _sensitivity;

  void _log(String text, Color c) => _events.insert(0, CareEvent(hm(DateTime.now()), text, c));

  @override void toggleSkeleton() { _skeletonOnly = !_skeletonOnly; notifyListeners(); }
  @override void toggleListening() { _listening = !_listening; notifyListeners(); }
  @override void setSleepAt(TimeOfDay t) { _sleepAt = t; notifyListeners(); }
  @override void setWakeAt(TimeOfDay t) { _wakeAt = t; notifyListeners(); }
  @override void setSensitivity(double v) { _sensitivity = v; notifyListeners(); }
  @override void toggleAway(bool on) => setLife(on ? Life.away : Life.active, on ? '현관' : '거실');

  @override
  void setLife(Life l, String loc) {
    _life = l; _location = loc; _since = DateTime.now();
    _log('${l.label} · $loc', l.color);
    notifyListeners();
  }

  @override
  void triggerFall() {
    if (_fall) return;
    _fall = true; _noResponse = false; _countdown = 15; _location = '거실';
    _log('낙상 감지 · 거실', AppColors.red);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _countdown--;
      if (_countdown <= 0) {
        _noResponse = true;
        t.cancel();
        _log('로봇 확인 응답 없음', AppColors.red);
      }
      notifyListeners();
    });
    notifyListeners();
  }

  @override
  void resolveFall() {
    _timer?.cancel();
    _fall = false; _noResponse = false;
    _log('보호자 확인 완료', AppColors.teal);
    notifyListeners();
  }

  @override
  void tvSound() {
    _soundTag = 'TV 소리 · 무시됨';
    notifyListeners();
    Timer(const Duration(seconds: 4), () { _soundTag = null; notifyListeners(); });
  }

  @override void simulateDisconnect() { _error = AppError.connectionLost; notifyListeners(); }
  @override void reconnect() { _error = null; notifyListeners(); }
}
