// test/domain/spec_verification_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/local/save_repository.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/president/president_crisis.dart';

void main() {
  group('Spec Full System Verification (§ Acceptance Criteria Matrix)', () {
    test('Criterion #16: Active crisis call and GameState serialize and deserialize cleanly', () {
      final initial = SaveRepository.createNewGame().copyWith(
        activeCrisisCall: const PresidentCrisisCall(
          id: 'crisis_test_1',
          caller: CrisisCallerType.mayor,
          callerName: 'Recep Vardar',
          callerTitle: 'Belediye Başkanı',
          callerAvatar: '🏛️',
          dialogQuote: 'Kulüp kasası kritik seviyede.',
          choices: [
            CrisisChoice(
              title: 'Kabul Et',
              description: 'Para geldi, güven azaldı',
              cashDelta: 50000,
              boardTrustDelta: -10,
              outcomeMessage: 'Kredi onaylandı',
            ),
          ],
        ),
        crisisCooldownMatches: 2,
        resolvedCrisisIds: ['crisis_prev_1'],
        clubXp: 1500,
      );

      final json = initial.toJson();
      final loaded = GameState.fromJson(json);

      expect(loaded.activeCrisisCall, isNotNull);
      expect(loaded.activeCrisisCall?.id, equals('crisis_test_1'));
      expect(loaded.crisisCooldownMatches, equals(2));
      expect(loaded.resolvedCrisisIds, contains('crisis_prev_1'));
      expect(loaded.clubXp, equals(1500));
      expect(loaded.clubLevel, equals(3));
    });

    test('Criterion #17: Nullable state fields support clean clearing in copyWith', () {
      final initial = SaveRepository.createNewGame();
      expect(initial.activeLoan, isNull);

      final withCrisis = initial.copyWith(
        activeCrisisCall: const PresidentCrisisCall(
          id: 'c1',
          caller: CrisisCallerType.ultraLeader,
          callerName: 'P',
          callerTitle: 'T',
          callerAvatar: '📢',
          dialogQuote: 'D',
          choices: [],
        ),
      );
      expect(withCrisis.activeCrisisCall, isNotNull);

      final cleared = withCrisis.copyWith(clearCrisisCall: true);
      expect(cleared.activeCrisisCall, isNull);
    });

    test('Criterion #18: Sacking triggers when board trust reaches 0', () {
      final initial = SaveRepository.createNewGame();
      final badMeters = initial.userClub.meters.applyDeltas(
        deltaBoardTrust: -100,
      ).onMatchCompleted();

      expect(badMeters.isSacked, isTrue);
      expect(badMeters.boardTrust, equals(0));
    });
  });
}
