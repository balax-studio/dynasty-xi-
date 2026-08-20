// domain/progression/museum_records.dart
// Club Museum & Historical Records tracker (§14.4)

class ClubMuseumRecords {
  final String biggestWinScore;
  final String biggestWinOpponent;
  final int unbeatenStreak;
  final String recordSigningName;
  final int recordSigningFee;
  final String recordSaleName;
  final int recordSaleFee;
  final String allTimeTopScorerName;
  final int allTimeTopScorerGoals;

  const ClubMuseumRecords({
    this.biggestWinScore = '0-0',
    this.biggestWinOpponent = '—',
    this.unbeatenStreak = 0,
    this.recordSigningName = '—',
    this.recordSigningFee = 0,
    this.recordSaleName = '—',
    this.recordSaleFee = 0,
    this.allTimeTopScorerName = '—',
    this.allTimeTopScorerGoals = 0,
  });

  ClubMuseumRecords checkAndRecordMatch({
    required int homeScore,
    required int awayScore,
    required String opponentName,
    required bool isWin,
  }) {
    final diff = homeScore - awayScore;
    var newBiggestWinScore = biggestWinScore;
    var newBiggestWinOpponent = biggestWinOpponent;

    if (isWin && diff > 0) {
      final currentMaxDiff = _parseScoreDiff(biggestWinScore);
      if (diff > currentMaxDiff) {
        newBiggestWinScore = '$homeScore-$awayScore';
        newBiggestWinOpponent = opponentName;
      }
    }

    return ClubMuseumRecords(
      biggestWinScore: newBiggestWinScore,
      biggestWinOpponent: newBiggestWinOpponent,
      unbeatenStreak: isWin ? unbeatenStreak + 1 : (homeScore == awayScore ? unbeatenStreak + 1 : 0),
      recordSigningName: recordSigningName,
      recordSigningFee: recordSigningFee,
      recordSaleName: recordSaleName,
      recordSaleFee: recordSaleFee,
      allTimeTopScorerName: allTimeTopScorerName,
      allTimeTopScorerGoals: allTimeTopScorerGoals,
    );
  }

  ClubMuseumRecords checkAndRecordTransfer({
    required String playerName,
    required int fee,
    required bool isIncoming,
  }) {
    if (isIncoming && fee > recordSigningFee) {
      return ClubMuseumRecords(
        biggestWinScore: biggestWinScore,
        biggestWinOpponent: biggestWinOpponent,
        unbeatenStreak: unbeatenStreak,
        recordSigningName: playerName,
        recordSigningFee: fee,
        recordSaleName: recordSaleName,
        recordSaleFee: recordSaleFee,
        allTimeTopScorerName: allTimeTopScorerName,
        allTimeTopScorerGoals: allTimeTopScorerGoals,
      );
    } else if (!isIncoming && fee > recordSaleFee) {
      return ClubMuseumRecords(
        biggestWinScore: biggestWinScore,
        biggestWinOpponent: biggestWinOpponent,
        unbeatenStreak: unbeatenStreak,
        recordSigningName: recordSigningName,
        recordSigningFee: recordSigningFee,
        recordSaleName: playerName,
        recordSaleFee: fee,
        allTimeTopScorerName: allTimeTopScorerName,
        allTimeTopScorerGoals: allTimeTopScorerGoals,
      );
    }
    return this;
  }

  int _parseScoreDiff(String score) {
    try {
      final parts = score.split('-');
      if (parts.length == 2) {
        return int.parse(parts[0].trim()) - int.parse(parts[1].trim());
      }
    } catch (_) {}
    return 0;
  }

  ClubMuseumRecords copyWith({
    String? biggestWinScore,
    String? biggestWinOpponent,
    int? unbeatenStreak,
    String? recordSigningName,
    int? recordSigningFee,
    String? recordSaleName,
    int? recordSaleFee,
    String? allTimeTopScorerName,
    int? allTimeTopScorerGoals,
  }) {
    return ClubMuseumRecords(
      biggestWinScore: biggestWinScore ?? this.biggestWinScore,
      biggestWinOpponent: biggestWinOpponent ?? this.biggestWinOpponent,
      unbeatenStreak: unbeatenStreak ?? this.unbeatenStreak,
      recordSigningName: recordSigningName ?? this.recordSigningName,
      recordSigningFee: recordSigningFee ?? this.recordSigningFee,
      recordSaleName: recordSaleName ?? this.recordSaleName,
      recordSaleFee: recordSaleFee ?? this.recordSaleFee,
      allTimeTopScorerName: allTimeTopScorerName ?? this.allTimeTopScorerName,
      allTimeTopScorerGoals: allTimeTopScorerGoals ?? this.allTimeTopScorerGoals,
    );
  }

  Map<String, dynamic> toJson() => {
        'biggestWinScore': biggestWinScore,
        'biggestWinOpponent': biggestWinOpponent,
        'unbeatenStreak': unbeatenStreak,
        'recordSigningName': recordSigningName,
        'recordSigningFee': recordSigningFee,
        'recordSaleName': recordSaleName,
        'recordSaleFee': recordSaleFee,
        'allTimeTopScorerName': allTimeTopScorerName,
        'allTimeTopScorerGoals': allTimeTopScorerGoals,
      };

  factory ClubMuseumRecords.fromJson(Map<String, dynamic> json) => ClubMuseumRecords(
        biggestWinScore: json['biggestWinScore'] as String? ?? '0-0',
        biggestWinOpponent: json['biggestWinOpponent'] as String? ?? '—',
        unbeatenStreak: json['unbeatenStreak'] as int? ?? 0,
        recordSigningName: json['recordSigningName'] as String? ?? '—',
        recordSigningFee: json['recordSigningFee'] as int? ?? 0,
        recordSaleName: json['recordSaleName'] as String? ?? '—',
        recordSaleFee: json['recordSaleFee'] as int? ?? 0,
        allTimeTopScorerName: json['allTimeTopScorerName'] as String? ?? '—',
        allTimeTopScorerGoals: json['allTimeTopScorerGoals'] as int? ?? 0,
      );
}
