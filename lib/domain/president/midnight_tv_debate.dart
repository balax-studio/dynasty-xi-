// domain/president/midnight_tv_debate.dart
// Late-Night Live Sports TV Debates (Gece 02:00 Canlı Yayın Düellosu)

class TvDebateTopic {
  final String id;
  final String showName;
  final String punditName;
  final String accusation;
  final List<TvDebateChoice> choices;

  const TvDebateTopic({
    required this.id,
    required this.showName,
    required this.punditName,
    required this.accusation,
    required this.choices,
  });

  static List<TvDebateTopic> getAvailableDebates() {
    return [
      const TvDebateTopic(
        id: 'ref_conspiracy',
        showName: 'BEYAZ DERBİ GECE YARISI',
        punditName: 'Ahmet Çakar / Sinan Engin',
        accusation: 'Hafta sonu oynanan maçta hakem açıkça sizin takımınızı korudu! TFF ile gizli görüşmeler yaptığınız iddia ediliyor!',
        choices: [
          TvDebateChoice(
            title: 'CANLI YAYINA TELEFONLA BAĞLAN & MASAYA VUR',
            dialogue: '"Sen kimsin de benim şerefli kulübümü töhmet altında bırakıyorsun! Belgen varsa açıkla, yoksa yarın mahkemedeyiz!"',
            fansDelta: 10,
            boardDelta: -4,
            cashDelta: -15000, // TFF Ceza riski
            ratingScore: 9.8,
            outcomeText: 'Sosyal medya yıkıldı! Taraftarlar başkanın dik duruşunu ayakta alkışladı. TFF ₣15.000 para cezası kesti.',
          ),
          TvDebateChoice(
            title: 'VİDEOLU KANITLARLA SAKİN VE DİPLOMATİK AÇIKLAMA',
            dialogue: '"Pozisyon pozisyon VAR kayıtlarını inceledik. Aleyhimize verilen 3 haksız kararı kamuoyunun takdirine sunuyoruz."',
            fansDelta: 4,
            boardDelta: 8,
            cashDelta: 0,
            ratingScore: 7.2,
            outcomeText: 'Aklıselim futbol yorumcuları başkanın soğukkanlı ve belgeli açıklamasını takdir etti.',
          ),
          TvDebateChoice(
            title: 'YAYINI KINAYIP REKLAM VEREN SPONSORLARI GERİ ÇEK',
            dialogue: '"Bu reyting uğruna yapılan bir linç operasyonudur. Kanalınızdaki tüm kulüp reklamlarımızı donduruyoruz."',
            fansDelta: 6,
            boardDelta: 5,
            cashDelta: -10000,
            ratingScore: 8.5,
            outcomeText: 'Kanal yönetimi geri adım attı ve programda özür metni yayınladı.',
          ),
        ],
      ),
      const TvDebateTopic(
        id: 'transfer_bubble',
        showName: 'FUTBOL ARENASI ÖZEL',
        punditName: 'Erman Toroğlu',
        accusation: 'Yaptığınız 10 milyonluk forvet transferi tam bir fiyasko çıktı! Menajerlerle ne tür rantlar döndü?',
        choices: [
          TvDebateChoice(
            title: 'HODRİ MEYDAN: STÜDYOYA BİZZAT BASKIN YAP',
            dialogue: '"Gelin stüdyoya geliyorum! Yüzüme söyleyin ne biliyorsanız! Canlı yayında hesaplaşacağız!"',
            fansDelta: 12,
            boardDelta: -6,
            cashDelta: -25000,
            ratingScore: 10.0,
            outcomeText: 'Reyting rekorları kırıldı! Gece 03:00\'te stüdyo önünde yüzlerce taraftar meşale yaktı.',
          ),
          TvDebateChoice(
            title: 'İSTATİSTİKLER VE SCOUT ANALİZİ İLE CEVAP VER',
            dialogue: '"Oyuncumuz ligin en çok mesafe kat eden ismi. Zamana ve adaptasyona ihtiyacı var."',
            fansDelta: 2,
            boardDelta: 6,
            cashDelta: 0,
            ratingScore: 6.0,
            outcomeText: 'Taraftarlar açıklamayı sıkıcı bulsa da yönetim kurulunda güven tazelendi.',
          ),
        ],
      ),
    ];
  }
}

class TvDebateChoice {
  final String title;
  final String dialogue;
  final int fansDelta;
  final int boardDelta;
  final int cashDelta;
  final double ratingScore;
  final String outcomeText;

  const TvDebateChoice({
    required this.title,
    required this.dialogue,
    required this.fansDelta,
    required this.boardDelta,
    required this.cashDelta,
    required this.ratingScore,
    required this.outcomeText,
  });
}
