// app/theme/app_typography.dart
// Retro Y2K Typography system combining VT323 (CRT/Arcade), Share Tech Mono (HUD/Data), and Comic Neue (Story).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  /// Dev Retro Arcade & Dijital Skor Başlığı
  static TextStyle display({Color color = AppColors.neutral50}) {
    return GoogleFonts.vt323(
      fontSize: 38,
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: 1.0,
    );
  }

  /// Retro Windows Başlık 1 (Pencere Başlıkları ve Bölüm İsimleri)
  static TextStyle h1({Color color = AppColors.neutral50}) {
    return GoogleFonts.shareTechMono(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 0.5,
    );
  }

  /// Retro Windows Başlık 2
  static TextStyle h2({Color color = AppColors.neutral50}) {
    return GoogleFonts.shareTechMono(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 0.3,
    );
  }

  /// Retro Windows Başlık 3
  static TextStyle h3({Color color = AppColors.neutral50}) {
    return GoogleFonts.shareTechMono(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  /// Retro Monospace Gövde Metni
  static TextStyle body({Color color = AppColors.neutral50}) {
    return GoogleFonts.spaceMono(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.45,
    );
  }

  /// Nostaljik Çizgi Roman Hikaye ve Diyalog Metni
  static TextStyle story({Color color = AppColors.neutral50}) {
    return GoogleFonts.comicNeue(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.4,
    );
  }

  /// Küçük Monospace Açıklama / Alt Metin
  static TextStyle bodySmall({Color color = AppColors.neutral300}) {
    return GoogleFonts.spaceMono(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  /// Piksel / 8-Bit Mini Etiket
  static TextStyle label({Color color = AppColors.neutral50}) {
    return GoogleFonts.shareTechMono(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 0.5,
    );
  }

  /// Dijital Sayaç & Skor Rakamları
  static TextStyle monoNumber({Color color = AppColors.neutral50}) {
    return GoogleFonts.vt323(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: 1.2,
    );
  }

  // Standart Getter Erişimi
  static TextStyle get h1Style => h1();
  static TextStyle get h2Style => h2();
  static TextStyle get h3Style => h3();
  static TextStyle get bodyLarge => body();
  static TextStyle get bodyMedium => body();
  static TextStyle get bodySmallStyle => bodySmall();
  static TextStyle get monoMedium => monoNumber();
  static TextStyle get statLarge => display();
}
