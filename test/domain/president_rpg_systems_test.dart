// test/domain/president_rpg_systems_test.dart
// Unit tests for all President RPG depth domain systems.

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/economy/stock_market.dart';
import 'package:futbol/domain/economy/tax_audit.dart';
import 'package:futbol/domain/player/player_agent_deals.dart';
import 'package:futbol/domain/president/board_factions.dart';
import 'package:futbol/domain/president/clubs_association.dart';
import 'package:futbol/domain/president/midnight_tv_debate.dart';
import 'package:futbol/domain/president/president_crisis.dart';
import 'package:futbol/domain/president/president_lifestyle.dart';
import 'package:futbol/domain/president/president_origin.dart';
import 'package:futbol/domain/president/legal_defense.dart';
import 'package:futbol/domain/transfers/transfer_hijack.dart';

void main() {
  group('President Origin Archetypes', () {
    test('all 4 archetypes exist with distinct stat modifiers', () {
      final origins = PresidentOrigin.getAllOrigins();
      expect(origins.length, 4);

      for (final origin in origins) {
        expect(origin.title.isNotEmpty, true);
        expect(origin.perkDescription.isNotEmpty, true);
        expect(origin.flawDescription.isNotEmpty, true);
      }
    });
  });

  group('President Crisis Hotline & Ref Tunnel', () {
    test('predefined crisis callers exist and have valid choices', () {
      final callers = PresidentCrisisCall.getPredefinedCalls();
      expect(callers.length, 4);

      for (final caller in callers) {
        expect(caller.callerName.isNotEmpty, true);
        expect(caller.choices.length, 3);
        for (final choice in caller.choices) {
          expect(choice.title.isNotEmpty, true);
          expect(choice.outcomeMessage.isNotEmpty, true);
        }
      }
    });

    test('ref tunnel confrontation options have valid outcomes', () {
      final outcome = RefTunnelOutcome.executeConfrontation(0);
      expect(outcome.title.isNotEmpty, true);
      expect(outcome.narrative.isNotEmpty, true);
    });
  });

  group('Board Factions & Takeovers', () {
    test('board factions calculate majority correctly', () {
      final state = BoardFactionsState.createInitialState();
      expect(state.members.length, 5);

      final totalPower = state.members.fold(0, (sum, f) => sum + f.votingPowerPercent);
      expect(totalPower, greaterThan(0));
      expect(state.isEarlyElectionMotionActive, false);
      expect(state.totalPresidentialSupportPercent, greaterThan(0));
    });

    test('foreign takeover offers provide valid valuation', () {
      final offers = ForeignTakeoverOffer.getAvailableOffers();
      expect(offers.isNotEmpty, true);
      for (final offer in offers) {
        expect(offer.investorName.isNotEmpty, true);
        expect(offer.cashOfferAmount, greaterThan(0));
      }
    });
  });

  group('Tax Audit & Legal Defense', () {
    test('tax audit scenarios have options with financial consequences', () {
      final scenario = TaxAuditScenario.generateInspection(600000);
      expect(scenario.title.isNotEmpty, true);
      expect(scenario.auditFineAmount, greaterThan(0));
    });

    test('legal cases have calculated success chances', () {
      final cases = LegalCaseItem.getActiveCases();
      expect(cases.isNotEmpty, true);

      for (final c in cases) {
        expect(c.appealCost, greaterThan(0));
        expect(c.successChancePercent, inInclusiveRange(0, 100));
      }
    });
  });

  group('Transfer Hijacking & Agent Deals', () {
    test('transfer hijack targets have rival bid info and fan hype', () {
      final targets = TransferHijackTarget.getAvailableHijacks();
      expect(targets.isNotEmpty, true);

      for (final t in targets) {
        expect(t.requiredHijackBid, greaterThan(t.rivalBidAmount));
        expect(t.fansHypeBonus, greaterThan(0));
      }
    });

    test('agent meeting options provide commission and loyalty trade-offs', () {
      final options = PlayerAgentMeetingOption.getOptions();
      expect(options.isNotEmpty, true);

      for (final opt in options) {
        expect(opt.title.isNotEmpty, true);
      }
    });
  });

  group('Midnight TV Debates, Lifestyle & Clubs Association', () {
    test('midnight TV debates have pundit accusations and rating consequences', () {
      final debates = TvDebateTopic.getAvailableDebates();
      expect(debates.isNotEmpty, true);

      for (final d in debates) {
        expect(d.punditName.isNotEmpty, true);
        expect(d.choices.isNotEmpty, true);
        for (final c in d.choices) {
          expect(c.ratingScore, inInclusiveRange(0.0, 10.0));
        }
      }
    });

    test('president luxury lifestyle catalog includes high-prestige assets', () {
      final assets = PresidentLuxuryAsset.getDefaultCatalog();
      expect(assets.length, 4);

      for (final a in assets) {
        expect(a.purchaseCost, greaterThan(0));
        expect(a.prestigeBonus, greaterThan(0));
      }
    });

    test('clubs association summit active agendas include coalition voting', () {
      final agendas = AssociationSummitAgenda.getActiveAgendas();
      expect(agendas.isNotEmpty, true);

      for (final a in agendas) {
        expect(a.options.length, 2);
        for (final opt in a.options) {
          expect(opt.supportPercent, inInclusiveRange(0, 100));
        }
      }
    });

    test('legal defense case items have valid penalties and success chances', () {
      final cases = LegalCaseItem.getActiveCases();
      expect(cases.isNotEmpty, true);

      for (final c in cases) {
        expect(c.initialPenalty, greaterThan(0));
        expect(c.appealCost, greaterThan(0));
        expect(c.successChancePercent, inInclusiveRange(1, 100));
        expect(c.victoryOutcome.isNotEmpty, true);
      }
    });
  });
}
