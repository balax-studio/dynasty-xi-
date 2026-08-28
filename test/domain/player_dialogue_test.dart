import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/rpg/player_dialogue_engine.dart';

void main() {
  group('PlayerDialogueEngine RPG Tests', () {
    Player createTestPlayer({
      required PersonalityType personality,
      int morale = 60,
      int loyalty = 50,
    }) {
      return Player(
        id: 'p-dialogue-1',
        firstName: 'Kerem',
        lastName: 'Aktürkoğlu',
        countryCode: 'TR',
        position: Position.lw,
        age: 25,
        pace: 88,
        technique: 84,
        shooting: 79,
        passing: 78,
        defending: 42,
        physical: 70,
        mentality: 80,
        potential: 86,
        personality: personality,
        morale: morale,
        loyalty: loyalty,
        weeklyWage: 15000,
        contractSeasonsLeft: 2,
        releaseClause: 500000,
        faceSeed: 'kerem-seed',
      );
    }

    test('getTopicsForPlayer returns 4 categories for owned and 2 for unowned', () {
      final player = createTestPlayer(personality: PersonalityType.ambitious);

      final ownedTopics = PlayerDialogueEngine.getTopicsForPlayer(player, isOwned: true);
      expect(ownedTopics.length, 4);
      expect(ownedTopics.map((t) => t.category), containsAll([
        DialogueTopicCategory.performance,
        DialogueTopicCategory.playingTime,
        DialogueTopicCategory.training,
        DialogueTopicCategory.leadership,
      ]));

      final unownedTopics = PlayerDialogueEngine.getTopicsForPlayer(player, isOwned: false);
      expect(unownedTopics.length, 2);
      expect(unownedTopics.map((t) => t.category), containsAll([
        DialogueTopicCategory.transferPersuasion,
        DialogueTopicCategory.characterScout,
      ]));
    });

    test('Praise gives high morale to Ambitious or Temperamental players', () {
      final player = createTestPlayer(personality: PersonalityType.ambitious);
      final topics = PlayerDialogueEngine.getTopicsForPlayer(player, isOwned: true);
      final perfTopic = topics.firstWhere((t) => t.id == 'topic_performance');
      final praiseOption = perfTopic.options.firstWhere((o) => o.id == 'perf_praise');

      final result = PlayerDialogueEngine.evaluateChoice(
        player: player,
        topic: perfTopic,
        option: praiseOption,
        clubCash: 50000,
        clubLockerRoom: 50,
      );

      expect(result.deltaMorale, greaterThanOrEqualTo(15));
      expect(result.reactionEmoji, '[FORM]');
      expect(result.playerReplyText, contains('bu güveninizi boşa çıkarmayacağım'));
    });

    test('Harsh disciplinary warning causes severe morale drop and locker room unrest for Rebel players', () {
      final player = createTestPlayer(personality: PersonalityType.rebel);
      final topics = PlayerDialogueEngine.getTopicsForPlayer(player, isOwned: true);
      final perfTopic = topics.firstWhere((t) => t.id == 'topic_performance');
      final warningOption = perfTopic.options.firstWhere((o) => o.id == 'perf_warning');

      final result = PlayerDialogueEngine.evaluateChoice(
        player: player,
        topic: perfTopic,
        option: warningOption,
        clubCash: 50000,
        clubLockerRoom: 50,
      );

      expect(result.deltaMorale, lessThan(-15));
      expect(result.deltaLockerRoom, lessThan(0));
      expect(result.reactionEmoji, '');
      expect(result.playerReplyText, contains('Beni günah keçisi yapamazsınız'));
    });

    test('Bonus promise delivers massive morale and sharpness to Mercenary players', () {
      final player = createTestPlayer(personality: PersonalityType.mercenary);
      final topics = PlayerDialogueEngine.getTopicsForPlayer(player, isOwned: true);
      final perfTopic = topics.firstWhere((t) => t.id == 'topic_performance');
      final bonusOption = perfTopic.options.firstWhere((o) => o.id == 'perf_bonus_promise');

      final result = PlayerDialogueEngine.evaluateChoice(
        player: player,
        topic: perfTopic,
        option: bonusOption,
        clubCash: 10000,
        clubLockerRoom: 50,
      );

      expect(result.deltaCash, -2500);
      expect(result.deltaMorale, 25);
      expect(result.deltaSharpness, 15);
      expect(result.reactionEmoji, '');
    });

    test('Transfer vision pitch secures 20% transfer discount with Ambitious targets', () {
      final player = createTestPlayer(personality: PersonalityType.ambitious);
      final topics = PlayerDialogueEngine.getTopicsForPlayer(player, isOwned: false);
      final transTopic = topics.firstWhere((t) => t.id == 'topic_transfer_persuasion');
      final visionOption = transTopic.options.firstWhere((o) => o.id == 'trans_vision_trophies');

      final result = PlayerDialogueEngine.evaluateChoice(
        player: player,
        topic: transTopic,
        option: visionOption,
        clubCash: 50000,
        clubLockerRoom: 50,
      );

      expect(result.transferDiscountPercent, 20);
      expect(result.reactionEmoji, '[KUPA]');
      expect(result.summaryDeltas, contains('%20 Transfer İndirimi'));
    });

    test('Rally team leadership assignment boosts club locker room when player is a Leader', () {
      final player = createTestPlayer(personality: PersonalityType.leader);
      final topics = PlayerDialogueEngine.getTopicsForPlayer(player, isOwned: true);
      final leadTopic = topics.firstWhere((t) => t.id == 'topic_leadership');
      final rallyOption = leadTopic.options.firstWhere((o) => o.id == 'lead_rally_team');

      final result = PlayerDialogueEngine.evaluateChoice(
        player: player,
        topic: leadTopic,
        option: rallyOption,
        clubCash: 50000,
        clubLockerRoom: 50,
      );

      expect(result.deltaLockerRoom, greaterThanOrEqualTo(10));
      expect(result.deltaMorale, greaterThanOrEqualTo(10));
      expect(result.reactionEmoji, 'SHIELD');
    });
  });
}
