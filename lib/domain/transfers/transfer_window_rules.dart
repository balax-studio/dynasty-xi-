// domain/transfers/transfer_window_rules.dart
// FIFA and League Transfer Window & 25-Player Squad Registration Governance Rules

import '../../core/time/game_clock.dart';

class TransferValidationResult {
  final bool isValid;
  final String? errorMessage;

  const TransferValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  static const TransferValidationResult valid = TransferValidationResult(isValid: true);

  factory TransferValidationResult.error(String message) => TransferValidationResult(
        isValid: false,
        errorMessage: message,
      );
}

class TransferWindowRules {
  static const int maxSquadRegistrationLimit = 25;
  static const int u21AgeThreshold = 21;

  /// Returns true if registration window is open in current season phase
  static bool isWindowOpen(SeasonPhase phase) {
    return phase.isTransferWindowOpen;
  }

  /// Returns user-friendly status banner for transfer screen
  static String getWindowStatusLabel(SeasonPhase phase) {
    switch (phase) {
      case SeasonPhase.preSeason:
        return 'YAZ TRANSFER TESCİL PENCERESİ AÇIK';
      case SeasonPhase.midSeasonBreak:
        return 'KIŞ ARA TRANSFER TESCİL PENCERESİ AÇIK';
      case SeasonPhase.firstHalf:
      case SeasonPhase.secondHalf:
        return 'RESMİ TESCİL PENCERESİ KAPALI (ÖN İZLEME & SCOUT TAKİBİ)';
      case SeasonPhase.seasonEvaluation:
        return 'SEZON SONU MALİ DÖNEMİ (YAZ PENCERESİ YAKINDA)';
    }
  }

  /// Checks if a player can be registered in the squad
  static bool canRegisterPlayer({
    required int currentSquadSize,
    required bool isU21,
  }) {
    if (isU21) {
      // U21 homegrown players do not occupy 25-player A-Team registration list
      return true;
    }
    return currentSquadSize < maxSquadRegistrationLimit;
  }

  /// Validates a potential player transfer transaction
  static TransferValidationResult validatePurchase({
    required SeasonPhase phase,
    required int clubCash,
    required int playerFee,
    required int currentSquadSize,
    required bool isU21,
  }) {
    if (!isWindowOpen(phase)) {
      return TransferValidationResult.error(
        'Tescil penceresi kapalı! Oyuncu transferi ve lisans kaydı yalnızca Yaz (Sezon Öncesi) ve Kış (Devre Arası) tescil dönemlerinde yapılabilir.',
      );
    }

    if (clubCash < playerFee) {
      return TransferValidationResult.error(
        'Kasa bütçesi yetersiz! Transfer bedeli için ₣$playerFee gerekiyor (Mevcut Kasa: ₣$clubCash).',
      );
    }

    if (!canRegisterPlayer(currentSquadSize: currentSquadSize, isU21: isU21)) {
      return TransferValidationResult.error(
        'A Takım tescil kotası dolu ($currentSquadSize/$maxSquadRegistrationLimit)! Yeni oyuncu kaydetmek için kadrodan oyuncu satmalı veya serbest bırakmalısınız.',
      );
    }

    return TransferValidationResult.valid;
  }
}
