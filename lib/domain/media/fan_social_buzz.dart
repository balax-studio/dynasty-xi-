// domain/media/fan_social_buzz.dart
// Procedural fan social media commentary feed (§16.2)

class FanTweet {
  final String authorName;
  final String handle;
  final String avatarIcon;
  final String content;
  final int likes;
  final int retweets;

  const FanTweet({
    required this.authorName,
    required this.handle,
    required this.avatarIcon,
    required this.content,
    required this.likes,
    required this.retweets,
  });
}

class FanSocialBuzzGenerator {
  static List<String> generateFanBuzz({
    required String userClubName,
    required int userGoals,
    required int oppGoals,
    required String opponentName,
    String? motmName,
  }) {
    if (userGoals > oppGoals) {
      return [
        '[FORM] İşte futbol bu! $userClubName sahada resital sundu! $userGoals-$oppGoals',
        if (motmName != null) 'STAR $motmName bu ligin çok üzerinde bir topçu, helal olsun sana çocuk!',
        'Harika taktik, harika mücadele! Bu takım şampiyon olacak!',
        'Hafta sonum güzelleşti resmen. Yürü be $userClubName!',
      ];
    } else if (userGoals < oppGoals) {
      return [
        ' Böyle bir futbol olamaz! $userClubName acilen toparlanmalı.',
        'Defanstaki hatalar saç baş yoldurdu. $opponentName hak etti kazandı.',
        'Yönetim ve teknik heyet bu maçı iyi analiz etsin, sabrımız tükeniyor.',
      ];
    } else {
      return [
        '[ANLASMA] 1 puan fena değil ama $opponentName karşısında galibiyet kaçtı.',
        'Ortada bir maç oldu. Önümüzdeki haftaya bakacağız artık.',
      ];
    }
  }

  static List<FanTweet> generateFanTweets({
    required String userClubName,
    required int userGoals,
    required int oppGoals,
    required String opponentName,
    String? motmName,
  }) {
    final buzz = generateFanBuzz(
      userClubName: userClubName,
      userGoals: userGoals,
      oppGoals: oppGoals,
      opponentName: opponentName,
      motmName: motmName,
    );

    final authors = [
      (name: 'Arma Sevdalısı', handle: '@tribunsesi', icon: ''),
      (name: 'Taktik Masası', handle: '@taktikanaliz', icon: '[RAPOR]'),
      (name: 'Semt Çocuğu', handle: '@semt_cocugu', icon: '[GOL]'),
      (name: 'Büyük Başkan', handle: '@baskan_fan', icon: '[VIP]'),
    ];

    return List.generate(buzz.length, (i) {
      final author = authors[i % authors.length];
      return FanTweet(
        authorName: author.name,
        handle: author.handle,
        avatarIcon: author.icon,
        content: buzz[i],
        likes: (i + 1) * 342,
        retweets: (i + 1) * 78,
      );
    });
  }
}
