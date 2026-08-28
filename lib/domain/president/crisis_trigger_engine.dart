// domain/president/crisis_trigger_engine.dart
// Executive Hotline Crisis Trigger Engine (§12.8, §17.5)

import '../entities/game_state.dart';
import 'president_crisis.dart';

class CrisisTriggerEngine {
  /// Kulübün anlık durumunu (Bütçe, Güven, Moral, Fikstür) analiz ederek
  /// tetiklenmesi gereken acil Kırmızı Hat çağrısını belirler.
  /// Kriz koşulu yoksa `null` döner.
  static PresidentCrisisCall? evaluateCrisis(GameState state) {
    final club = state.userClub;
    final cash = club.meters.cash;
    final boardTrust = club.meters.boardTrust;
    final fans = club.meters.fans;
    final lockerRoom = club.meters.lockerRoom;
    final matchday = state.clock.matchday;

    // 1. Mali Darboğaz / Kasa İflas Tehdidi (< ₣15.000)
    if (cash < 15000) {
      return const PresidentCrisisCall(
        id: 'financial_insolvency_call',
        caller: CrisisCallerType.mayor,
        callerName: 'Vergi Dairesi & Belediye',
        callerTitle: 'Maliye ve Hazine Komisyonu',
        callerAvatar: '[DUSUS]',
        dialogQuote: 'Sayın Başkan! Kulüp hesaplarınızda bloke riski var. Acil 25.000 € kaynak girişi yapmazsanız transfer tahtası ve tesis elektrikleri kesilecek!',
        choices: [
          CrisisChoice(
            title: 'Kişisel Servetten Sermaye Aktar (25.000 €)',
            description: 'Başkanlık fonunu devreye sokarak maliyeyi yatıştır.',
            cashDelta: 25000,
            boardTrustDelta: 10,
            fansDelta: 4,
            outcomeMessage: 'Kişisel kaynakla kriz savuşturuldu, transfer tahtası açık kaldı.',
          ),
          CrisisChoice(
            title: 'Gelecek Sezon Tribün Gelirini İpotek Et',
            description: 'Nakit akışı sağla ama taraftarın tepkisini çek.',
            cashDelta: 40000,
            fansDelta: -10,
            boardTrustDelta: -5,
            outcomeMessage: 'Tribün hakları devredildi, kasaya para girdi.',
          ),
          CrisisChoice(
            title: 'Tasarruf Paketi Açıkla (Maaşları Dondur)',
            description: 'Harcamaları kısarak kriz masası oluştur.',
            lockerRoomDelta: -12,
            boardTrustDelta: 6,
            outcomeMessage: 'Mali disiplin sağlandı fakat soyunma odası huzursuz.',
          ),
        ],
      );
    }

    // 2. Yönetim Kurulu Güven Oylaması Tehdidi (Güven < %40)
    if (boardTrust < 40) {
      return const PresidentCrisisCall(
        id: 'board_no_confidence_call',
        caller: CrisisCallerType.rivalPresident,
        callerName: 'Muhalif Divan Kurulu Lideri',
        callerTitle: 'Olağanüstü Kongre Komitesi',
        callerAvatar: '[HUKUK]',
        dialogQuote: 'Başkan! Yönetim Kurulu içinde çoğunluk imza topladı. Bu hafta takıma net bir galibiyet primi koymazsanız olağanüstü kongre kararı alıyoruz!',
        choices: [
          CrisisChoice(
            title: 'Çifte Galibiyet Primi İlan Et (30.000 €)',
            description: 'Futbolcuları motive edip kader maçını kazan.',
            cashDelta: -30000,
            lockerRoomDelta: 10,
            boardTrustDelta: 8,
            outcomeMessage: 'Takım maça odaklandı, muhalefet sessizliğe büründü.',
          ),
          CrisisChoice(
            title: 'Divan Kurulu Heyetine Rest Çek ("Milletin İradesi")',
            description: 'Popülist basın toplantısı düzenle.',
            fansDelta: 8,
            boardTrustDelta: -10,
            outcomeMessage: 'Taraftar arkanızda toplandı ancak yönetimde çatlak büyüdü.',
          ),
          CrisisChoice(
            title: 'Muhalif Üyelerle Gizli Yemekte Anlaş',
            description: 'İki yöneticiye komite başkanlığı teklif et.',
            boardTrustDelta: 5,
            lockerRoomDelta: -2,
            outcomeMessage: 'İmza krizi diplomasi ile donduruldu.',
          ),
        ],
      );
    }

    // 3. Tribün Ayaklanması & Holigan Şantajı (Taraftar < %35)
    if (fans < 35) {
      return const PresidentCrisisCall(
        id: 'ultra_rebellion_call',
        caller: CrisisCallerType.ultraLeader,
        callerName: 'Amigo Reis',
        callerTitle: 'Birleşik Tribünler Sözcüsü',
        callerAvatar: '[DUYURU]',
        dialogQuote: 'Büyük Başkan! Taraftar tesisleri bastı. Antrenmanı durdurduk. Ya transfer sözü verirsin ya da pazar günü istifa tezahüratından maçı oynatmayız!',
        choices: [
          CrisisChoice(
            title: 'Tesislere İnip Taraftarla Bizzat Konuş',
            description: 'Cesurca megafonu alıp güven aşıla.',
            fansDelta: 12,
            boardTrustDelta: 4,
            lockerRoomDelta: 2,
            outcomeMessage: 'Taraftar ikna oldu, tesislerde birlik havası oluştu.',
          ),
          CrisisChoice(
            title: 'Emniyetten Takviye Çevik Kuvvet İste',
            description: 'Tesis güvenliğini polise devret.',
            fansDelta: -10,
            boardTrustDelta: 6,
            cashDelta: -10000,
            outcomeMessage: 'Holiganlar dağıtıldı ama tribün tepkisi sertleşti.',
          ),
          CrisisChoice(
            title: 'Grup Liderlerine Bedava Maç Bileti Dağıt',
            description: 'Amigoları memnun ederek tansiyonu düşür.',
            cashDelta: -15000,
            fansDelta: 6,
            boardTrustDelta: -4,
            outcomeMessage: 'Protestolar durdu, amigolar desteğe döndü.',
          ),
        ],
      );
    }

    // 4. Soyunma Odası İsyanı & Kaptan Boykotu (Moral < %35)
    if (lockerRoom < 35) {
      return const PresidentCrisisCall(
        id: 'locker_rebellion_call',
        caller: CrisisCallerType.starPlayerAgent,
        callerName: 'Takım Kaptanı Menajeri',
        callerTitle: 'Oyuncu Temsilcisi',
        callerAvatar: '[MENAJER]',
        dialogQuote: 'Sayın Başkan, takım kaptanı ve yerli oyuncular hocanın antrenman metodlarını boykot ediyor. Acil bir prim dopingi veya özel toplantı yapmanız şart.',
        choices: [
          CrisisChoice(
            title: 'Takımla Barbekü Partisi & Moral Yemeği Düzenle',
            description: 'Başkanlık bütçesinden 10.000 € ile takımı kaynaştır.',
            cashDelta: -10000,
            lockerRoomDelta: 14,
            fansDelta: 4,
            outcomeMessage: 'Takım kenetlendi, kriz tatlıya bağlandı.',
          ),
          CrisisChoice(
            title: 'Kaptanı Kadro Dışı Bırakıp Disiplini Koru',
            description: 'Taviz verme, hocanın arkasında dur.',
            lockerRoomDelta: -6,
            boardTrustDelta: 10,
            outcomeMessage: 'Kadro dışı kararı otorite sağladı, yönetim takdir etti.',
          ),
          CrisisChoice(
            title: 'Hoca ile Kaptanı Odanda Yüzleştir',
            description: 'Arabuluculuk yap.',
            lockerRoomDelta: 6,
            boardTrustDelta: 2,
            outcomeMessage: 'Karşılıklı tavizlerle buzlar eridi.',
          ),
        ],
      );
    }

    // 5. Periyodik Derbi / TFF / Transfer Krizleri (Örn: 7. ve 14. hafta dönüm noktaları)
    if (matchday == 7 || matchday == 14) {
      return const PresidentCrisisCall(
        id: 'tff_referee_scandal',
        caller: CrisisCallerType.federationHead,
        callerName: 'Federasyon Başkanı',
        callerTitle: 'TFF Disiplin Kurulu',
        callerAvatar: '[HUKUK]',
        dialogQuote: 'Sayın Başkan, kulübünüzün maç sonu hakem bildirisi disiplin kuruluna sevk edildi. Sert ceza kapıda. Kamuoyu önünde uzlaşma mesajı verecek misiniz?',
        choices: [
          CrisisChoice(
            title: 'Diplomatik Açıklama ile Geri Adım At',
            description: 'Cezadan kurtul ama tribünlere yumuşak görün.',
            fansDelta: -4,
            boardTrustDelta: 6,
            outcomeMessage: 'Disiplin sevki para cezasına dönüştürüldü.',
          ),
          CrisisChoice(
            title: 'Canlı Yayına Çıkıp TFF\'ye Meydan Oku',
            description: 'Bütün camiayı arkana alıp bayrak aç.',
            fansDelta: 14,
            boardTrustDelta: -8,
            lockerRoomDelta: 6,
            outcomeMessage: 'Camiada kenetlenme rüzgarı esti!',
          ),
          CrisisChoice(
            title: 'Kulüpler Birliği Zirvesinde Lobi Yap',
            description: 'Diğer başkanlarla ortak bildiri hazırla.',
            cashDelta: -12000,
            boardTrustDelta: 4,
            outcomeMessage: 'Ortak diplomasi ile TFF üzerindeki baskı arttı.',
          ),
        ],
      );
    }

    return null;
  }
}
