// domain/entities/meter.dart
// Pure Dart. 4 core meters (Cash, Fans, Locker Room, Board Trust) + thresholds and sacking logic.

class ClubMeters {
  static const int warningThreshold = 30;
  static const int criticalThreshold = 15;
  static const int graceMatchesAllowed = 3;

  final int cash; // Kasa (₣)
  final int fans; // Taraftar (0 - 100)
  final int lockerRoom; // Soyunma Odası (0 - 100)
  final int boardTrust; // Yönetim Güveni (0 - 100)
  final int consecutiveCriticalMatches; // Sacking grace counter
  final bool isSacked;

  const ClubMeters({
    this.cash = 25000,
    this.fans = 40,
    this.lockerRoom = 35,
    this.boardTrust = 50,
    this.consecutiveCriticalMatches = 0,
    this.isSacked = false,
  });

  bool get isBoardWarning => boardTrust <= warningThreshold;
  bool get isBoardCritical => boardTrust <= criticalThreshold;
  bool get isFansCritical => fans <= criticalThreshold;
  bool get isLockerRoomCritical => lockerRoom <= criticalThreshold;
  bool get isCashDebt => cash < 0;

  /// Apply delta changes to meters
  ClubMeters applyDeltas({
    int deltaCash = 0,
    int deltaFans = 0,
    int deltaLockerRoom = 0,
    int deltaBoardTrust = 0,
  }) {
    final nextCash = cash + deltaCash;
    final nextFans = (fans + deltaFans).clamp(0, 100);
    final nextLockerRoom = (lockerRoom + deltaLockerRoom).clamp(0, 100);
    final nextBoardTrust = (boardTrust + deltaBoardTrust).clamp(0, 100);
    final nextIsSacked = nextBoardTrust <= 0 || consecutiveCriticalMatches > graceMatchesAllowed;

    return ClubMeters(
      cash: nextCash,
      fans: nextFans,
      lockerRoom: nextLockerRoom,
      boardTrust: nextBoardTrust,
      consecutiveCriticalMatches: consecutiveCriticalMatches,
      isSacked: nextIsSacked,
    );
  }

  /// Evaluates consecutive critical match streak after a fixture is played
  ClubMeters onMatchCompleted() {
    final isCritical = boardTrust <= criticalThreshold;
    final nextConsecutive = isCritical ? consecutiveCriticalMatches + 1 : 0;
    final nextIsSacked = boardTrust <= 0 || nextConsecutive > graceMatchesAllowed;

    return copyWith(
      consecutiveCriticalMatches: nextConsecutive,
      isSacked: nextIsSacked,
    );
  }

  ClubMeters copyWith({
    int? cash,
    int? fans,
    int? lockerRoom,
    int? boardTrust,
    int? consecutiveCriticalMatches,
    bool? isSacked,
  }) {
    return ClubMeters(
      cash: cash ?? this.cash,
      fans: fans ?? this.fans,
      lockerRoom: lockerRoom ?? this.lockerRoom,
      boardTrust: boardTrust ?? this.boardTrust,
      consecutiveCriticalMatches: consecutiveCriticalMatches ?? this.consecutiveCriticalMatches,
      isSacked: isSacked ?? this.isSacked,
    );
  }

  Map<String, dynamic> toJson() => {
        'cash': cash,
        'fans': fans,
        'lockerRoom': lockerRoom,
        'boardTrust': boardTrust,
        'consecutiveCriticalMatches': consecutiveCriticalMatches,
        'isSacked': isSacked,
      };

  factory ClubMeters.fromJson(Map<String, dynamic> json) => ClubMeters(
        cash: json['cash'] as int? ?? 25000,
        fans: json['fans'] as int? ?? 40,
        lockerRoom: json['lockerRoom'] as int? ?? 35,
        boardTrust: json['boardTrust'] as int? ?? 50,
        consecutiveCriticalMatches: json['consecutiveCriticalMatches'] as int? ?? 0,
        isSacked: json['isSacked'] as bool? ?? false,
      );
}
