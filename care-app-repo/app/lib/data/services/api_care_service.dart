import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/errors/app_error.dart';
import '../models/care_event.dart';
import '../models/life_state.dart';
import 'care_service.dart';
import 'mock_care_service.dart';

/// 실서버 연결용 CareService.
/// - 기본은 데모 모드(demoMode=true)로, 서버 없이도 앱이 바로 동작 (MockCareService 위임).
/// - 설정에서 서버 주소를 입력하고 적용하면 demoMode=false 가 되어 실서버 폴링으로 전환.
/// - GET  /api/state 를 2초마다 폴링, 명령은 각 POST/PATCH 엔드포인트로 전송.
class ApiCareService extends CareService {
  String _baseUrl;
  bool _demoMode;
  final MockCareService _mock = MockCareService();

  ApiCareService({String baseUrl = ''})
      : _baseUrl = baseUrl,
        _demoMode = baseUrl.trim().isEmpty {
    _mock.addListener(notifyListeners);
    if (!_demoMode) {
      _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
      _poll();
    }
  }

  Timer? _timer;
  final HttpClient _http = HttpClient();

  // ---- 서버 상태 (demoMode=false 일 때만 사용) ----
  Life _life = Life.active;
  String _location = '거실';
  DateTime _since = DateTime.now();
  bool _fall = false, _noResponse = false, _skeletonOnly = false, _listening = false;
  int _countdown = 0;
  String? _soundTag;
  AppError? _error;
  List<CareEvent> _events = const [];
  TimeOfDay _sleepAt = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wakeAt = const TimeOfDay(hour: 6, minute: 30);
  double _sensitivity = 0.6;

  bool get demoMode => _demoMode;

  @override Life get life => _demoMode ? _mock.life : _life;
  @override String get location => _demoMode ? _mock.location : _location;
  @override DateTime get since => _demoMode ? _mock.since : _since;
  @override bool get fall => _demoMode ? _mock.fall : _fall;
  @override bool get noResponse => _demoMode ? _mock.noResponse : _noResponse;
  @override int get countdown => _demoMode ? _mock.countdown : _countdown;
  @override String? get soundTag => _demoMode ? _mock.soundTag : _soundTag;
  @override List<CareEvent> get events => _demoMode ? _mock.events : List.unmodifiable(_events);
  @override AppError? get error => _demoMode ? _mock.error : _error;
  @override bool get skeletonOnly => _demoMode ? _mock.skeletonOnly : _skeletonOnly;
  @override bool get listening => _demoMode ? _mock.listening : _listening;
  @override TimeOfDay get sleepAt => _demoMode ? _mock.sleepAt : _sleepAt;
  @override TimeOfDay get wakeAt => _demoMode ? _mock.wakeAt : _wakeAt;
  @override double get sensitivity => _demoMode ? _mock.sensitivity : _sensitivity;

  /// 서버 주소 설정. 비어있으면 데모 모드, 채워져 있으면 실서버 모드로 전환.
  void setBaseUrl(String url) {
    final trimmed = url.trim().replaceAll(RegExp(r'/+$'), '');
    _baseUrl = trimmed;
    if (trimmed.isEmpty) {
      _demoMode = true;
      _timer?.cancel();
      _timer = null;
    } else {
      _demoMode = false;
      _error = null;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
      _poll();
    }
    notifyListeners();
  }

  String get baseUrl => _baseUrl;

