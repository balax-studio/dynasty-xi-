// domain/media/newspaper_story_engine.dart
// Rich Contextual Sports Newspaper & Media Narrative Generator (§17.5-1, §66)

import '../entities/game_state.dart';

class NewspaperStory {
  final String outletName;
  final String headline;
  final String subhead;
  final String reporter;
  final String columnQuote;
  final String dateString;
  final bool isPositive;

  const NewspaperStory({
    required this.outletName,
    required this.headline,
    required this.subhead,
    required this.reporter,
    required this.columnQuote,
    required this.dateString,
    required this.isPositive,
  });
}

class NewspaperStoryEngine {
  /// Kulübün ligdeki durumuna, son maçına, kasasına ve yaklaşan fikstüre göre
  /// zengin, atmosferik bir gazete kupürü üretir.
  static NewspaperStory generateStory(GameState state) {
    final club = state.userClub;
    final clock = state.clock;
    final matchday = clock.matchday;
    final season = clock.seasonNumber;
    final dateStr = 'HAFTA $matchday • SEZON $season';

    final fixtures = state.currentLeague.fixtures;
    final playedFixtures = fixtures.where((f) => f.isPlayed).toList();
    final nextFixture = fixtures.firstWhere(
      (f) => f.matchday == matchday && !f.isPlayed,
      orElse: () => fixtures.first,
    );

    final isUserHome = nextFixture.homeClubId == club.id;
    final oppId = isUserHome ? nextFixture.awayClubId : nextFixture.homeClubId;
    final oppName = state.currentLeague.getClubName(oppId);

    final cash = club.meters.cash;
    final boardTrust = club.meters.boardTrust;
    final fans = club.meters.fans;
    final lockerRoom = club.meters.lockerRoom;

    // 1. Mali Darboğaz / Kriz Haberi
    if (cash < 10000) {
      return NewspaperStory(
        outletName: 'EKONOMİ & SPOR KULİSLERİ',
        headline: '${club.name.toUpperCase()} KASASINDA KRİTİK SEVİYE!',
        subhead: 'Maliye ve denetleme kurullarının gözü kulüp hesaplarında. Başkanın acil kaynak yaratma planı spor kamuoyunun gündemine oturdu.',
        reporter: 'Mali Analist Hakan Kaya',
        columnQuote: '"Başkanın şahsi itibarı ve sıcak para yönetimi bu sezonun kaderini tayin edecek."',
        dateString: dateStr,
        isPositive: false,
      );
    }

    // 2. Yönetim Güvensizliği & Kongre Fısıltıları
    if (boardTrust < 35) {
      return NewspaperStory(
        outletName: 'KULİS MANŞET • ÖZEL HABER',
        headline: 'YÖNETİM KURULUNDA ÇATLAK DERİNLEŞİYOR!',
        subhead: 'Alınan istikrarsız sonuçlar ve güven kaybı sonrası muhalif divan üyelerinin olağanüstü genel kurul hazırlığı yaptığı iddia ediliyor.',
        reporter: 'Nihal Aksu (Kıdemli Muhabir)',
        columnQuote: '"Yönetim bu hafta sahada net bir cevap veremezse, kongre çanları çalmaya başlayabilir."',
        dateString: dateStr,
        isPositive: false,
      );
    }

    // 3. Tribün İsyanı / Taraftar Coşkusu
    if (fans < 35) {
      return NewspaperStory(
        outletName: 'TRİBÜNÜN SESİ GAZETESİ',
        headline: 'TARAFTARDAN TESİSLERDE PROTESTO ÇAĞRISI!',
        subhead: 'Ateşli taraftar grupları tribünlerde sabırlarının taştığını açıkladı. $oppName karşılaşması öncesi camiada gerilim doruk noktasında.',
        reporter: 'Ali Rıza Korkmaz',
        columnQuote: '"Bu camia sadece mücadele görmek istiyor; futbolcular sahaya yüreğini koymalı."',
        dateString: dateStr,
        isPositive: false,
      );
    }

    // 4. Son Maç Oynandıysa: Galibiyet, Mağlubiyet veya Beraberlik Yorumu
    if (playedFixtures.isNotEmpty) {
      final lastMatch = playedFixtures.last;
      final lastUserHome = lastMatch.homeClubId == club.id;
      final userGoals = lastUserHome ? (lastMatch.homeScore ?? 0) : (lastMatch.awayScore ?? 0);
      final oppGoals = lastUserHome ? (lastMatch.awayScore ?? 0) : (lastMatch.homeScore ?? 0);

      if (userGoals > oppGoals) {
        return NewspaperStory(
          outletName: 'FUTBOL GAZETESİ • ZAFER SAYISI',
          headline: 'ZAFERİN ADI ${club.name.toUpperCase()}!',
          subhead: 'Son düdükle birlikte sahada taktik resitali vardı. Teknik heyetin hazırladığı hücum planı ve soyunma odasının inancı 3 puanı getirdi.',
          reporter: 'Nihal Aksu (Baş Yazar)',
          columnQuote: '"Bu takım sahada sadece futbol oynamıyor, bir hanedanlık inşa ediyor."',
          dateString: dateStr,
          isPositive: true,
        );
      } else if (userGoals < oppGoals) {
        return NewspaperStory(
          outletName: 'SON BASKI • SPOR ANALİZ',
          headline: 'KRİTİK MAÇTA BEKLENMEDİK KAYIP!',
          subhead: 'Hakem düdüğü ve şanssız pozisyonlar skora yansıdı. Taraftarlar sosyal medyada taktik tercihlerini ve hakem kararlarını tartışıyor.',
          reporter: 'Bülent Turgut',
          columnQuote: '"Yenilgiden ders çıkarıp önümüzdeki $oppName sınavına kenetlenmek gerekiyor."',
          dateString: dateStr,
          isPositive: false,
        );
      }
    }

    // 5. Yaklaşan Maç / Fikstür Manşetleri
    if (matchday <= 3) {
      return NewspaperStory(
        outletName: 'LİG RADARI • SEZON BAŞLANGICI',
        headline: 'YENİ SEZONDA GÖZLER ${club.name.toUpperCase()} ÜZERİNDE!',
        subhead: 'Lig maratonu hız kesmeden sürüyor. Hafta sonu oynanacak $oppName randevusu öncesi tüm gözler başkanın belirlediği şampiyonluk hedefine çevrildi.',
        reporter: 'Saha Kenarı Ekibi',
        columnQuote: '"Sezonun ilk haftalarında toplanan puanlar, ligin sonunda kupa olarak geri döner."',
        dateString: dateStr,
        isPositive: true,
      );
    }

    if (matchday >= 18) {
      return NewspaperStory(
        outletName: 'FİNAL VİRAJI • ÖZEL BÜLTEN',
        headline: 'ŞAMPİYONLUK VE YÜKSELME HESAPLARI KIZIŞTI!',
        subhead: 'Son haftalara girilirken puan cetvelinde heyecan tavan yaptı. $oppName karşısında alınacak netice sıralamayı doğrudan etkileyecek.',
        reporter: 'Nihal Aksu (Baş Yazar)',
        columnQuote: '"Artık hata lüksü kalmadı. Her pas, her taktik hamle altın değerinde."',
        dateString: dateStr,
        isPositive: true,
      );
    }

    // Genel Maç Önü Manşeti
    return NewspaperStory(
      outletName: 'FUTBOL GAZETESİ • SON BASKI',
      headline: 'HEDEF $oppName KARŞISINDA MUTLAK 3 PUAN!',
      subhead: '$matchday. hafta karşılaşması öncesinde yönetim, teknik heyet ve taraftarlar tek yürek oldu. Şehir maç saatine kilitlendi.',
      reporter: 'Kemalettin Sertel',
      columnQuote: '"Takımın enerjisi yüksek, soyunma odasında moraller yerinde."',
      dateString: dateStr,
      isPositive: true,
    );
  }
}
