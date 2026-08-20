// app/theme/app_theme.dart
// Neo-Brutalism + 16-Bit / 26-Bit Arcade Theme Data for MaterialApp.

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.neoPitchBlack,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonLime,
        secondary: AppColors.neonCyan,
        surface: AppColors.neoCardBg,
        error: AppColors.comicRed,
        onPrimary: Colors.black,
        onSurface: AppColors.neutral50,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.neoCardBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h2(color: Colors.white),
        iconTheme: const IconThemeData(color: AppColors.neonLime),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.neoCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Colors.black, width: 2.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonLime,
          foregroundColor: Colors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Colors.black, width: 2),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: AppTypography.label(color: Colors.black),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.neoPitchBlack,
        selectedItemColor: AppColors.neonLime,
        unselectedItemColor: AppColors.neutral300,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
