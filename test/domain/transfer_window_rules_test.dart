// test/domain/transfer_window_rules_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/core/time/game_clock.dart';
import 'package:futbol/domain/transfers/transfer_window_rules.dart';

void main() {
  group('TransferWindowRules Tests', () {
    test('isWindowOpen accurately reflects SeasonPhase', () {
      expect(TransferWindowRules.isWindowOpen(SeasonPhase.preSeason), isTrue);
      expect(TransferWindowRules.isWindowOpen(SeasonPhase.midSeasonBreak), isTrue);
      expect(TransferWindowRules.isWindowOpen(SeasonPhase.firstHalf), isFalse);
      expect(TransferWindowRules.isWindowOpen(SeasonPhase.secondHalf), isFalse);
      expect(TransferWindowRules.isWindowOpen(SeasonPhase.seasonEvaluation), isFalse);
    });

    test('canRegisterPlayer enforces 25 A-Team squad limit while allowing U21 exemption', () {
      expect(TransferWindowRules.canRegisterPlayer(currentSquadSize: 20, isU21: false), isTrue);
      expect(TransferWindowRules.canRegisterPlayer(currentSquadSize: 24, isU21: false), isTrue);
      expect(TransferWindowRules.canRegisterPlayer(currentSquadSize: 25, isU21: false), isFalse);
      // U21 homegrown player does not consume A-Team 25 quota
      expect(TransferWindowRules.canRegisterPlayer(currentSquadSize: 25, isU21: true), isTrue);
      expect(TransferWindowRules.canRegisterPlayer(currentSquadSize: 28, isU21: true), isTrue);
    });

    test('validatePurchase rejects transactions when transfer window is closed', () {
      final result = TransferWindowRules.validatePurchase(
        phase: SeasonPhase.firstHalf,
        clubCash: 50000,
        playerFee: 10000,
        currentSquadSize: 20,
        isU21: false,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Tescil penceresi kapalı'));
    });

    test('validatePurchase rejects transactions when club cash is insufficient', () {
      final result = TransferWindowRules.validatePurchase(
        phase: SeasonPhase.preSeason,
        clubCash: 5000,
        playerFee: 10000,
        currentSquadSize: 20,
        isU21: false,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Kasa bütçesi yetersiz'));
    });

    test('validatePurchase rejects transactions when A-Team squad is full (25 players)', () {
      final result = TransferWindowRules.validatePurchase(
        phase: SeasonPhase.preSeason,
        clubCash: 50000,
        playerFee: 10000,
        currentSquadSize: 25,
        isU21: false,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('A Takım tescil kotası dolu'));
    });

    test('validatePurchase allows valid purchase during open window', () {
      final result = TransferWindowRules.validatePurchase(
        phase: SeasonPhase.midSeasonBreak,
        clubCash: 50000,
        playerFee: 10000,
        currentSquadSize: 22,
        isU21: false,
      );

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });
  });
}
