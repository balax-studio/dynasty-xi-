// domain/tactics/opposition_scout.dart
// Pre-Match Tactical Opposition Scouting and Weakness Analysis Report (§13.4, §11.2)

import '../entities/club.dart';
import '../../core/rng/deterministic_rng.dart';

class OppositionScoutReport {
  final String opponentClubName;
  final String opponentBadge;
  final String dominantFormation;
  final String tacticalStyle;
  final String primaryWeakness;
  final String keyThreatPlayerName;
  final int keyThreatOvr;
  final String recommendedCounterTactic;
  final double setPieceVulnerability; // 0.0 to 1.0
  final double flankVulnerability; // 0.0 to 1.0

  const OppositionScoutReport({
    required this.opponentClubName,
    required this.opponentBadge,
    required this.dominantFormation,
    required this.tacticalStyle,
    required this.primaryWeakness,
    required this.keyThreatPlayerName,
    required this.keyThreatOvr,
    required this.recommendedCounterTactic,
    required this.setPieceVulnerability,
    required this.flankVulnerability,
  });

  factory OppositionScoutReport.generate({
    required Club opponent,
    int scoutFacilityLevel = 1,
    int seed = 88,
  }) {
    final rng = DeterministicRng(seed);

    final formations = ['4-3-3', '4-4-2', '3-5-2', '4-2-3-1', '5-3-2'];
    final styles = ['Gegenpressing', 'Tiki-Taka', 'Kontra Atak', 'Otobüsü Çek (Katı Savunma)', 'Doğrudan Kanat Hücumu'];
    final weaknesses = [
      'Sağ bek arkasında geniş koridorlar bırakıyorlar.',
      'Defansif duran toplarda adam adama markaj hatası yapıyorlar.',
      'Merkez orta sahada baskı yediklerinde top kaybı oranları çok yüksek.',
      'Kalecileri uzaktan çekilen şutlarda top sektiriyor.',
      'Yüksek hat oynadıkları için derinlemesine paslara karşı çok savunmasızlar.'
    ];

    final formIdx = rng.nextInt(formations.length);
    final styleIdx = rng.nextInt(styles.length);
    final weakIdx = rng.nextInt(weaknesses.length);

    final starPlayer = opponent.squad.isNotEmpty
        ? (List.from(opponent.squad)..sort((a, b) => b.overallRating.compareTo(a.overallRating))).first
        : null;

    final threatName = starPlayer?.name ?? 'Star Forvet';
    final threatOvr = starPlayer?.overallRating ?? 75;

    final counter = styleIdx == 0
        ? 'Genişletilmiş Kontra Atak & Hızlı Çıkış'
        : (styleIdx == 1 ? 'Merkez Kapanma & Sert Müdahale' : 'Sabırlı Topa Sahip Olma & Kanat Bindirmeleri');

    return OppositionScoutReport(
      opponentClubName: opponent.name,
      opponentBadge: opponent.badgeIcon,
      dominantFormation: formations[formIdx],
      tacticalStyle: styles[styleIdx],
      primaryWeakness: weaknesses[weakIdx],
      keyThreatPlayerName: threatName,
      keyThreatOvr: threatOvr,
      recommendedCounterTactic: counter,
      setPieceVulnerability: 0.2 + rng.nextInt(60) / 100.0,
      flankVulnerability: 0.3 + rng.nextInt(50) / 100.0,
    );
  }
}
