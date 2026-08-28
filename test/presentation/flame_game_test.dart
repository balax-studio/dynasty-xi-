import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/sim/match_events.dart';
import 'package:futbol/presentation/flame/live_match_flame_game.dart';

Player createPlayer(String id, String lastName, Position pos) {
  return Player(
    id: id,
    firstName: 'Test',
    lastName: lastName,
    countryCode: 'TR',
    age: 24,
    position: pos,
    pace: 75,
    technique: 75,
    shooting: 75,
    passing: 75,
    defending: 75,
    physical: 75,
    mentality: 75,
    potential: 80,
    weeklyWage: 2000,
    fitness: 90,
  );
}

void main() {
  test('LiveMatchFlameGame initializes pitch, players, ball and ticks minutes', () async {
    final starters = [
      createPlayer('p1', 'Demirel', Position.gk),
      createPlayer('p2', 'Gönül', Position.rb),
      createPlayer('p3', 'Lugano', Position.cb),
      createPlayer('p4', 'Edu', Position.cb),
      createPlayer('p5', 'Carlos', Position.lb),
      createPlayer('p6', 'Aurelio', Position.dm),
      createPlayer('p7', 'Appiah', Position.cm),
      createPlayer('p8', 'Alex', Position.am),
      createPlayer('p9', 'Deivid', Position.rw),
      createPlayer('p10', 'Semih', Position.st),
      createPlayer('p11', 'Boral', Position.lw),
    ];

    final game = LiveMatchFlameGame(
      homePlayers: starters,
      awayPlayers: starters,
      homeFormation: '4-3-3',
      awayFormation: '4-3-3',
    );

    await game.onLoad();
    expect(game.children.isNotEmpty, isTrue);

    // Test minute tick
    game.onMinuteTick(10, [
      const MatchEvent(
        minute: 10,
        type: MatchEventType.shotSaved,
        description: 'Müthiş şut ve kurtarış!',
        isHomeTeam: true,
      ),
    ]);

    expect(game.currentMinute, equals(10));
    expect(game.lastEvent?.type, equals(MatchEventType.shotSaved));

    // Test goal celebration trigger
    game.onMinuteTick(25, [
      const MatchEvent(
        minute: 25,
        type: MatchEventType.goal,
        description: 'GOOOOOOL!',
        isHomeTeam: true,
      ),
    ]);

    expect(game.currentMinute, equals(25));
    expect(game.shakeIntensity, greaterThan(0));
  });
}
