// domain/cards/dynamic_card_factory.dart
// Pure Dart. Generates contextual dynamic decision cards based on in-game events (§12.4 & §12.5).

import '../entities/card.dart';
import '../entities/player.dart';
import '../sim/injury_engine.dart';

class DynamicCardFactory {
  /// Generates a contextual card when a key player suffers an injury.
  static DecisionCard createInjuryCard(Player player, InjuryOccurrence injury) {
    return DecisionCard(
      id: 'dyn_injury_${player.id}_${DateTime.now().millisecondsSinceEpoch}',
      characterName: 'Ayşe Tanrıkulu',
      characterRole: 'Kulüp Doktoru',
      characterAvatar: '',
      headline: '${player.fullName} Sakatlandı!',
      storyText:
          '"Hocam, ${player.fullName} maçta ${injury.injuryType} sakatlığı yaşadı. Yaklaşık ${injury.matchesOut} maç sahalardan uzak kalacak."',
      category: CardCategory.medical,
      options: [
        const CardOption(
          id: 'opt_injury_special_clinic',
          text: 'Özel klinikte hızlı tedaviye başla (-₣15.000, +Hızlı İyileşme)',
          resultText: 'Oyuncu özel kliniğe sevk edildi. Tedavi süresi 1 maç kısaldı.',
          deltaCash: -15000,
          deltaLockerRoom: 5,
          deltaBoardTrust: -2,
        ),
        const CardOption(
          id: 'opt_injury_standard_rest',
          text: 'Tesislerimizde standart dinlenme uygulansın',
          resultText: 'Oyuncu tesislerimizde dinlenmeye çekildi.',
          deltaLockerRoom: 0,
        ),
      ],
    );
  }

  /// Generates a card when a high-performing player is underpaid.
  static DecisionCard createUnderpaidCard(Player player, int expectedWage) {
    return DecisionCard(
      id: 'dyn_underpaid_${player.id}_${DateTime.now().millisecondsSinceEpoch}',
      characterName: player.fullName,
      characterRole: '${player.position.label} (Maaş: ₣${player.weeklyWage})',
      characterAvatar: '',
      headline: '${player.lastName}\'nin Maaş İsyanı',
      storyText:
          '"Hocam, takıma katkım ortada ama haftalık sadece ₣${player.weeklyWage} alıyorum. Piyasa değerimin hakkını (₣$expectedWage) istiyorum!"',
      category: CardCategory.lockerRoom,
      options: [
        CardOption(
          id: 'opt_raise_wage',
          text: 'Maaşını artır (-₣${(expectedWage - player.weeklyWage) * 4} Bütçe, +Moral)',
          resultText: '${player.fullName} ile zamlı sözleşme imzalandı. Yüzü gülüyor.',
          deltaCash: -((expectedWage - player.weeklyWage) * 4),
          deltaLockerRoom: 8,
          deltaBoardTrust: -3,
        ),
        CardOption(
          id: 'opt_reject_raise',
          text: 'Sözleşmen geçerli, sahaya odaklan! (-Moral, -Bağlılık)',
          resultText: '${player.lastName} kapıyı çarparak çıktı. Soyunma odasında huzursuzluk yarattı.',
          deltaLockerRoom: -10,
          deltaBoardTrust: 3,
        ),
      ],
    );
  }

  /// Generates a card when a player's contract is nearing expiration.
  static DecisionCard createContractExpiringCard(Player player) {
    return DecisionCard(
      id: 'dyn_contract_exp_${player.id}_${DateTime.now().millisecondsSinceEpoch}',
      characterName: 'Bülent Tosun',
      characterRole: 'Oyuncu Menajeri',
      characterAvatar: '[MENAJER]',
      headline: '${player.fullName} Sözleşme Sonu Yaklaşıyor',
      storyText:
          '"Hocam, müvekkilim ${player.fullName}\'in sözleşmesinde son sezona girdik. Başka kulüpler teklif hazırlıyor."',
      category: CardCategory.transfer,
      options: [
        CardOption(
          id: 'opt_renew_contract',
          text: 'Hemen 2 yıllık yeni sözleşme öner (-₣10.000 İmza)',
          resultText: '${player.fullName} kulüpte kalmaktan mutluluk duyduğunu belirtti.',
          deltaCash: -10000,
          deltaLockerRoom: 4,
          deltaBoardTrust: 4,
        ),
        const CardOption(
          id: 'opt_let_expire',
          text: 'Sezon sonu vedalaşacağız, transfer listesine koy',
          resultText: 'Oyuncu transfer listesine eklendi.',
          deltaLockerRoom: -4,
          deltaFans: -2,
        ),
      ],
    );
  }

  /// Generates a card when a star player is benched consecutively.
  static DecisionCard createStarBenchedCard(Player player) {
    return DecisionCard(
      id: 'dyn_star_bench_${player.id}_${DateTime.now().millisecondsSinceEpoch}',
      characterName: player.fullName,
      characterRole: 'Yıldız Oyuncu',
      characterAvatar: 'STAR',
      headline: 'Yıldızın Kulübe İsyanı',
      storyText:
          '"Hocam, ben bu takımın yıldızıyım. Yedek kulübesinde oturmaya alışkın değilim! Beni oynatmayacaksanız gideyim."',
      category: CardCategory.lockerRoom,
      options: [
        CardOption(
          id: 'opt_promise_start',
          text: 'Önümüzdeki maç 11\'de başlama sözü ver (+Moral)',
          resultText: '${player.fullName} motive oldu ve antrenmanlara asıldı.',
          deltaLockerRoom: 6,
        ),
        const CardOption(
          id: 'opt_earn_shirt',
          text: 'Kimse formayı tapulamadı, hak eden oynar! (-Moral)',
          resultText: 'Yıldız oyuncu tavır aldı.',
          deltaLockerRoom: -8,
          deltaBoardTrust: 4,
        ),
      ],
    );
  }
}
