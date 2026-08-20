// domain/liveops/season_theme.dart
// Weekly Season Thematic Modifiers & Event Buffs (§28.2)

enum SeasonThemeType {
  youthFever('Gençlik Aşısı', 'Akademi oyuncularının antrenman gelişimine +%30 bonus.', '⭐', 1.3, 1.0),
  goalFest('Gol Festivali', 'Tüm maçlarda xG ve hücum şansları +%20 artar.', '🔥', 1.0, 1.2),
  ironDefense('Çelik Savunma', 'Defansif bloklar daha sağlam; kalesinde gol görmeme primi 2 katına çıkar.', '🛡️', 1.0, 0.85),
  derbyHeat('Derbi Ateşi', 'Taraftar memnuniyeti ve bilet hasılatı +%25 yükselir.', '⚡', 1.0, 1.0);

  final String title;
  final String description;
  final String icon;
  final double youthGrowthMultiplier;
  final double xgMultiplier;

  const SeasonThemeType(
    this.title,
    this.description,
    this.icon,
    this.youthGrowthMultiplier,
    this.xgMultiplier,
  );
}

class SeasonThemeService {
  static SeasonThemeType getThemeForMatchday(int matchday) {
    final idx = ((matchday - 1) ~/ 5) % SeasonThemeType.values.length;
    return SeasonThemeType.values[idx];
  }
}