  TimeOfDay _parseTod(String s) {
    final p = s.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  Future<void> _poll() async {
    if (_demoMode) return;
    try {
      final req = await _http.getUrl(Uri.parse('$_baseUrl/api/state')).timeout(const Duration(seconds: 4));
      final res = await req.close().timeout(const Duration(seconds: 4));
      final body = await res.transform(utf8.decoder).join();
      final j = jsonDecode(body) as Map<String, dynamic>;
      _life = Life.values.byName((j['life'] as String?) ?? 'active');
      _location = (j['location'] as String?) ?? '';
      _since = DateTime.tryParse((j['since'] as String?) ?? '') ?? DateTime.now();
      _fall = j['fall'] == true;
      _noResponse = j['noResponse'] == true;
      _countdown = (j['countdown'] as num?)?.toInt() ?? 0;
      _soundTag = j['soundTag'] as String?;
      _skeletonOnly = j['skeletonOnly'] == true;
      _listening = j['listening'] == true;
      _sleepAt = _parseTod((j['sleepAt'] as String?) ?? '22:30');
      _wakeAt = _parseTod((j['wakeAt'] as String?) ?? '06:30');
      _sensitivity = (j['sensitivity'] as num?)?.toDouble() ?? 0.6;
      final ev = (j['events'] as List?) ?? const [];
      _events = ev
          .map((e) => CareEvent(
                (e['time'] as String?) ?? '',
                (e['text'] as String?) ?? '',
                Color((e['color'] as num?)?.toInt() ?? 0xFF008080),
              ))
          .toList();
      final err = j['error'] as Map<String, dynamic>?;
      _error = err == null ? null : AppError(err['code'] ?? 'ERROR', err['message'] ?? '오류가 발생했어요');
      notifyListeners();
    } catch (_) {
      if (_error == null) {
        _error = AppError.connectionLost;
        notifyListeners();
      }
    }
  }

  Future<void> _post(String path, [Map<String, dynamic>? body, String method = 'POST']) async {
    if (_demoMode) return;
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final req = method == 'PATCH' ? await _http.patchUrl(uri) : await _http.postUrl(uri);
      req.headers.contentType = ContentType.json;
      if (body != null) req.write(jsonEncode(body));
      final res = await req.close().timeout(const Duration(seconds: 5));
      await res.drain();
      _poll();
    } catch (_) {
      _error = AppError.connectionLost;
      notifyListeners();
    }
  }

  @override void toggleSkeleton() => _demoMode ? _mock.toggleSkeleton() : _post('/api/settings', {'skeletonOnly': !_skeletonOnly}, 'PATCH');
  @override void toggleListening() => _demoMode ? _mock.toggleListening() : _post('/api/settings', {'listening': !_listening}, 'PATCH');
  @override void setSleepAt(TimeOfDay t) => _demoMode ? _mock.setSleepAt(t) : _post('/api/settings', {'sleepAt': '${t.hour}:${t.minute.toString().padLeft(2, '0')}'}, 'PATCH');
  @override void setWakeAt(TimeOfDay t) => _demoMode ? _mock.setWakeAt(t) : _post('/api/settings', {'wakeAt': '${t.hour}:${t.minute.toString().padLeft(2, '0')}'}, 'PATCH');
  @override void setSensitivity(double v) => _demoMode ? _mock.setSensitivity(v) : _post('/api/settings', {'sensitivity': v}, 'PATCH');
  @override void toggleAway(bool on) => _demoMode ? _mock.toggleAway(on) : _post('/api/away', {'on': on});
  @override void resolveFall() => _demoMode ? _mock.resolveFall() : _post('/api/fall/resolve');
  @override void setLife(Life l, String loc) => _demoMode ? _mock.setLife(l, loc) : _post('/api/device/state', {'life': l.name, 'location': loc});
  @override void triggerFall() => _demoMode ? _mock.triggerFall() : _post('/api/fall/trigger');
  @override void tvSound() => _demoMode ? _mock.tvSound() : _post('/api/tv-sound');
  @override void simulateDisconnect() => _demoMode ? _mock.simulateDisconnect() : _post('/api/disconnect');
  @override void reconnect() {
    if (_demoMode) { _mock.reconnect(); return; }
    _error = null;
    notifyListeners();
    _post('/api/reconnect');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _http.close();
    _mock.removeListener(notifyListeners);
    _mock.dispose();
    super.dispose();
  }
}
