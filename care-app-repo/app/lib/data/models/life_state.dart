import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 메인 컴퓨터가 판정해서 보내주는 생활 상태
enum Life { active, sleeping, away, resting }

extension LifeX on Life {
  String get label => switch (this) { Life.active => '활동 중', Life.sleeping => '수면 중', Life.away => '외출 중', Life.resting => '휴식 중' };
  Color get color => switch (this) { Life.active => AppColors.teal, Life.sleeping => AppColors.indigo, Life.away => AppColors.away, Life.resting => AppColors.amber };
  IconData get icon => switch (this) { Life.active => Icons.directions_walk, Life.sleeping => Icons.bedtime_outlined, Life.away => Icons.door_front_door_outlined, Life.resting => Icons.weekend_outlined };
}
