// core/audio/audio_synthesizer.dart
// Web Audio and Sound Synthesizer for Dynasty XI UI, Match whistle, Goal celebration and Card swipes.

import 'package:flutter/services.dart';

class AudioSynthesizer {
  static bool soundEnabled = true;

  /// Karar Kartı Kaydırma / Seçim Sesi
  static void playCardSwipe() {
    if (!soundEnabled) return;
    SystemSound.play(SystemSoundType.click);
  }

  /// Buton / Menü Dokunma Sesi
  static void playClick() {
    if (!soundEnabled) return;
    SystemSound.play(SystemSoundType.click);
  }

  /// Hakem Düdüğü (Maç Başlangıcı / Bitişi)
  static void playWhistle() {
    if (!soundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
  }

  /// Gol Sesi & Tribün Coşkusu
  static void playGoalFanfare() {
    if (!soundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
  }

  /// Şampiyonluk & Kupa Töreni
  static void playTrophyFanfare() {
    if (!soundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
  }

  /// Başarı / Onay Sesi
  static void playSuccess() {
    if (!soundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
  }

  /// Başarısızlık / Ret Sesi
  static void playFailure() {
    if (!soundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
  }

  /// Para / Kasa Harcama Sesi
  static void playMoney() {
    if (!soundEnabled) return;
    SystemSound.play(SystemSoundType.click);
  }

  static void toggleSound() {
    soundEnabled = !soundEnabled;
  }
}
