// domain/media/press_conference.dart
// Post-Match & Pre-Match Press Conferences with 3 Stances (§16)

enum PressStance {
  diplomatic('Diplomatik & Ölçülü', '[BASIN]'),
  aggressive('İddialı & Meydan Okuyan', '[FORM]'),
  protective('Oyuncuları Koruyan & Destekleyici', 'SHIELD');

  final String label;
  final String icon;

  const PressStance(this.label, this.icon);
}

class PressOption {
  final String text;
  final PressStance stance;
  final int fanImpact;
  final int boardImpact;
  final int lockerImpact;

  const PressOption({
    required this.text,
    required this.stance,
    this.fanImpact = 0,
    this.boardImpact = 0,
    this.lockerImpact = 0,
  });
}

class PressConference {
  final String reporterName;
  final String mediaOutlet;
  final String question;
  final List<PressOption> options;

  const PressConference({
    required this.reporterName,
    required this.mediaOutlet,
    required this.question,
    required this.options,
  });
}

class PressConferenceGenerator {
  static PressConference generatePostMatchConference({
    required int userGoals,
    required int oppGoals,
    required String opponentName,
  }) {
    if (userGoals > oppGoals) {
      // Galibiyet Sonrası Soru
      return PressConference(
        reporterName: 'Mehmet Demirkol',
        mediaOutlet: 'Futbol Meydanı TV',
        question:
            'Tebrikler Başkanım/Hocam! $opponentName karşısında $userGoals-$oppGoals gibi net bir skor aldınız. Takımınızın bu form grafiği şampiyonluk için yeterli mi?',
        options: [
          const PressOption(
            text: 'Ayaklarımız yere basmalı. Sadece bir maç kazandık, önümüzdeki haftalara odaklanıyoruz.',
            stance: PressStance.diplomatic,
            fanImpact: 3,
            boardImpact: 5,
            lockerImpact: 2,
          ),
          const PressOption(
            text: 'Biz bu lige damga vurmaya geldik! Bu futbolla önümüzde kimse duramaz!',
            stance: PressStance.aggressive,
            fanImpact: 10,
            boardImpact: -2,
            lockerImpact: 6,
          ),
          const PressOption(
            text: 'Bütün övgü sahada canını dişine takan futbolcularıma ait, onlarla gurur duyuyorum.',
            stance: PressStance.protective,
            fanImpact: 4,
            boardImpact: 2,
            lockerImpact: 10,
          ),
        ],
      );
    } else if (userGoals < oppGoals) {
      // Mağlubiyet Sonrası Soru
      return PressConference(
        reporterName: 'Uğur Karakullukçu',
        mediaOutlet: 'Tribün Gündemi',
        question:
            '$opponentName karşısında alınan $userGoals-$oppGoals skor taraftarda hayal kırıklığı yarattı. Bu mağlubiyetin sorumlusu kim?',
        options: [
          const PressOption(
            text: 'Hatalarımızdan ders çıkarıp antrenman sahamızda daha sıkı çalışacağız.',
            stance: PressStance.diplomatic,
            fanImpact: 1,
            boardImpact: 4,
            lockerImpact: 1,
          ),
          const PressOption(
            text: 'Hakem kararları ve şanssızlıklar olmasa sonuç çok farklı olurdu. Gelecek maç cevabımızı sahada vereceğiz!',
            stance: PressStance.aggressive,
            fanImpact: 8,
            boardImpact: -4,
            lockerImpact: 4,
          ),
          const PressOption(
            text: 'Sorumluluk tamamen benim. Oyuncularımın arkasındayım, ayağa kalkacağız.',
            stance: PressStance.protective,
            fanImpact: 2,
            boardImpact: -1,
            lockerImpact: 9,
          ),
        ],
      );
    } else {
      // Beraberlik Sonrası Soru
      return PressConference(
        reporterName: 'Attila Gökçe',
        mediaOutlet: 'Akşam Spor',
        question: '$opponentName maçı $userGoals-$oppGoals eşitlikle bitti. 1 puan kazanç mı yoksa kayıp mı?',
        options: [
          const PressOption(
            text: 'Zorlu bir deplasman/rakip karşısında alınan 1 puan lig maratonunda değerlidir.',
            stance: PressStance.diplomatic,
            fanImpact: 2,
            boardImpact: 3,
            lockerImpact: 2,
          ),
          const PressOption(
            text: 'Kazanmayı hak eden taraftık, galibiyet elimizden kaçtı.',
            stance: PressStance.aggressive,
            fanImpact: 5,
            boardImpact: 0,
            lockerImpact: 3,
          ),
          const PressOption(
            text: 'Oyuncularım ellerinden geleni yaptı, mücadelelerinden memnunum.',
            stance: PressStance.protective,
            fanImpact: 3,
            boardImpact: 2,
            lockerImpact: 7,
          ),
        ],
      );
    }
  }
}
