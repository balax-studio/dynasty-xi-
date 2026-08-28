// domain/sim/match_events.dart
// Pure Dart. Events produced by the 90-minute match simulation engine.

enum MatchEventType {
  whistleStart,
  goal,
  shotSaved,
  shotOffTarget,
  foul,
  yellowCard,
  redCard,
  injury,
  substitution,
  keyMoment,
  halfTime,
  halfTimeTalk,
  fullTime;

  String get icon {
    switch (this) {
      case MatchEventType.whistleStart:
        return '[DUYURU]';
      case MatchEventType.goal:
        return '[GOL]';
      case MatchEventType.shotSaved:
        return '';
      case MatchEventType.shotOffTarget:
        return '';
      case MatchEventType.foul:
        return '[UYARI]';
      case MatchEventType.yellowCard:
        return '';
      case MatchEventType.redCard:
        return '';
      case MatchEventType.injury:
        return '[SAĞLIK]';
      case MatchEventType.substitution:
        return '';
      case MatchEventType.keyMoment:
        return 'BOLT';
      case MatchEventType.halfTime:
        return '';
      case MatchEventType.halfTimeTalk:
        return '';
      case MatchEventType.fullTime:
        return '';
    }
  }
}

class LiveDecisionOption {
  final String id;
  final String label;
  final String description;
  final double boostXg;
  final double riskCounterXg;

  const LiveDecisionOption({
    required this.id,
    required this.label,
    required this.description,
    this.boostXg = 0.0,
    this.riskCounterXg = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'description': description,
        'boostXg': boostXg,
        'riskCounterXg': riskCounterXg,
      };

  factory LiveDecisionOption.fromJson(Map<String, dynamic> json) => LiveDecisionOption(
        id: json['id'] as String,
        label: json['label'] as String,
        description: json['description'] as String,
        boostXg: (json['boostXg'] as num?)?.toDouble() ?? 0.0,
        riskCounterXg: (json['riskCounterXg'] as num?)?.toDouble() ?? 0.0,
      );
}

class MatchEvent {
  final int minute;
  final MatchEventType type;
  final String description;
  final String? primaryPlayerName;
  final String? secondaryPlayerName;
  final bool isHomeTeam;
  final int scoreHome;
  final int scoreAway;
  final List<LiveDecisionOption> liveOptions;

  List<LiveDecisionOption>? get decisionOptions => liveOptions.isEmpty ? null : liveOptions;

  const MatchEvent({
    required this.minute,
    required this.type,
    required this.description,
    this.primaryPlayerName,
    this.secondaryPlayerName,
    this.isHomeTeam = true,
    this.scoreHome = 0,
    this.scoreAway = 0,
    this.liveOptions = const [],
  });

  bool get isGoal => type == MatchEventType.goal;
  bool get isKeyMoment => type == MatchEventType.keyMoment;

  Map<String, dynamic> toJson() => {
        'minute': minute,
        'type': type.name,
        'description': description,
        'primaryPlayerName': primaryPlayerName,
        'secondaryPlayerName': secondaryPlayerName,
        'isHomeTeam': isHomeTeam,
        'scoreHome': scoreHome,
        'scoreAway': scoreAway,
        'liveOptions': liveOptions.map((o) => o.toJson()).toList(),
      };

  factory MatchEvent.fromJson(Map<String, dynamic> json) => MatchEvent(
        minute: json['minute'] as int,
        type: MatchEventType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => MatchEventType.foul,
        ),
        description: json['description'] as String,
        primaryPlayerName: json['primaryPlayerName'] as String?,
        secondaryPlayerName: json['secondaryPlayerName'] as String?,
        isHomeTeam: json['isHomeTeam'] as bool? ?? true,
        scoreHome: json['scoreHome'] as int? ?? 0,
        scoreAway: json['scoreAway'] as int? ?? 0,
        liveOptions: (json['liveOptions'] as List<dynamic>?)
                ?.map((o) => LiveDecisionOption.fromJson(o as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

class MatchGoalEvent {
  final int minute;
  final String? scorerName;
  final String? scorerId;
  final String? assistantName;
  final String? assistantId;
  final bool isHome;

  const MatchGoalEvent({
    required this.minute,
    this.scorerName,
    this.scorerId,
    this.assistantName,
    this.assistantId,
    this.isHome = true,
  });
}

