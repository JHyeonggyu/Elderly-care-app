import 'package:flutter/material.dart';
import '../../core/errors/app_error.dart';
import '../models/care_event.dart';
import '../models/life_state.dart';

/// 앱이 의존하는 유일한 데이터 창구.
/// 실제 서버가 생기면 이 인터페이스를 구현한 ApiCareService(REST/WebSocket/FCM)를 만들어
/// service_locator.dart 에서 교체하면 화면 코드는 수정할 필요가 없습니다.
abstract class CareService extends ChangeNotifier {
  // 메인 컴퓨터가 보내주는 결과
  Life get life;
  String get location;
  DateTime get since;
  bool get fall;
  bool get noResponse;
  int get countdown;
  String? get soundTag;
  List<CareEvent> get events;
  AppError? get error;

  // 앱 화면 설정
  bool get skeletonOnly;
  bool get listening;
  TimeOfDay get sleepAt;
  TimeOfDay get wakeAt;
  double get sensitivity;

  void toggleSkeleton();
  void toggleListening();
  void setSleepAt(TimeOfDay t);
  void setWakeAt(TimeOfDay t);
  void setSensitivity(double v);
  void toggleAway(bool on);
  void resolveFall();

  // 시연용 (실서버 구현에서는 빈 구현으로 두면 됨)
  void setLife(Life l, String loc);
  void triggerFall();
  void tvSound();
  void simulateDisconnect();
  void reconnect();
}
