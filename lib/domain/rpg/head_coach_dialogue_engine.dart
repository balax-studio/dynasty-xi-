// domain/rpg/head_coach_dialogue_engine.dart
// RPG Head Coach Interactive Dialogue & Management Engine (§15.4)

import '../entities/game_state.dart';
import '../president/head_coach.dart';

enum CoachDialogueTopic {
  tacticalPlan('⚔️ Taktik & Oyun Planı', 'Haftalık maç stratejisini ve oyun temposunu tartışın.'),
  playerManagement('👥 Kadro & Gençler', 'Gençlerin oynatılması ve yıldızların dinlendirilmesini talep edin.'),
  transferAdvice('🔍 Transfer Tavsiyesi', 'Hocadan kadrodaki en zayıf halka ve eksik bölge raporu alın.'),
  presidentCritique('⚡ Başkanlık Uyarısı', 'Takımın gidişatı ve disiplini hakkında sert/yapıcı ikazda bulunun.'),
  licenseUpgrade('🎓 Pro Lisans Kampı', 'Hocayı UEFA Taktik Seminerine gönderip OVR ve itibarını yükseltin (₣8.000).');

  final String title;
  final String description;

  const CoachDialogueTopic(this.title, this.description);
}

class CoachDialogueOption {
  final String id;
  final String label;
  final String presidentSpeech;
  final String coachReply;
  final int deltaLockerRoom;
  final int deltaBoardTrust;
  final int deltaFans;
  final int deltaCash;
  final int coachOvrBonus;
  final String resultSummary;

  const CoachDialogueOption({
    required this.id,
    required this.label,
    required this.presidentSpeech,
    required this.coachReply,
    this.deltaLockerRoom = 0,
    this.deltaBoardTrust = 0,
    this.deltaFans = 0,
    this.deltaCash = 0,
    this.coachOvrBonus = 0,
    required this.resultSummary,
  });
}

