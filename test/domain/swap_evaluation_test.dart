// test/domain/swap_evaluation_test.dart
// Unit tests for Intelligent Swap Evaluation Engine

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/economy/swap_evaluation_engine.dart';
import 'package:futbol/domain/entities/player.dart';

void main() {
  group('SwapEvaluationEngine Tests', () {
    const targetPlayer = Player(
      id: 'target_1',
      firstName: 'Mauro',
      lastName: 'Icardi',
      countryCode: 'AR',
      age: 31,
      position: Position.st,
      pace: 76,
      technique: 85,
      shooting: 90,
      passing: 74,
      defending: 35,
      physical: 78,
      mentality: 86,
      potential: 88,
      weeklyWage: 15000,
    );

    test('Rejects aged, high-wage deadwood swap candidate', () {
      const oldDeadwood = Player(
        id: 'old_1',
        firstName: 'Emre',
        lastName: 'Taşdemir',
        countryCode: 'TR',
        age: 34,
        position: Position.lb,
        pace: 55,
        technique: 60,
        shooting: 50,
        passing: 60,
        defending: 60,
        physical: 55,
        mentality: 65,
        potential: 65,
        weeklyWage: 8000,
      );

      final result = SwapEvaluationEngine.evaluate(
        targetPlayer: targetPlayer,
        swapPlayer: oldDeadwood,
        offeredCash: 50000,
        askingFee: 150000,
      );

      expect(result.isRejected, isTrue);
      expect(result.responseMessage, contains('yüksek maaş yükü ve ilerlemiş yaşı'));
      expect(result.effectiveSwapDiscount, equals(0));
    });

    test('Rejects swap candidate with severe quality gap', () {
      const lowQuality = Player(
        id: 'low_1',
        firstName: 'Ali',
        lastName: 'Yıldız',
        countryCode: 'TR',
        age: 26,
        position: Position.st,
        pace: 50,
        technique: 50,
        shooting: 50,
        passing: 50,
        defending: 30,
        physical: 50,
        mentality: 50,
        potential: 60,
        weeklyWage: 1000,
      );

      final result = SwapEvaluationEngine.evaluate(
        targetPlayer: targetPlayer,
        swapPlayer: lowQuality,
        offeredCash: 30000,
        askingFee: 150000,
      );

      expect(result.isRejected, isTrue);
      expect(result.responseMessage, contains('mevcut seviyesi ilk 11 planlarımızın oldukça gerisinde'));
    });

    test('Accepts high-potential wonderkid swap when cash covers remaining fee', () {
      const wonderkid = Player(
        id: 'wonder_1',
        firstName: 'Semih',
        lastName: 'Kılıçsoy',
        countryCode: 'TR',
        age: 19,
        position: Position.st,
        pace: 84,
        technique: 82,
        shooting: 85,
        passing: 72,
        defending: 35,
        physical: 80,
        mentality: 80,
        potential: 89,
        weeklyWage: 4000,
      );

      final askingFee = targetPlayer.marketValue;
      final offeredCash = askingFee - wonderkid.marketValue;

      final result = SwapEvaluationEngine.evaluate(
        targetPlayer: targetPlayer,
        swapPlayer: wonderkid,
        offeredCash: offeredCash > 0 ? offeredCash : 10000,
        askingFee: askingFee,
      );

      expect(result.isAccepted, isTrue);
      expect(result.responseMessage, contains('yüksek potansiyeliyle geleceğimize büyük katkı sağlayacaktır'));
      expect(result.effectiveSwapDiscount, greaterThan(0));
    });

    test('Issues counter-offer when swap player is good but cash is insufficient', () {
      const goodSwap = Player(
        id: 'good_1',
        firstName: 'Cenk',
        lastName: 'Tosun',
        countryCode: 'TR',
        age: 29,
        position: Position.st,
        pace: 75,
        technique: 78,
        shooting: 82,
        passing: 70,
        defending: 40,
        physical: 78,
        mentality: 82,
        potential: 82,
        weeklyWage: 6000,
      );

      final result = SwapEvaluationEngine.evaluate(
        targetPlayer: targetPlayer,
        swapPlayer: goodSwap,
        offeredCash: 5000,
        askingFee: 300000,
      );

      expect(result.isCounterOffer, isTrue);
      expect(result.requiredAdditionalCash, greaterThan(0));
      expect(result.responseMessage, contains('ek ₣'));
    });
  });
}
