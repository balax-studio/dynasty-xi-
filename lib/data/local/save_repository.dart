// data/local/save_repository.dart
// Handles save/load of GameState with SharedPreferences, versioning and initial game creation.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/rng/deterministic_rng.dart';
import '../../core/time/game_clock.dart';
import '../../domain/entities/club.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/manager.dart';
import '../../domain/entities/meter.dart';
import '../../domain/entities/player.dart';
import '../../domain/generation/club_generator.dart';
import '../../domain/generation/player_generator.dart';
import '../assets/card_database.dart';

class SaveRepository {
  static const String _kSaveKey = 'dynasty_xi_save_state_v1';
  static const String _kLastExitTimeKey = 'dynasty_xi_last_exit_epoch_ms';

  Future<void> save(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson());
    await prefs.setString(_kSaveKey, jsonString);
    await prefs.setInt(_kLastExitTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<GameState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_kSaveKey);
    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameState.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSaveKey);
    await prefs.remove(_kLastExitTimeKey);
  }

  Future<int?> getLastExitEpochMs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kLastExitTimeKey);
  }

  /// Yeni Bir Oyun Durumu Başlatır (FTUE ile 20. Ligden Başlangıç)
  static GameState createNewGame({
    String clubName = 'Angora Gücü',
    String managerName = 'Hoca',
    String primaryColorHex = '#0B2E20',
    String secondaryColorHex = '#D9A62E',
    String badgeIcon = '🛡️',
  }) {
    final rng = DeterministicRng(DateTime.now().millisecondsSinceEpoch);

    // Kullanıcı Kadrosu Üretimi (20. Lig Kademesi)
    final squad = PlayerGenerator.generateSquad(
      rng: rng,
      leagueTier: 20,
      clubIdPrefix: 'user_c',
    );

    // Kaptan Osman Yalçın
    final captain = squad.firstWhere(
      (p) => p.position.isMidfielder || p.position.isForward,
      orElse: () => squad[0],
    );
    final squadWithCaptain = squad.map((p) {
      if (p.id == captain.id) {
        return p.copyWith(
          firstName: 'Osman',
          lastName: 'Yalçın',
          position: Position.cm,
          personality: PersonalityType.leader,
          morale: 45, // Başlangıçta maaş alamadığı için morali düşük
        );
      }
      return p;
    }).toList();

    final starting11 = squadWithCaptain.take(11).map((p) => p.id).toList();
    final subs = squadWithCaptain.skip(11).map((p) => p.id).toList();

    final facMap = <FacilityType, Facility>{};
    for (final type in FacilityType.values) {
      facMap[type] = Facility(
        type: type,
        level: type == FacilityType.stadium ? 1 : 0, // Sadece stadyum açık başlar
      );
    }

    final userClub = Club(
      id: 'user_c',
      name: clubName,
      city: 'Angora',
      badgeIcon: badgeIcon,
      primaryColorHex: primaryColorHex,
      secondaryColorHex: secondaryColorHex,
      leagueTier: 20,
      isUserClub: true,
      meters: const ClubMeters(
        cash: 12000,
        fans: 40,
        lockerRoom: 35,
        boardTrust: 50,
      ),
      facilities: facMap,
      squad: squadWithCaptain,
      starting11Ids: starting11,
      substituteIds: subs,
      formation: '4-3-3',
      tacticalStyle: 'Dengeli',
      ticketPrice: 8,
      sponsorWeeklyIncome: 1500,
    );

    final manager = Manager(
      name: managerName,
      level: 1,
      currentXp: 0,
      reputation: 30,
    );

    final league = ClubGenerator.generateLeague(
      rng: rng,
      leagueTier: 20,
      userClub: userClub,
      seasonNumber: 1,
    );

    // Transfer Pazarında 5 adet serbest oyuncu
    final transferPool = <Player>[];
    for (var i = 0; i < 5; i++) {
      transferPool.add(PlayerGenerator.generatePlayer(
        rng: rng,
        position: Position.values[i % Position.values.length],
        targetOvr: 52 + rng.nextInt(6),
        id: 'free_agent_$i',
      ));
    }

    return GameState(
      userClub: userClub,
      manager: manager,
      clock: const GameClock(
        seasonNumber: 1,
        dayOfSeason: 1,
        matchday: 1,
        currentWindow: MatchWindow.morning,
      ),
      currentLeague: league,
      transferMarket: transferPool,
      pendingCards: CardDatabase.mvpCards.take(2).toList(),
      isFtueActive: true,
      ftueStep: 0,
      targetLeaguePosition: 5,
      notificationLog: ['Dynasty XI kariyeriniz başladı. Hoş geldiniz hocam!'],
    );
  }
}
