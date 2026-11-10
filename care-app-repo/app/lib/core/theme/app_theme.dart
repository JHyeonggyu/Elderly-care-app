import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.pri, surface: AppColors.base),
        scaffoldBackgroundColor: AppColors.base,
        dividerColor: AppColors.line,
        textTheme: ThemeData.light().textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      );

  /// 카드 공통 장식: 아주 옅은 그림자
  static BoxDecoration card([double r = 26]) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withOpacity(.05), blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: AppColors.ink.withOpacity(.10), blurRadius: 28, offset: const Offset(0, 12), spreadRadius: -14),
        ],
      );
}
