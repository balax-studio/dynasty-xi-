// domain/cards/extended_narrative_cards.dart
// Narrative Chains: Shady Agents, Nepotism, Mind Games, Transfer Demands & Perk-Locked Options (§A.2, §A.3, §A.9, §12.6)

import '../entities/card.dart';

class ExtendedNarrativeCards {
  static List<DecisionCard> getCards() {
    return const [
      // 1. Nepotism: President's Nephew (§A.3 Kart 13)
      DecisionCard(
        id: 'chain_nepotism_1',
        characterName: 'Yönetim Kurulu',
        characterRole: 'Kulüp İdare Heyeti',
        characterAvatar: '🏛️',
        headline: 'Başkanın Yeğeni',
        storyText: 'Kulüp başkanı makamına gelip 19 yaşındaki yeğenini A takıma monte etmeni ve ilk 11 garantisi vermeni rica ediyor.',
        category: CardCategory.board,
        options: [
          CardOption(
            id: 'nepotism_accept',
            text: 'Talebi kabul et, yeğeni ilk 11 başlat.',
            resultText: 'Başkan memnun oldu ancak soyunma odasında huzursuzluk çıktı.',
            deltaBoardTrust: 15,
            deltaLockerRoom: -18,
            deltaCash: 5000,
          ),
          CardOption(
            id: 'nepotism_reject',
            text: 'Liyakatten taviz vermem, reddet.',
            resultText: 'Oyuncular kararına saygı duydu, yönetim soğuk karşıladı.',
            deltaBoardTrust: -15,
            deltaLockerRoom: 12,
          ),
          CardOption(
            id: 'nepotism_mentor',
            text: '🔒 [Motivatör] Yeğeni akademiye gönderip özel rehberlik ata.',
            resultText: 'Dengeli bir orta yol bulundu. Genç oyuncu gelişirken takım takdir etti.',
            requiredPerkId: 'motivator_tier1',
            deltaBoardTrust: 10,
            deltaLockerRoom: 5,
          ),
        ],
      ),

      // 2. Shady Agent Commission Deal (§A.5 Kart 22)
      DecisionCard(
        id: 'chain_agent_shady_1',
        characterName: 'Gölge Menajer',
        characterRole: 'Uluslararası Oyuncu Temsilcisi',
        characterAvatar: '🕶️',
        headline: 'Karanlık Menajer Teklifi',
        storyText: 'Ünlü bir menajer, Güney Amerikalı bir wonderkid\'i kulübe getirmeyi teklif ediyor. Ancak elden ₣10.000 komisyon talep ediyor.',
        category: CardCategory.transfer,
        options: [
          CardOption(
            id: 'shady_agent_pay',
            text: 'Parayı öde, oyuncuyu kadroya kat.',
            resultText: 'Oyuncu geldi, taraftar coştu ancak bütçe ve güven sarsıldı.',
            deltaCash: -10000,
            deltaFans: 8,
            deltaBoardTrust: -5,
          ),
          CardOption(
            id: 'shady_agent_report',
            text: 'Resmi olmayan teklifi federasyona bildir.',
            resultText: 'Etik duruşunuz federasyon ve yönetimin takdirini kazandı.',
            deltaBoardTrust: 10,
            deltaFans: 5,
          ),
          CardOption(
            id: 'shady_agent_bargain',
            text: '🔒 [Tüccar] Komisyonu yasal sözleşmeye bağlayıp indirime zorla.',
            resultText: 'Pazarlık gücünüzle komisyonu yarıya indirip resmi protokole bağladınız.',
            requiredPerkId: 'merchant_tier1',
            deltaCash: -4000,
            deltaFans: 12,
          ),
        ],
      ),

      // 3. Rival Manager Mind Games (§A.2 Kart 10)
      DecisionCard(
        id: 'chain_mind_games_1',
        characterName: 'Rakip Hoca',
        characterRole: 'Ezeli Rakip Teknik Direktörü',
        characterAvatar: '👔',
        headline: 'Derbi Öncesi Akıl Oyunları',
        storyText: 'Rakip teknik direktör basına verdiği demeçte takımının şans eseri kazandığını ve taktiksel olarak yetersiz olduğunu söyledi.',
        category: CardCategory.press,
        options: [
          CardOption(
            id: 'mind_games_retaliate',
            text: 'Sert yanıt ver: "Cevabı sahada alacaklar!"',
            resultText: 'Tribünler ve soyunma odası ateşlendi.',
            deltaFans: 12,
            deltaLockerRoom: 8,
            deltaBoardTrust: -5,
          ),
          CardOption(
            id: 'mind_games_silent',
            text: 'Sessiz kalıp soğukkanlılığını koru.',
            resultText: 'Yönetim olgunluğunuzu övdü.',
            deltaBoardTrust: 5,
            deltaLockerRoom: -4,
          ),
          CardOption(
            id: 'mind_games_showman',
            text: '🔒 [Sahne İnsanı] İğneleyici bir espriyle tüm kamuoyunu arkana al.',
            resultText: 'Basın toplantısında kahkahalar koptu, tüm moral üstünlüğü ele geçirildi.',
            requiredPerkId: 'showman_tier1',
            deltaFans: 20,
            deltaBoardTrust: 10,
          ),
        ],
      ),

      // 4. Star Player Transfer Ultimatum (§A.1 Kart 2)
      DecisionCard(
        id: 'chain_transfer_ultimatum_1',
        characterName: 'Yıldız Forvet',
        characterRole: 'Takım Golcüsü',
        characterAvatar: '⭐',
        headline: 'Yıldız Oyuncunun Ayrılık Talebi',
        storyText: 'Takımın en değerli forveti büyük ligden teklif aldığını ve satılmazsa antrenmanlara çıkmayacağını bildirdi.',
        category: CardCategory.squad,
        options: [
          CardOption(
            id: 'transfer_ultimatum_sell',
            text: 'Yüksek bonservisle satılmasına izin ver.',
            resultText: 'Kasaya ciddi bir nakit girdi fakat taraftarlar üzüldü.',
            deltaCash: 35000,
            deltaFans: -12,
            deltaLockerRoom: -8,
          ),
          CardOption(
            id: 'transfer_ultimatum_ban',
            text: 'Kadro dışı bırak, kulüpten büyük kimse yok!',
            resultText: 'Otoriteniz soyunma odasını hizaya soktu.',
            deltaLockerRoom: 10,
            deltaFans: 6,
            deltaBoardTrust: -10,
          ),
          CardOption(
            id: 'transfer_ultimatum_bonus',
            text: '🔒 [Taktikçi] Sezon sonuna kadar kalması için ikna edip şampiyonluk primi vaat et.',
            resultText: 'Oyuncu motive oldu, sezon sonuna kadar kalma sözü verdi.',
            requiredPerkId: 'tactician_tier1',
            deltaLockerRoom: 12,
            deltaBoardTrust: 8,
            deltaCash: -5000,
          ),
        ],
      ),
    ];
  }
}
