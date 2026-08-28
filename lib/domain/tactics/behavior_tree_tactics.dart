// domain/tactics/behavior_tree_tactics.dart
// Behavior Tree (Davranış Ağacı) Decision Engine for Tactical Player Choices

import '../entities/player.dart';

enum BehaviorStatus { success, failure, running }

enum TacticalActionType {
  shoot,
  throughBall,
  wingCross,
  dribblePast,
  retainPossession,
  tacticalFoul,
}

class TacticalContext {
  final Player actor;
  final double distanceToGoal;
  final int defendersInFront;
  final double passingLaneOpenness;
  final bool hasSupportRunner;
  final double matchMomentum;

  const TacticalContext({
    required this.actor,
    required this.distanceToGoal,
    required this.defendersInFront,
    required this.passingLaneOpenness,
    required this.hasSupportRunner,
    required this.matchMomentum,
  });
}

abstract class BehaviorNode {
  BehaviorStatus execute(TacticalContext context);
}

class ActionNode extends BehaviorNode {
  final TacticalActionType action;
  final bool Function(TacticalContext context) condition;

  ActionNode({required this.action, required this.condition});

  @override
  BehaviorStatus execute(TacticalContext context) {
    return condition(context) ? BehaviorStatus.success : BehaviorStatus.failure;
  }
}

class SelectorNode extends BehaviorNode {
  final List<BehaviorNode> children;
  SelectorNode(this.children);

  @override
  BehaviorStatus execute(TacticalContext context) {
    for (final child in children) {
      final status = child.execute(context);
      if (status == BehaviorStatus.success) return BehaviorStatus.success;
    }
    return BehaviorStatus.failure;
  }
}

class SequenceNode extends BehaviorNode {
  final List<BehaviorNode> children;
  SequenceNode(this.children);

  @override
  BehaviorStatus execute(TacticalContext context) {
    for (final child in children) {
      final status = child.execute(context);
      if (status != BehaviorStatus.success) return status;
    }
    return BehaviorStatus.success;
  }
}

/// Taktik Karar Motoru (Behavior Tree Implementation)
class TacticalBehaviorTree {
  static TacticalActionType evaluateBestAction(TacticalContext ctx) {
    // 1. Şut Seçeneği (Yakın mesafe ve açık açı)
    if (ctx.distanceToGoal <= 20.0 && ctx.defendersInFront <= 1 && ctx.actor.shooting >= 65) {
      return TacticalActionType.shoot;
    }

    // 2. Araya Kaçırma Pası (Through Ball)
    if (ctx.hasSupportRunner && ctx.passingLaneOpenness >= 0.65 && ctx.actor.passing >= 60) {
      return TacticalActionType.throughBall;
    }

    // 3. Kanat Ortası (Wing Cross)
    if (ctx.distanceToGoal <= 35.0 && (ctx.actor.position == Position.lw || ctx.actor.position == Position.rw || ctx.actor.position == Position.rb || ctx.actor.position == Position.lb)) {
      return TacticalActionType.wingCross;
    }

    // 4. Çalım / Dripling
    if (ctx.actor.technique >= 70 && ctx.defendersInFront <= 1) {
      return TacticalActionType.dribblePast;
    }

    // 5. Varsayılan: Topu Tut ve Güvenli Oyna
    return TacticalActionType.retainPossession;
  }
}
