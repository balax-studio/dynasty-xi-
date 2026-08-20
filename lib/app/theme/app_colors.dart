// app/theme/app_colors.dart
// Neo-Brutalism + 16-Bit / 26-Bit Arcade Gaming Design Tokens & Decorations.

import 'package:flutter/material.dart';

class AppColors {
  // --- Neo-Brutalism & 16-Bit Arcade Palette ---
  static const Color neoPitchBlack = Color(0xFF0A0D14); // Derin Katot Siyahı Tuval
  static const Color neoCardBg = Color(0xFF121722); // Panel Arka Planı
  static const Color neoInnerBg = Color(0xFF1B2230); // İç Kutu Arka Planı
  static const Color neoBorderBlack = Color(0xFF000000); // Sert Siyah Outlines

  // --- Saturated Acid / Neon Accents ---
  static const Color neonLime = Color(0xFF00FF66); // Acid Lime Green
  static const Color neonPink = Color(0xFFFF007F); // Electric Magenta/Pink
  static const Color neonCyan = Color(0xFF00F0FF); // Cyber Cyan
  static const Color neonAmber = Color(0xFFFFB800); // Arcade Amber
  static const Color neonPurple = Color(0xFFB026FF); // Vapor Purple
  static const Color comicYellow = Color(0xFFFFE600); // Punchy Yellow
  static const Color comicRed = Color(0xFFFF2A2A); // Radical Red
  static const Color accentGold = Color(0xFFFFD700); // Pixel Gold
  static const Color accentGoldLight = Color(0xFFFFF066);

  // --- Legacy Color Aliases (Compatibility) ---
  static const Color win95Grey = Color(0xFF1B2230); // Replaced with dark neo surface
  static const Color win95DarkGrey = Color(0xFF2E3846); 
  static const Color win95LightGrey = Color(0xFF2E3846);
  static const Color win95White = Color(0xFF00F0FF);
  static const Color win95Black = Color(0xFF000000);
  static const Color win95TitleNavy = Color(0xFF121722);
  static const Color win95TitleCyan = Color(0xFF00F0FF);
  static const Color win95Teal = Color(0xFF00FF66);

  // --- Retro Tuval & Sinyal Renkleri ---
  static const Color primaryDark = Color(0xFF0D141E);
  static const Color primaryDeep = neoPitchBlack;
  static const Color signalGreen = neonLime;
  static const Color signalRed = comicRed;
  static const Color signalAmber = neonAmber;
  static const Color rivalBlue = neonCyan;

  // Nötr Renkler
  static const Color neutral900 = neoCardBg;
  static const Color neutral800 = neoInnerBg;
  static const Color neutral700 = Color(0xFF2B3548);
  static const Color neutral300 = Color(0xFF94A3B8);
  static const Color neutral50 = Color(0xFFF1F5F9);

  // Nadirlik Renkleri (16-Bit Arcade RPG)
  static const Color rarityAmateur = Color(0xFF9E9E9E); // 1★ Gri
  static const Color rarityPro = neonLime; // 2★ Neon Yeşil
  static const Color rarityQuality = neonCyan; // 3★ Elektrik Mavi
  static const Color rarityStar = Color(0xFFD946EF); // 4★ Siber Fuşya
  static const Color rarityLegend = accentGold; // 5★ Piksel Altın
  static const Color rarityIcon = Color(0xFFFFFFFF); // 5★+ Elmas Beyazı

  static Color getRarityColor(int stars) {
    switch (stars) {
      case 1:
        return rarityAmateur;
      case 2:
        return rarityPro;
      case 3:
        return rarityQuality;
      case 4:
        return rarityStar;
      case 5:
      default:
        return rarityLegend;
    }
  }

  /// Pure Neo-Brutalist Box Decoration with Thick Black Outline & Hard Offset Unblurred Shadow
  static BoxDecoration neoBoxDecoration({
    Color backgroundColor = neoCardBg,
    Color borderColor = Colors.black,
    Color shadowColor = Colors.black,
    Offset shadowOffset = const Offset(4, 4),
    double borderWidth = 2.5,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius,
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          offset: shadowOffset,
          blurRadius: 0,
        ),
      ],
    );
  }

  /// Backward-compatible alias that applies Neo-Brutalist flat offset styling instead of Win95 bevels
  static BoxDecoration win95BoxDecoration({
    Color backgroundColor = neoCardBg,
    bool isPressed = false,
    bool hasHardShadow = true,
    double borderWidth = 2.0,
  }) {
    return neoBoxDecoration(
      backgroundColor: backgroundColor,
      borderColor: Colors.black,
      shadowColor: isPressed ? Colors.transparent : Colors.black,
      shadowOffset: isPressed ? Offset.zero : const Offset(3, 3),
      borderWidth: borderWidth,
    );
  }

  /// Comic & Arcade High-Impact Neo-Brutalist Decoration
  static BoxDecoration comicBoxDecoration({
    Color backgroundColor = neoCardBg,
    Color borderColor = Colors.black,
    Color shadowColor = neonLime,
    double borderWidth = 2.5,
    Offset shadowOffset = const Offset(4, 4),
  }) {
    return neoBoxDecoration(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      shadowColor: shadowColor,
      borderWidth: borderWidth,
      shadowOffset: shadowOffset,
    );
  }
}
