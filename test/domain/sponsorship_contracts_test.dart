// test/domain/sponsorship_contracts_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/economy/financial_statement.dart';
import 'package:futbol/domain/economy/sponsorship_contract.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/manager.dart';
import 'package:futbol/domain/entities/meter.dart';

void main() {
  group('Sponsorship Domain & Anti-Spam RPG Contract Tests', () {
    test('Catalog provides tiered sponsorship contracts across all 3 slots', () {
      final tier20Contracts = SponsorshipCatalog.getAvailableContracts(20);
      expect(tier20Contracts.isNotEmpty, true);

      final mainShirtContracts = tier20Contracts.where((c) => c.slot == SponsorshipSlot.mainShirt).toList();
      final sleeveContracts = tier20Contracts.where((c) => c.slot == SponsorshipSlot.sleeve).toList();
      final stadiumContracts = tier20Contracts.where((c) => c.slot == SponsorshipSlot.stadiumNaming).toList();

      expect(mainShirtContracts.length, greaterThanOrEqualTo(3));
      expect(sleeveContracts.length, greaterThanOrEqualTo(2));
      expect(stadiumContracts.length, greaterThanOrEqualTo(2));

      for (final contract in tier20Contracts) {
        expect(contract.weeklyIncome, greaterThan(0));
        expect(contract.durationWeeks, greaterThan(0));
        expect(contract.perk.description.isNotEmpty, true);
        expect(contract.risk.description.isNotEmpty, true);
      }
    });

    test('Higher league tier boosts weekly income and signing bonuses', () {
      final tier20Contracts = SponsorshipCatalog.getAvailableContracts(20);
      final tier1Contracts = SponsorshipCatalog.getAvailableContracts(1);

      final t20Crypto = tier20Contracts.firstWhere((c) => c.id == 'main_cryptobet_cyber');
      final t1Crypto = tier1Contracts.firstWhere((c) => c.id == 'main_cryptobet_cyber');

      expect(t1Crypto.weeklyIncome, greaterThan(t20Crypto.weeklyIncome));
      expect(t1Crypto.signingBonus, greaterThan(t20Crypto.signingBonus));
    });

    test('SponsorshipContract JSON serialization and deserialization is lossless', () {
      const contract = SponsorshipContract(
        id: 'test_eco_future',
        brandName: 'EcoFuture Renewables',
        brandIcon: '',
        sector: 'Yeşil Enerji',
        slot: SponsorshipSlot.mainShirt,
        weeklyIncome: 4200,
        signingBonus: 15000,
        durationWeeks: 12,
        weeksRemaining: 8,
        perk: SponsorshipPerk(
          description: '+6 Taraftar, +4 Yönetim Güveni',
          fanDelta: 6,
          boardTrustDelta: 4,
        ),
        risk: SponsorshipRisk(
          description: 'Erken fesihte ₣5000 tazminat',
          earlyTerminationPenalty: 5000,
        ),
      );

      final json = contract.toJson();
      final revived = SponsorshipContract.fromJson(json);

      expect(revived.id, contract.id);
      expect(revived.brandName, contract.brandName);
      expect(revived.slot, SponsorshipSlot.mainShirt);
      expect(revived.weeklyIncome, 4200);
      expect(revived.signingBonus, 15000);
      expect(revived.durationWeeks, 12);
      expect(revived.weeksRemaining, 8);
      expect(revived.perk.fanDelta, 6);
      expect(revived.risk.earlyTerminationPenalty, 5000);
    });

    test('GameState correctly stores and serializes activeSponsorships map', () {
      const club = Club(
        id: 'c1',
        name: 'Test FC',
        city: 'Ankara',
        leagueTier: 20,
        meters: ClubMeters(cash: 20000),
      );

      const manager = Manager(
        name: 'Alex Ferguson',
        reputation: 50,
      );

      const contract = SponsorshipContract(
        id: 'anadolu_celik',
        brandName: 'Anadolu Çelik Sanayi',
        brandIcon: '',
        sector: 'Ağır Sanayi',
        slot: SponsorshipSlot.mainShirt,
        weeklyIncome: 3500,
        signingBonus: 10000,
        durationWeeks: 10,
        weeksRemaining: 10,
        perk: SponsorshipPerk(
          description: 'Tesis inşaatlarında %10 indirim',
          facilityDiscount: 0.10,
        ),
        risk: SponsorshipRisk(
          description: 'Ağır sanayi imajı: -2 Taraftar Memnuniyeti',
          fanDelta: -2,
        ),
      );

      const gameState = GameState(
        userClub: club,
        manager: manager,
        activeSponsorships: {
          SponsorshipSlot.mainShirt: contract,
        },
      );

      expect(gameState.activeSponsorships.containsKey(SponsorshipSlot.mainShirt), true);
      expect(gameState.activeSponsorships[SponsorshipSlot.mainShirt]?.brandName, 'Anadolu Çelik Sanayi');

      final json = gameState.toJson();
      final revived = GameState.fromJson(json);

      expect(revived.activeSponsorships.containsKey(SponsorshipSlot.mainShirt), true);
      expect(revived.activeSponsorships[SponsorshipSlot.mainShirt]?.weeklyIncome, 3500);
    });

    test('Contract isExpired is true when weeksRemaining reaches zero', () {
      const activeContract = SponsorshipContract(
        id: 'test',
        brandName: 'Test',
        brandIcon: 'STAR',
        sector: 'Test',
        slot: SponsorshipSlot.sleeve,
        weeklyIncome: 1000,
        signingBonus: 2000,
        durationWeeks: 10,
        weeksRemaining: 2,
        perk: SponsorshipPerk(description: 'Test perk'),
        risk: SponsorshipRisk(description: 'Test risk'),
      );

      expect(activeContract.isExpired, false);

      final expired = activeContract.copyWith(weeksRemaining: 0);
      expect(expired.isExpired, true);
    });
  });
}
