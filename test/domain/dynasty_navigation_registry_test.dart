// test/domain/dynasty_navigation_registry_test.dart
// Unit tests for DynastyNavigationRegistry, shortcut filtering, and badge evaluation.

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/manager.dart';
import 'package:futbol/domain/navigation/dynasty_navigation_registry.dart';

void main() {
  group('DynastyNavigationRegistry Tests', () {
    late GameState testState;

    setUp(() {
      testState = GameState(
        userClub: Club(
          id: 'test_club',
          name: 'Ankara Gücü',
          city: 'Ankara',
          meters: const ClubMeters(cash: 10000, fans: 50, lockerRoom: 50, boardTrust: 30),
        ),
        manager: const Manager(name: 'Test Manager'),
        headCoach: null,
      );
    });

    test('All 19 shortcuts are registered and valid', () {
      expect(DynastyNavigationRegistry.allShortcuts.length, 19);
      for (final shortcut in DynastyNavigationRegistry.allShortcuts) {
        expect(shortcut.id.isNotEmpty, isTrue);
        expect(shortcut.label.isNotEmpty, isTrue);
        expect(shortcut.icon.isNotEmpty, isTrue);
      }
    });

    test('getById returns valid definition or null', () {
      final headCoach = DynastyNavigationRegistry.getById('head_coach');
      expect(headCoach, isNotNull);
      expect(headCoach!.label, contains('TEKNİK DİREKTÖR'));

      final nonExistent = DynastyNavigationRegistry.getById('non_existent');
      expect(nonExistent, isNull);
    });

    test('getShortcutsByIds preserves order and filters valid items', () {
      final requestedIds = ['facilities', 'trophy_room', 'invalid_id', 'press_conference'];
      final shortcuts = DynastyNavigationRegistry.getShortcutsByIds(requestedIds);

      expect(shortcuts.length, 3);
      expect(shortcuts[0].id, 'facilities');
      expect(shortcuts[1].id, 'trophy_room');
      expect(shortcuts[2].id, 'press_conference');
    });

    test('badgeEvaluator dynamically generates badges based on GameState', () {
      final headCoach = DynastyNavigationRegistry.getById('head_coach')!;
      expect(headCoach.badgeEvaluator?.call(testState), 'ATAMA YAP');

      final boardroom = DynastyNavigationRegistry.getById('boardroom_summit')!;
      // boardTrust is 30 (< 40)
      expect(boardroom.badgeEvaluator?.call(testState), 'KRİTİK');

      final finance = DynastyNavigationRegistry.getById('finance')!;
      // cash is 10000 (< 15000)
      expect(finance.badgeEvaluator?.call(testState), '⚠️ NAKİT');
    });

    test('Default shortcuts list contains valid registered items', () {
      final defaultList = DynastyNavigationRegistry.getShortcutsByIds(
        DynastyNavigationRegistry.defaultShortcutIds,
      );
      expect(defaultList.length, DynastyNavigationRegistry.defaultShortcutIds.length);
    });
  });
}