class HeadCoachDialogueEngine {
  /// Konuya ve Hocanın Karakterine Göre Seçenekleri Üret
  static List<CoachDialogueOption> getOptionsForTopic(
    CoachDialogueTopic topic,
    HeadCoach coach,
    GameState state,
  ) {
    final club = state.userClub;

    switch (topic) {
      case CoachDialogueTopic.tacticalPlan:
        return [
          CoachDialogueOption(
            id: 'tac_high_press',
            label: 'Önde Şok Pres & Agresif Hücum',
            presidentSpeech: 'Hocam, taraftar hücum futbolu istiyor! Rakibi kendi sahasına hapsedelim.',
            coachReply: coach.archetype == HeadCoachArchetype.tactician
                ? 'Tam benim felsefem Sayın Başkan! İleri üçlüyü rakip stoperlere bastırıp ilk 20 dakikada fişi çekeceğiz.'
                : 'Hücum oynamak güzel ama savunma arkasında boşluk bırakabiliriz. Yine de emirlerinizi uygulayacağım.',
            deltaFans: 3,
            deltaLockerRoom: 1,
            resultSummary: 'Ofansif tempo artırıldı. Taraftar coşkusu yükseldi (+3).',
          ),
          CoachDialogueOption(
            id: 'tac_solid_defense',
            label: 'Kompakt Savunma & Kontra Atak',
            presidentSpeech: 'Önce gol yemeyeceğiz! Arkayı sağlama alıp hızlı hücumlarla vuralım.',
            coachReply: coach.archetype == HeadCoachArchetype.disciplinarian
                ? 'Aynen öyle Başkanım. Disiplinsiz hücum iflas getirir. Çelik gibi bir hat kuruyoruz.'
                : 'Sonuç almak için pragmatik olacağız. 1-0 olsun bizim olsun!',
            deltaBoardTrust: 2,
            deltaLockerRoom: -1,
            resultSummary: 'Savunma emniyeti sağlandı. Yönetim memnuniyeti arttı (+2).',
          ),
        ];

      case CoachDialogueTopic.playerManagement:
        return [
          CoachDialogueOption(
            id: 'squad_trust_youth',
            label: 'Genç Yeteneklere Şans Ver',
            presidentSpeech: 'Kulübün geleceği altyapıda. Genç yeteneklerimizi ilk 11\'de görmek istiyorum.',
            coachReply: coach.archetype == HeadCoachArchetype.youthDeveloper
                ? 'Harika bir vizyon Başkanım! U19\'dan çıkardığımız cevherleri ilk 11\'e monte edeceğim.'
                : 'Riskli ama sizin talimatınız başımın üstüne. Gençlere forma süresi vereceğim.',
            deltaFans: 2,
            deltaLockerRoom: 2,
            resultSummary: 'Gençlerin forma şansı arttı. Takım enerjisi yükseldi (+2).',
          ),
          const CoachDialogueOption(
            id: 'squad_veteran_focus',
            label: 'Tecrübeli Yıldızlara Güven',
            presidentSpeech: 'Macera aramayalım. Maçı taşıyacak olanlar kariyerli ve soğukkanlı oyunculardır.',
            coachReply: 'Kesinlikle katılıyorum Başkanım. Baskı anlarında sahadaki tecrübe puan getirir.',
            deltaLockerRoom: 3,
            deltaBoardTrust: 1,
            resultSummary: 'Soyunma odası huzuru sağlandı (+3).',
          ),
        ];

      case CoachDialogueTopic.transferAdvice:
        return const [
          CoachDialogueOption(
            id: 'adv_striker',
            label: 'Bitirici Forvet & Golcü Raporu',
            presidentSpeech: 'Hocam hücum hattımız sence yeterli mi? Nereye takviye yapalım?',
            coachReply: 'Pozisyona giriyoruz ama son vuruşlarda eksiğimiz var. Ceza sahasında bitirici bir golcü şampiyonluğu getirir!',
            deltaBoardTrust: 1,
            resultSummary: 'Scout ekibine forvet arama talimatı iletildi.',
          ),
          CoachDialogueOption(
            id: 'adv_defense',
            label: 'Lider Stoper & Savunma Raporu',
            presidentSpeech: 'Savunmamız güven veriyor mu? Geri dörtlüye takviye ister misin?',
            coachReply: 'Hava toplarında ve kademe hatalarında zorlanıyoruz. Defansı toparlayacak tecrübeli bir lider şart.',
            deltaBoardTrust: 1,
            resultSummary: 'Savunma takviye planı yönetim gündemine alındı.',
          ),
        ];

      case CoachDialogueTopic.presidentCritique:
        return [
          CoachDialogueOption(
            id: 'critique_firm_warning',
            label: 'Sert İkaz: "Sonuçlar Kabul Edilemez!"',
            presidentSpeech: 'Hocam burası büyük kulüp. Taraftarın da yönetimin de sabrı tükeniyor. Bir an önce toparlanın!',
            coachReply: coach.boardConfidence > 60
                ? 'Mesajınızı aldım Başkanım. Antrenman temposunu iki katına çıkarıyoruz, mazeret yok!'
                : 'Baskıyı anlıyorum Başkanım. Takımı bu cendereden çıkaracak gücüm var, bana güvenin.',
            deltaBoardTrust: 4,
            deltaLockerRoom: -3,
            resultSummary: 'Hocaya sert uyarı verildi. Yönetim otoritesi pekişti (+4), soyunma odası gerildi (-3).',
          ),
          const CoachDialogueOption(
            id: 'critique_support',
            label: 'Tam Destek: "Yönetim Arkanda!"',
            presidentSpeech: 'Hocam dedikodulara kulak asma. Yönetim olarak senin arkandayız, hedefe beraber yürüyeceğiz.',
            coachReply: 'Bu güveniniz için çok teşekkür ederim Başkanım! Bu kulüp için canla başla savaşmaya devam edeceğiz.',
            deltaLockerRoom: 4,
            deltaBoardTrust: -1,
            deltaFans: 2,
            resultSummary: 'Hocaya güven tazelendi. Takım morali ve bağlılığı yükseldi (+4).',
          ),
        ];

      case CoachDialogueTopic.licenseUpgrade:
        final canAfford = club.meters.cash >= 8000;
        return [
          CoachDialogueOption(
            id: 'license_uefa_pro',
            label: 'UEFA Pro Lisans & Taktik Kampına Gönder (₣8.000)',
            presidentSpeech: 'Hocam, seni Avrupa\'nın en modern taktik seminerine ve masterclass eğitimine gönderiyoruz.',
            coachReply: canAfford
                ? 'Başkanım bu kulübün vizyonuna hayranım! En güncel hücum setleri ve veri analitiği ile geri döneceğim.'
                : 'Başkanım harika bir fikir fakat kulüp kasasında bu bütçe yok gibi görünüyor.',
            deltaCash: canAfford ? -8000 : 0,
            coachOvrBonus: canAfford ? 3 : 0,
            deltaBoardTrust: canAfford ? 5 : 0,
            deltaLockerRoom: canAfford ? 3 : 0,
            resultSummary: canAfford
                ? 'Hoca semineri tamamladı! OVR +3 arttı, kulüp itibarı güçlendi (+5).'
                : 'Yetersiz bütçe nedeniyle eğitim ertelendi.',
          ),
        ];
    }
  }
}
