// domain/entities/card.dart
// Pure Dart. Decision Card entity with options, meter deltas, prerequisites and story chain hooks.

enum CardCategory {
  board('Yönetim', '🏛️'),
  press('Basın', '🎙️'),
  fans('Taraftar', '📢'),
  lockerRoom('Soyunma Odası', '👕'),
  squad('Kadro', '⚽'),
  medical('Sağlık & Tıp', '🏥'),
  transfer('Transfer & Menajer', '💼'),
  scouting('Scout', '🔍'),
  finance('Finans', '💰'),
  youth('Gençlik & Altyapı', '🌱'),
  sponsor('Sponsorluk', '🤝'),
  personal('Kişisel', '⭐'),
  crisis('Kriz', '⚠️');

  final String label;
  final String icon;

  const CardCategory(this.label, this.icon);
}

class CardOption {
  final String id;
  final String text;
  final String resultText;
  final int deltaCash;
  final int deltaFans;
  final int deltaLockerRoom;
  final int deltaBoardTrust;
  final String? requiredPerkId;
  final String? nextChainCardId;
  final int chainDelayHours;

  const CardOption({
    required this.id,
    required this.text,
    required this.resultText,
    this.deltaCash = 0,
    this.deltaFans = 0,
    this.deltaLockerRoom = 0,
    this.deltaBoardTrust = 0,
    this.requiredPerkId,
    this.nextChainCardId,
    this.chainDelayHours = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'resultText': resultText,
        'deltaCash': deltaCash,
        'deltaFans': deltaFans,
        'deltaLockerRoom': deltaLockerRoom,
        'deltaBoardTrust': deltaBoardTrust,
        'requiredPerkId': requiredPerkId,
        'nextChainCardId': nextChainCardId,
        'chainDelayHours': chainDelayHours,
      };

  factory CardOption.fromJson(Map<String, dynamic> json) => CardOption(
        id: json['id'] as String,
        text: json['text'] as String,
        resultText: json['resultText'] as String? ?? '',
        deltaCash: json['deltaCash'] as int? ?? 0,
        deltaFans: json['deltaFans'] as int? ?? 0,
        deltaLockerRoom: json['deltaLockerRoom'] as int? ?? 0,
        deltaBoardTrust: json['deltaBoardTrust'] as int? ?? 0,
        requiredPerkId: json['requiredPerkId'] as String?,
        nextChainCardId: json['nextChainCardId'] as String?,
        chainDelayHours: json['chainDelayHours'] as int? ?? 0,
      );
}

class DecisionCard {
  final String id;
  final String characterName;
  final String characterRole;
  final String characterAvatar; // Icon or avatar code
  final String headline;
  final String storyText;
  final CardCategory category;
  final List<CardOption> options;
  final int minTier;
  final int maxTier;
  final String? chainId;
  final String? chainArcId;
  final int? chainStep;
  final int cooldownMatches;

  const DecisionCard({
    required this.id,
    required this.characterName,
    required this.characterRole,
    required this.characterAvatar,
    required this.headline,
    required this.storyText,
    required this.category,
    required this.options,
    this.minTier = 1,
    this.maxTier = 20,
    this.chainId,
    this.chainArcId,
    this.chainStep,
    this.cooldownMatches = 5,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'characterName': characterName,
        'characterRole': characterRole,
        'characterAvatar': characterAvatar,
        'headline': headline,
        'storyText': storyText,
        'category': category.name,
        'options': options.map((o) => o.toJson()).toList(),
        'minTier': minTier,
        'maxTier': maxTier,
        'chainId': chainId,
        'chainArcId': chainArcId,
        'chainStep': chainStep,
        'cooldownMatches': cooldownMatches,
      };

  factory DecisionCard.fromJson(Map<String, dynamic> json) => DecisionCard(
        id: json['id'] as String,
        characterName: json['characterName'] as String,
        characterRole: json['characterRole'] as String,
        characterAvatar: json['characterAvatar'] as String? ?? '👤',
        headline: json['headline'] as String,
        storyText: json['storyText'] as String,
        category: CardCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => CardCategory.board,
        ),
        options: (json['options'] as List<dynamic>)
            .map((o) => CardOption.fromJson(o as Map<String, dynamic>))
            .toList(),
        minTier: json['minTier'] as int? ?? 1,
        maxTier: json['maxTier'] as int? ?? 20,
        chainId: json['chainId'] as String?,
        chainArcId: json['chainArcId'] as String?,
        chainStep: json['chainStep'] as int?,
        cooldownMatches: json['cooldownMatches'] as int? ?? 5,
      );
}
