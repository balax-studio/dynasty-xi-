// domain/entities/position_weights.dart
// Exact 7-attribute positional weight matrix for overall rating (OVR) calculation (§9.2).

import 'player.dart';

class PositionWeight {
  final double pace;
  final double technique;
  final double shooting;
  final double passing;
  final double defending;
  final double physical;
  final double mentality;

  const PositionWeight({
    required this.pace,
    required this.technique,
    required this.shooting,
    required this.passing,
    required this.defending,
    required this.physical,
    required this.mentality,
  });

  double get sum =>
      pace +
      technique +
      shooting +
      passing +
      defending +
      physical +
      mentality;

  int calculateOvr({
    required int pace,
    required int technique,
    required int shooting,
    required int passing,
    required int defending,
    required int physical,
    required int mentality,
  }) {
    final raw = (pace * this.pace) +
        (technique * this.technique) +
        (shooting * this.shooting) +
        (passing * this.passing) +
        (defending * this.defending) +
        (physical * this.physical) +
        (mentality * this.mentality);
    return raw.round().clamp(35, 99);
  }
}

const kPositionWeights = <Position, PositionWeight>{
  Position.gk: PositionWeight(
    pace: 0.05,
    technique: 0.15,
    shooting: 0.00,
    passing: 0.10,
    defending: 0.40,
    physical: 0.20,
    mentality: 0.10,
  ),
  Position.cb: PositionWeight(
    pace: 0.12,
    technique: 0.08,
    shooting: 0.00,
    passing: 0.08,
    defending: 0.38,
    physical: 0.22,
    mentality: 0.12,
  ),
  Position.lb: PositionWeight(
    pace: 0.18,
    technique: 0.12,
    shooting: 0.04,
    passing: 0.14,
    defending: 0.26,
    physical: 0.16,
    mentality: 0.10,
  ),
  Position.rb: PositionWeight(
    pace: 0.18,
    technique: 0.12,
    shooting: 0.04,
    passing: 0.14,
    defending: 0.26,
    physical: 0.16,
    mentality: 0.10,
  ),
  Position.dm: PositionWeight(
    pace: 0.08,
    technique: 0.12,
    shooting: 0.06,
    passing: 0.18,
    defending: 0.30,
    physical: 0.16,
    mentality: 0.10,
  ),
  Position.cm: PositionWeight(
    pace: 0.10,
    technique: 0.18,
    shooting: 0.10,
    passing: 0.24,
    defending: 0.16,
    physical: 0.12,
    mentality: 0.10,
  ),
  Position.am: PositionWeight(
    pace: 0.12,
    technique: 0.26,
    shooting: 0.18,
    passing: 0.24,
    defending: 0.04,
    physical: 0.06,
    mentality: 0.10,
  ),
  Position.lw: PositionWeight(
    pace: 0.28,
    technique: 0.22,
    shooting: 0.18,
    passing: 0.16,
    defending: 0.04,
    physical: 0.04,
    mentality: 0.08,
  ),
  Position.rw: PositionWeight(
    pace: 0.28,
    technique: 0.22,
    shooting: 0.18,
    passing: 0.16,
    defending: 0.04,
    physical: 0.04,
    mentality: 0.08,
  ),
  Position.st: PositionWeight(
    pace: 0.18,
    technique: 0.16,
    shooting: 0.34,
    passing: 0.08,
    defending: 0.02,
    physical: 0.14,
    mentality: 0.08,
  ),
};
