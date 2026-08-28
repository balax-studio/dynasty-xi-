// domain/scouting/scouting_mission.dart
// Asynchronous Scouting Expeditions, Progress Tracking, and Attribute Fog of War

import '../entities/player.dart';

enum ScoutDurationTier {
  quick(1, 'Hızlı Tarama (1 Maç)', 5000),
  standard(2, 'Standart İnceleme (2 Maç)', 10000),
  deep(3, 'Kapsamlı Rapor (3 Maç)', 20000);

  final int matchDuration;
  final String label;
  final int cost;

  const ScoutDurationTier(this.matchDuration, this.label, this.cost);
}

class ScoutingMission {
  final String id;
  final String region;
  final ScoutDurationTier tier;
  final int totalMatches;
  final int matchesRemaining;
  final int assignedScoutLevel; // 1 to 5
  final List<Player> discoveredProspects;
  final bool isCompleted;

  const ScoutingMission({
    required this.id,
    required this.region,
    required this.tier,
    required this.totalMatches,
    required this.matchesRemaining,
    required this.assignedScoutLevel,
    required this.discoveredProspects,
    this.isCompleted = false,
  });

  double get progressRatio {
    if (totalMatches <= 0) return 1.0;
    final completedMatches = totalMatches - matchesRemaining;
    return (completedMatches / totalMatches).clamp(0.0, 1.0);
  }

  /// Advances mission duration by 1 match
  ScoutingMission tickMatch() {
    if (isCompleted) return this;
    final nextRemaining = matchesRemaining - 1;
    final completed = nextRemaining <= 0;

    return ScoutingMission(
      id: id,
      region: region,
      tier: tier,
      totalMatches: totalMatches,
      matchesRemaining: nextRemaining.clamp(0, totalMatches),
      assignedScoutLevel: assignedScoutLevel,
      discoveredProspects: discoveredProspects,
      isCompleted: completed,
    );
  }

  ScoutingMission copyWith({
    String? id,
    String? region,
    ScoutDurationTier? tier,
    int? totalMatches,
    int? matchesRemaining,
    int? assignedScoutLevel,
    List<Player>? discoveredProspects,
    bool? isCompleted,
  }) {
    return ScoutingMission(
      id: id ?? this.id,
      region: region ?? this.region,
      tier: tier ?? this.tier,
      totalMatches: totalMatches ?? this.totalMatches,
      matchesRemaining: matchesRemaining ?? this.matchesRemaining,
      assignedScoutLevel: assignedScoutLevel ?? this.assignedScoutLevel,
      discoveredProspects: discoveredProspects ?? this.discoveredProspects,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'region': region,
        'tier': tier.name,
        'totalMatches': totalMatches,
        'matchesRemaining': matchesRemaining,
        'assignedScoutLevel': assignedScoutLevel,
        'discoveredProspects': discoveredProspects.map((p) => p.toJson()).toList(),
        'isCompleted': isCompleted,
      };

  factory ScoutingMission.fromJson(Map<String, dynamic> json) {
    final tierName = json['tier'] as String?;
    final tier = ScoutDurationTier.values.firstWhere(
      (t) => t.name == tierName,
      orElse: () => ScoutDurationTier.standard,
    );

    final rawPlayers = json['discoveredProspects'] as List<dynamic>? ?? [];
    final players = rawPlayers.map((p) => Player.fromJson(p as Map<String, dynamic>)).toList();

    return ScoutingMission(
      id: json['id'] as String,
      region: json['region'] as String,
      tier: tier,
      totalMatches: json['totalMatches'] as int? ?? tier.matchDuration,
      matchesRemaining: json['matchesRemaining'] as int? ?? 0,
      assignedScoutLevel: json['assignedScoutLevel'] as int? ?? 1,
      discoveredProspects: players,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class ScoutFogOfWar {
  /// Returns OVR display string based on scout level (Range or exact value)
  static String getOvrDisplay(Player player, int scoutLevel) {
    if (scoutLevel >= 5) {
      return '${player.overall}';
    }
    final margin = (6 - scoutLevel); // Level 1: ±5, Level 4: ±2
    final minVal = (player.overall - margin).clamp(40, 99);
    final maxVal = (player.overall + margin).clamp(40, 99);
    return '$minVal - $maxVal';
  }

  /// Returns potential display string based on scout level
  static String getPotentialDisplay(Player player, int scoutLevel) {
    if (scoutLevel >= 5) {
      return '${player.potential}';
    }
    final margin = (6 - scoutLevel);
    final minVal = (player.potential - margin).clamp(50, 99);
    final maxVal = (player.potential + margin).clamp(50, 99);
    return '$minVal - $maxVal';
  }

  /// Checks if hidden personality/injury traits are revealed
  static bool isTraitRevealed({required int scoutLevel}) {
    return scoutLevel >= 3;
  }
}
