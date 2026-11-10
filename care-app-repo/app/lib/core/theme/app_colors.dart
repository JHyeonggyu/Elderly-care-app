import 'package:flutter/material.dart';

/// v8 디자인 규칙: 남색·쿨 그레이·흰색 바탕, 색은 상태를 알릴 때만 사용
class AppColors {
  static const ink = Color(0xFF0B1F33); // 짙은 남색 (글자)
  static const pri = Color(0xFF123B6D); // 주 색상
  static const sub = Color(0xFF6B7A8B); // 보조 글자
  static const line = Color(0xFFDCE4EC);
  static const base = Color(0xFFEEF3F8); // 화면 바탕
  static const dark = Color(0xFF0B1218); // 실시간·낙상 화면
  static const teal = Color(0xFF14A36B); // 안전·활동 (이전 이름 유지)
  static const amber = Color(0xFFF2A33A); // 휴식·주의
  static const indigo = Color(0xFF5B8DEF); // 수면
  static const away = Color(0xFF8A9BB0); // 외출
  static const red = Color(0xFFE5484D); // 위험
  static const mist = base;
}
