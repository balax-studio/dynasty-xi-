// domain/cards/extended_narrative_cards.dart
// Narrative Chains: Shady Agents, Nepotism, Mind Games, Transfer Demands & Perk-Locked Options (§A.2, §A.3, §A.9, §12.6)

import '../entities/card.dart';

class ExtendedNarrativeCards {
  static List<GameCard> getCards() {
    return [
      // 1. Nepotism: President's Nephew (§A.3 Kart 13)
      const GameCard(
        id: 'chain_nepotism_1',
        title: 'Başkanın Yeğeni',
        description: 'Kulüp başkanı makamına gelip 19 yaşındaki yeğenini A takıma monte etmeni ve ilk 11 garantisi vermeni rica ediyor.',
        type: CardType.dilemma,
        category: CardCategory.boardRoom,
        options: [
          CardOption(
            text: 'Talebi kabul et, yeğeni ilk 11 başlat.',
            consequences: CardConsequences(
              boardTrustChange: 15,
              lockerRoomChange: -18,
              cashChange: 5000,
            ),
          ),
          CardOption(
            text: 'Liyakatten taviz vermem, reddet.',
            consequences: CardConsequences(
              boardTrustChange: -15,
              lockerRoomChange: 12,
            ),
          ),
          CardOption(
            text: '🔒 [Motivatör] Yeğeni akademiye gönderip özel rehberlik ata.',
            requiredPerkId: 'motivator_tier1',
            consequences: CardConsequences(
              boardTrustChange: 10,
              lockerRoomChange: 5,
              managerXpGain: 50,
            ),
          ),
        ],
      ),

      // 2. Shady Agent Commission Deal (§A.5 Kart 22)
      const GameCard(
        id: 'chain_agent_shady_1',
        title: 'Karanlık Menajer Teklifi',
        description: 'Ünlü bir menajer, Güney Amerikalı bir wonderkid\'i kulübe getirmeyi teklif ediyor. Ancak elden ₣10.000 komisyon talep ediyor.',
        type: CardType.dilemma,
        category: CardCategory.transfers,
        options: [
          CardOption(
            text: 'Parayı öde, oyuncuyu kadroya kat.',
            consequences: CardConsequences(
              cashChange: -10000,
              fansChange: 8,
              boardTrustChange: -5,
            ),
          ),
          CardOption(
            text: 'Resmi olmayan teklifi federasyona bildir.',
            consequences: CardConsequences(
              boardTrustChange: 10,
              fansChange: 5,
            ),
          ),
          CardOption(
            text: '🔒 [Tüccar] Komisyonu yasal sözleşmeye bağlayıp indirime zorla.',
            requiredPerkId: 'merchant_tier1',
            consequences: CardConsequences(
              cashChange: -4000,
              fansChange: 12,
              managerXpGain: 60,
            ),
          ),
        ],
      ),

      // 3. Rival Manager Mind Games (§A.2 Kart 10)
      const GameCard(
        id: 'chain_mind_games_1',
        title: 'Derbi Öncesi Akıl Oyunları',
        description: 'Rakip teknik direktör basına verdiği demeçte takımının şans eseri kazandığını ve taktiksel olarak yetersiz olduğunu söyledi.',
        type: CardType.dilemma,
        category: CardCategory.media,
        options: [
          CardOption(
            text: 'Sert yanıt ver: "Cevabı sahada alacaklar!"',
            consequences: CardConsequences(
              fansChange: 12,
              lockerRoomChange: 8,
              boardTrustChange: -5,
            ),
          ),
          CardOption(
            text: 'Sessiz kalıp soğukkanlılığını koru.',
            consequences: CardConsequences(
              boardTrustChange: 5,
              lockerRoomChange: -4,
            ),
          ),
          CardOption(
            text: '🔒 [Sahne İnsanı] İğneleyici bir espriyle tüm kamuoyunu arkana al.',
            requiredPerkId: 'showman_tier1',
            consequences: CardConsequences(
              fansChange: 20,
              boardTrustChange: 10,
              managerXpGain: 75,
            ),
          ),
        ],
      ),

      // 4. Star Player Transfer Ultimatum (§A.1 Kart 2)
      const GameCard(
        id: 'chain_transfer_ultimatum_1',
        title: 'Yıldız Oyuncunun Ayrılık Talebi',
        description: 'Takımın en değerli forveti büyük ligden teklif aldığını ve satılmazsa antrenmanlara çıkmayacağını bildirdi.',
        type: CardType.dilemma,
        category: CardCategory.squad,
        options: [
          CardOption(
            text: 'Yüksek bonservisle satılmasına izin ver.',
            consequences: CardConsequences(
              cashChange: 35000,
              fansChange: -12,
              lockerRoomChange: -8,
            ),
          ),
          CardOption(
            text: 'Kadro dışı bırak, kulüpten büyük kimse yok!',
            consequences: CardConsequences(
              lockerRoomChange: 10,
              fansChange: 6,
              boardTrustChange: -10,
            ),
          ),
          CardOption(
            text: '🔒 [Taktikçi] Sezon sonuna kadar kalması için ikna edip şampiyonluk primi vaat et.',
            requiredPerkId: 'tactician_tier1',
            consequences: CardConsequences(
              lockerRoomChange: 12,
              boardTrustChange: 8,
              cashChange: -5000,
              managerXpGain: 80,
            ),
          ),
        ],
      ),
    ];
  }
}
