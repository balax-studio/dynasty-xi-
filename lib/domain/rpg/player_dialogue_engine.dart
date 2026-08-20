// domain/rpg/player_dialogue_engine.dart
// Pure Dart. Personality-driven RPG dialogue simulation with real in-game gameplay consequences.

import '../entities/player.dart';

enum DialogueTopicCategory {
  performance('Performans & Moral', '⚽'),
  playingTime('Oyun Süresi & Rol', '⏱️'),
  training('Gelişim & Özel Çalışma', '⚡'),
  leadership('Liderlik & Soyunma Odası', '🛡️'),
  transferPersuasion('Transfer İknası & Vizyon', '🤝'),
  characterScout('Mentalite & Karakter Analizi', '🔍');

  final String label;
  final String icon;

  const DialogueTopicCategory(this.label, this.icon);
}

class DialogueOption {
  final String id;
  final String title;
  final String tone;
  final String description;

  const DialogueOption({
    required this.id,
    required this.title,
    required this.tone,
    required this.description,
  });
}

class DialogueTopic {
  final String id;
  final DialogueTopicCategory category;
  final String title;
  final String subtitle;
  final String icon;
  final List<DialogueOption> options;
  final bool isOwnedOnly;

  const DialogueTopic({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.options,
    this.isOwnedOnly = true,
  });
}

class DialogueResult {
  final String playerReplyText;
  final String reactionEmoji;
  final int deltaMorale;
  final int deltaLoyalty;
  final double deltaForm;
  final int deltaSharpness;
  final int deltaFitness;
  final int deltaLockerRoom;
  final int deltaCash;
  final int transferDiscountPercent;
  final String? statBoostAttribute;
  final int statBoostAmount;
  final List<String> summaryDeltas;

  const DialogueResult({
    required this.playerReplyText,
    required this.reactionEmoji,
    this.deltaMorale = 0,
    this.deltaLoyalty = 0,
    this.deltaForm = 0.0,
    this.deltaSharpness = 0,
    this.deltaFitness = 0,
    this.deltaLockerRoom = 0,
    this.deltaCash = 0,
    this.transferDiscountPercent = 0,
    this.statBoostAttribute,
    this.statBoostAmount = 0,
    required this.summaryDeltas,
  });
}

class PlayerDialogueEngine {
  /// Oyuncunun mülkiyet durumuna ve verilerine göre uygun görüşme konularını listeler
  static List<DialogueTopic> getTopicsForPlayer(Player player, {required bool isOwned}) {
    if (isOwned) {
      return const [
        // 1. Performans & Moral
        DialogueTopic(
          id: 'topic_performance',
          category: DialogueTopicCategory.performance,
          title: 'Saha İçi Performansı ve Moral',
          subtitle: 'Son maçlardaki oyunu değerlendir, motive et veya disiplin uyarısı yap.',
          icon: '🔥',
          options: [
            DialogueOption(
              id: 'perf_praise',
              title: 'Harika bir tutkuyla oynuyorsun, sahadaki liderliğin tüm takımı ateşliyor!',
              tone: '🌟 Övgü & Coşku',
              description: 'Oyuncunun moralini ve formunu yükseltir; duygusal ve hırslı oyuncular çok olumlu karşılar.',
            ),
            DialogueOption(
              id: 'perf_constructive',
              title: 'Taktik disiplininden memnunum ama son vuruşlarda daha soğukkanlı olmalısın.',
              tone: '🛡️ Taktiksel & Mantıklı',
              description: 'Dengeli geri bildirim. Profesyonel ve mütevazı oyuncular için keskinlik ve form artışı sağlar.',
            ),
            DialogueOption(
              id: 'perf_warning',
              title: 'Son haftalardaki lakayt oyunun kabul edilemez! Kendine gelmezsen yedek kulübesi seni bekler.',
              tone: '⚡ Sert Disiplin Uyarısı',
              description: 'Riskli. Hırslı veya profesyonel oyuncuları hırslandırabilir; asi veya duygusal oyuncularda moral çöker.',
            ),
            DialogueOption(
              id: 'perf_bonus_promise',
              title: 'Gelecek maçta gol veya asist katkısı yaparsan özel galibiyet primi hesabında!',
              tone: '💰 Bireysel Prim Vaadi (₣2,500)',
              description: 'Özellikle paragöz ve hırslı oyuncularda anlık keskinlik ve motivasyon patlaması yaratır.',
            ),
          ],
        ),

        // 2. Oyun Süresi & Rol
        DialogueTopic(
          id: 'topic_playing_time',
          category: DialogueTopicCategory.playingTime,
          title: 'Oyun Süresi ve Kadro Hiyerarşisi',
          subtitle: 'İlk 11 beklentisini yönet, rotasyon planını açıkla veya rolünü netleştir.',
          icon: '⏱️',
          options: [
            DialogueOption(
              id: 'role_starter_promise',
              title: 'Sen bu takımın değişilmez omurgasısın. Önümüzdeki maçlarda sahaya 11’de çıkacaksın.',
              tone: '⭐ İlk 11 Garantisi',
              description: 'Morali ve sadakati hızla yükseltir, ayrılma isteğini sıfırlar.',
            ),
            DialogueOption(
              id: 'role_rotation_patience',
              title: 'Önümüzde yoğun bir fikstür var. Sana kesinlikle ihtiyacım olacak, hazır kal ve sıranı bekle.',
              tone: '🤝 Rotasyon & Sabır',
              description: 'Mütevazı ve sadık oyuncular sabırla karşılar, soyunma odası dengesini korur.',
            ),
            DialogueOption(
              id: 'role_harsh_reality',
              title: 'Şu anki formunla ilk 11’i hak etmiyorsun. Formayı ancak antrenmanda savaşarak kaparsın.',
              tone: '🧱 Katı Gerçeklik',
              description: 'Taviz vermeyen tutum. Asi oyuncularla kriz yaratabilir ama profesyonel oyuncuları kamçılar.',
            ),
          ],
        ),

        // 3. Gelişim & Özel Çalışma
        DialogueTopic(
          id: 'topic_training',
          category: DialogueTopicCategory.training,
          title: 'Bireysel Gelişim ve Taktiksel Odak',
          subtitle: 'Niteliklerini geliştirmesi için özel antrenman ödevi ver.',
          icon: '⚡',
          options: [
            DialogueOption(
              id: 'train_technique_mentality',
              title: 'Teknik zekânı ve karar verme hızını geliştirmek için ekstra taktik seanslarına katılmanı istiyorum.',
              tone: '🧠 Taktik & Mental Gelişim',
              description: 'Mentalite ve teknik niteliklere anlık gelişim bonusu kazandırır.',
            ),
            DialogueOption(
              id: 'train_physical_pace',
              title: 'İkili mücadelelerde ve patlayıcı güçte rakipleri ezmen için ekstra salon programı yazıyorum.',
              tone: '🏋️ Fiziksel & Kondisyon Yüklemesi',
              description: 'Fiziksel güce ve patlayıcılığa odaklanır; kondisyon tüketir.',
            ),
            DialogueOption(
              id: 'train_relax',
              title: 'Son zamanlarda çok yıprandın. Bu hafta sana özel hafif rejenerasyon programı uyguluyoruz.',
              tone: '☕ Dinlenme & Rejenerasyon',
              description: 'Kondisyonu yeniler, sakatlık riskini düşürür.',
            ),
          ],
        ),

        // 4. Liderlik & Soyunma Odası
        DialogueTopic(
          id: 'topic_leadership',
          category: DialogueTopicCategory.leadership,
          title: 'Soyunma Odası Atmosferi ve Liderlik',
          subtitle: 'Takım arkadaşlarını motive etmesi ve kulüp kültürünü taşıması için görev ver.',
          icon: '🛡️',
          options: [
            DialogueOption(
              id: 'lead_rally_team',
              title: 'Soyunma odasında gençlere ve yeni gelenlere abilik yap, takımı tek yürek halinde tutmanı bekliyorum.',
              tone: '🗣️ Takımı Toparlama Görevi',
              description: 'Lider ve sadık oyuncularda soyunma odası barına doğrudan (+6-+12) destek sağlar.',
            ),
            DialogueOption(
              id: 'lead_protect_manager',
              title: 'Yönetim ve taraftar baskısı artsa da biz bir aileyiz. Sahaya çıkıp kulübün onurunu koruyacağız.',
              tone: '🔥 Kulüp Ruhunu Savunma',
              description: 'Takım aidiyetini ve oyuncunun kulübe bağlılığını derinleştirir.',
            ),
          ],
        ),
      ];
    } else {
      // Transfer Hedefi / Rakip Oyuncu
      return const [
        // 1. Transfer İknası & Vizyon
        DialogueTopic(
          id: 'topic_transfer_persuasion',
          category: DialogueTopicCategory.transferPersuasion,
          title: 'Kulüp Vizyonu ve Transfer İkna Mülakatı',
          subtitle: 'Oyuncuyu projenize inandırarak bonservis ve maaş talebinde indirim sağlayın.',
          icon: '🤝',
          isOwnedOnly: false,
          options: [
            DialogueOption(
              id: 'trans_vision_trophies',
              title: 'Kulübümüz hızla yükselen bir hanedan inşa ediyor. Bizimle ligi ve kupaları domine edebilirsin!',
              tone: '🏆 Şampiyonluk & Başarı Vizyonu',
              description: 'Hırslı, profesyonel ve lider oyuncuları çok etkiler. Transfer maliyetinde %10-%20 indirim sağlar.',
            ),
            DialogueOption(
              id: 'trans_financial_splurge',
              title: 'Bütçemiz hazır. Seni kulübün en yüksek maaşlı yıldızlarından biri yapmaya ve bol bonus vermeye hazırız.',
              tone: '💰 Cazip Finansal Teklif',
              description: 'Özellikle paragöz ve asi oyuncuları derhal ikna eder; transfer kabul şansını zirveye çıkarır.',
            ),
            DialogueOption(
              id: 'trans_starter_core',
              title: 'Takımımızın oyun planı tamamen senin yeteneklerin etrafında kurulacak. 1. dakikadan itibaren sahadaki komutanımız sensin.',
              tone: '👑 Kilit Oyuncu Statüsü',
              description: 'Hırslı ve duygusal oyuncuları etkileyerek transfer isteklerini perçinler.',
            ),
          ],
        ),

        // 2. Karakter & Mentalite Keşfi
        DialogueTopic(
          id: 'topic_character_scout',
          category: DialogueTopicCategory.characterScout,
          title: 'Karakter ve Zihniyet Mülakatı',
          subtitle: 'Oyuncunun gizli kişilik dinamiklerini, sadakatini ve profesyonellik seviyesini test edin.',
          icon: '🔍',
          isOwnedOnly: false,
          options: [
            DialogueOption(
              id: 'scout_pressure_test',
              title: 'Tribünlerin homurdandığı, skorun geride olduğu 90. dakikada sorumluluk almaktan korkar mısın?',
              tone: '🎯 Baskı Altında Karakter Testi',
              description: 'Oyuncunun mental dayanıklılığını ve liderlik kapasitesini açığa çıkarır.',
            ),
            DialogueOption(
              id: 'scout_loyalty_check',
              title: 'Daha büyük bir kulüpten cazip bir teklif gelirse bizi yarı yolda bırakır mısın?',
              tone: '⚖️ Sadakat & Profesyonellik Sorgusu',
              description: 'Sadakat ve karakter eğilimlerini öğrenmenizi sağlar.',
            ),
          ],
        ),
      ];
    }
  }

  /// Seçilen seçeneği oyuncunun kişiliğine göre simüle eder ve oyun içi sonuçları üretir
  static DialogueResult evaluateChoice({
    required Player player,
    required DialogueTopic topic,
    required DialogueOption option,
    required int clubCash,
    required int clubLockerRoom,
  }) {
    final pType = player.personality;
    final buffer = StringBuffer();
    final deltas = <String>[];

    int deltaMorale = 0;
    int deltaLoyalty = 0;
    double deltaForm = 0.0;
    int deltaSharpness = 0;
    int deltaFitness = 0;
    int deltaLockerRoom = 0;
    int deltaCash = 0;
    int transferDiscountPercent = 0;
    String? statBoost;
    int statBoostAmount = 0;
    String reaction = '😎';

    switch (option.id) {
      // 1.1 Övgü & Coşku
      case 'perf_praise':
        if (pType == PersonalityType.temperamental || pType == PersonalityType.ambitious) {
          deltaMorale = 18;
          deltaForm = 0.6;
          deltaSharpness = 5;
          reaction = '🔥';
          buffer.write('"Hocam bu güveninizi boşa çıkarmayacağım! Sahaya çıktığımda her şeyimi vereceğime söz veriyorum."');
        } else if (pType == PersonalityType.humble || pType == PersonalityType.professional) {
          deltaMorale = 10;
          deltaForm = 0.3;
          reaction = '🤝';
          buffer.write('"Teşekkürler hocam. Bu sadece benim değil, tüm takımın ortak emeği. Aynen devam edeceğim."');
        } else if (pType == PersonalityType.rebel) {
          deltaMorale = 8;
          reaction = '😏';
          buffer.write('"Biliyorum hocam, sahanın en iyisi bendim zaten. İzlemeye devam edin."');
        } else {
          deltaMorale = 12;
          deltaForm = 0.4;
          reaction = '👏';
          buffer.write('"Güveniniz için teşekkürler patron! Takım için elimden gelenin en iyisini yapmaya devam edeceğim."');
        }
        break;

      // 1.2 Taktiksel & Mantıklı
      case 'perf_constructive':
        if (pType == PersonalityType.professional || pType == PersonalityType.leader) {
          deltaMorale = 8;
          deltaSharpness = 10;
          deltaForm = 0.5;
          statBoost = 'MEN';
          statBoostAmount = 1;
          reaction = '🧠';
          buffer.write('"Tam olarak üzerinde düşündüğüm noktaya değindiniz hocam. Taktiksel detayları analiz edip bir sonraki maçta daha kusursuz olacağım."');
        } else if (pType == PersonalityType.temperamental) {
          deltaMorale = -4;
          reaction = '😕';
          buffer.write('"Elimden geleni yapıyorum ama bazen şans yanımda olmuyor... Yine de deneyeceğim."');
        } else {
          deltaMorale = 6;
          deltaSharpness = 6;
          reaction = '👍';
          buffer.write('"Haklısınız hocam, videolara bakıp o pozisyonları düzelteceğim."');
        }
        break;

      // 1.3 Sert Disiplin Uyarısı
      case 'perf_warning':
        if (pType == PersonalityType.rebel) {
          deltaMorale = -22;
          deltaLoyalty = -10;
          deltaLockerRoom = -5;
          reaction = '😠';
          buffer.write('"Beni günah keçisi yapamazsınız! Takımda yürüyen o kadar adam varken suçu bana yıkamazsınız!"');
        } else if (pType == PersonalityType.temperamental) {
          deltaMorale = -18;
          deltaForm = -0.5;
          reaction = '😢';
          buffer.write('"Bütün baskıyı benim üzerime kurmanız haksızlık... Motivasyonumu tamamen kırıyorsunuz."');
        } else if (pType == PersonalityType.ambitious || pType == PersonalityType.professional) {
          deltaMorale = 5;
          deltaSharpness = 12;
          deltaForm = 0.7;
          reaction = '😤';
          buffer.write('"Haklısınız, bu seviye bana yakışmadı. Size kim olduğumu bir sonraki maçta sahada göstereceğim!"');
        } else {
          deltaMorale = -8;
          deltaSharpness = 8;
          reaction = '😐';
          buffer.write('"Mesajı aldım hocam. Kendime çeki düzen vereceğim."');
        }
        break;

      // 1.4 Prim Vaadi
      case 'perf_bonus_promise':
        if (clubCash >= 2500) {
          deltaCash = -2500;
          if (pType == PersonalityType.mercenary) {
            deltaMorale = 25;
            deltaSharpness = 15;
            deltaForm = 0.8;
            reaction = '🤑';
            buffer.write('"İşte konuşulması gereken dil bu patron! O maçta kaleyi delip geçeceğim, primi hazırlayın!"');
          } else {
            deltaMorale = 14;
            deltaSharpness = 8;
            reaction = '💰';
            buffer.write('"Teşekkürler hocam! Maddi manevi desteğinizi hissetmek ekstra güç veriyor."');
          }
        } else {
          deltaMorale = -5;
          reaction = '🤨';
          buffer.write('"Hocam kasada para yokken prim vaat etmeniz pek inandırıcı gelmedi açıkçası..."');
        }
        break;

      // 2.1 İlk 11 Garantisi
      case 'role_starter_promise':
        deltaMorale = 20;
        deltaLoyalty = 12;
        reaction = '⭐';
        if (pType == PersonalityType.ambitious) {
          buffer.write('"Aradığım saygı tam olarak bu. Sahada liderliği alıp takımı galibiyete taşıyacağım!"');
        } else {
          buffer.write('"Bu formayı terletmek benim için bir onurdur hocam. Asla yüzünüzü kara çıkarmayacağım."');
        }
        break;

      // 2.2 Rotasyon & Sabır
      case 'role_rotation_patience':
        if (pType == PersonalityType.humble || pType == PersonalityType.loyal) {
          deltaMorale = 10;
          deltaLoyalty = 8;
          deltaLockerRoom = 4;
          reaction = '🤝';
          buffer.write('"Anlıyorum hocam. Kulübün başarısı her şeyden önemli, bana ne zaman görev verirseniz hazırım."');
        } else if (pType == PersonalityType.ambitious || pType == PersonalityType.rebel) {
          deltaMorale = -12;
          deltaLoyalty = -6;
          reaction = '😒';
          buffer.write('"Ben yedek kulübesinde çürüyecek oyuncu değilim. Süre alamazsam menajerimle konuşmak zorunda kalırım."');
        } else {
          deltaMorale = 4;
          reaction = '👌';
          buffer.write('"Pekala patron, sıramı bekleyeceğim ve fırsat geldiğinde değerlendireceğim."');
        }
        break;

      // 2.3 Katı Gerçeklik
      case 'role_harsh_reality':
        if (pType == PersonalityType.professional) {
          deltaMorale = 4;
          deltaSharpness = 12;
          reaction = '🏋️';
          buffer.write('"Dürüstlüğünüze saygı duyuyorum. Antrenman temposunu iki katına çıkarıp o formayı söke söke alacağım."');
        } else if (pType == PersonalityType.rebel || pType == PersonalityType.temperamental) {
          deltaMorale = -20;
          deltaLoyalty = -15;
          reaction = '🚪';
          buffer.write('"Bana bu tavırla yaklaşırsanız takıma hiçbir faydam dokunmaz. Ocak ayında transfer listesine konmak istiyorum!"');
        } else {
          deltaMorale = -6;
          deltaSharpness = 6;
          reaction = '🤐';
          buffer.write('"Anlaşıldı hocam, çok daha fazla çalışmam gerekiyor."');
        }
        break;

      // 3.1 Taktik & Mental Gelişim
      case 'train_technique_mentality':
        deltaSharpness = 8;
        deltaMorale = 6;
        statBoost = 'TEC';
        statBoostAmount = 1;
        reaction = '🪄';
        buffer.write('"Taktik analiz ve karar alma üzerine çalışmak oyun zekâmı bir üst seviyeye taşıyacak. Hemen başlıyorum!"');
        break;

      // 3.2 Fiziksel & Kondisyon
      case 'train_physical_pace':
        deltaFitness = -8;
        deltaSharpness = 10;
        statBoost = 'PHY';
        statBoostAmount = 1;
        reaction = '💪';
        buffer.write('"Kas kütlesini ve patlayıcı gücü artırmak tam da aradığım şeydi. Sahada kimse beni yıkamayacak!"');
        break;

      // 3.3 Dinlenme
      case 'train_relax':
        deltaFitness = 18;
        deltaMorale = 12;
        reaction = '🔋';
        buffer.write('"Nefes almaya gerçekten çok ihtiyacım vardı patron. Önümüzdeki maça %100 zinde çıkacağım!"');
        break;

      // 4.1 Takımı Toparlama
      case 'lead_rally_team':
        if (pType == PersonalityType.leader || pType == PersonalityType.professional || pType == PersonalityType.loyal) {
          deltaLockerRoom = 12;
          deltaMorale = 15;
          deltaLoyalty = 10;
          reaction = '🛡️';
          buffer.write('"Bana güvenebilirsiniz hocam. Soyunma odasında kimsenin kafasını eğmesine izin vermeyeceğim, tek yumruk olacağız!"');
        } else {
          deltaLockerRoom = 4;
          deltaMorale = 6;
          reaction = '🗣️';
          buffer.write('"Elimden geldiğince arkadaşlara destek olmaya çalışırım hocam."');
        }
        break;

      // 4.2 Kulüp Ruhunu Savunma
      case 'lead_protect_manager':
        deltaLoyalty = 15;
        deltaMorale = 10;
        deltaLockerRoom = 6;
        reaction = '🔥';
        buffer.write('"Bu kulübün armasını gururla taşıyoruz. Sahaya çıkıp kimin patron olduğunu herkese göstereceğiz!"');
        break;

      // --- TRANSFER HEDEFLERİ ---
      // 5.1 Şampiyonluk Vizyonu
      case 'trans_vision_trophies':
        if (pType == PersonalityType.ambitious || pType == PersonalityType.leader) {
          transferDiscountPercent = 20;
          reaction = '🏆';
          buffer.write('"Kupa kaldırmak ve tarih yazmak tam da kariyerimde aradığım sıçrama! Projeniz beni çok heyecanlandırdı, transfer şartlarında fedakarlık yapmaya hazırım."');
        } else {
          transferDiscountPercent = 10;
          reaction = '🌟';
          buffer.write('"Kulübünüzün hedefleri etkileyici. Böyle bir projede yer almak benim için onur olur."');
        }
        break;

      // 5.2 Finansal Cazibe
      case 'trans_financial_splurge':
        if (pType == PersonalityType.mercenary || pType == PersonalityType.rebel) {
          transferDiscountPercent = 25;
          reaction = '💎';
          buffer.write('"Bana hak ettiğim değeri verecek bir kulüple çalışmaktan mutluluk duyarım. Menajerimle hemen el sıkışabilirsiniz!"');
        } else {
          transferDiscountPercent = 10;
          reaction = '🤝';
          buffer.write('"Cömert teklifiniz için teşekkürler. Şartlar gayet tatmin edici görünüyor."');
        }
        break;

      // 5.3 Kilit Oyuncu Statüsü
      case 'trans_starter_core':
        if (pType == PersonalityType.ambitious || pType == PersonalityType.temperamental) {
          transferDiscountPercent = 18;
          reaction = '👑';
          buffer.write('"Bana takımın merkezinde olma fırsatı vermeniz benim için paradan daha değerli. Bu formayı sırtıma geçirmek için sabırsızlanıyorum!"');
        } else {
          transferDiscountPercent = 10;
          reaction = '🎯';
          buffer.write('"Saha içi rolümün net olması çok sevindirici. Kulübünüze katılmaktan memnuniyet duyarım."');
        }
        break;

      // 6.1 Baskı Testi
      case 'scout_pressure_test':
        if (pType == PersonalityType.leader || pType == PersonalityType.ambitious) {
          reaction = '🦁';
          buffer.write('"Baskı benim için yakıttır hocam. Taraftar ıslıkladığında veya maç zora girdiğinde saklanmam, topu ben isterim!"');
        } else if (pType == PersonalityType.temperamental) {
          reaction = '🫣';
          buffer.write('"Dürüst olmak gerekirse tribünlerin homurdanması bazen beni geriyor ama takım desteğiyle üstesinden gelmeye çalışıyorum."');
        } else {
          reaction = '⚖️';
          buffer.write('"Her maçın stresi farklıdır ama sahada elimden gelenin en iyisini yapmaya odaklanırım."');
        }
        break;

      // 6.2 Sadakat Sorgusu
      case 'scout_loyalty_check':
        if (pType == PersonalityType.loyal || pType == PersonalityType.humble) {
          reaction = '🤝';
          buffer.write('"Beni transfer eden ve bana inanan kulübü asla yarı yolda bırakmam. İmza attıysam sonuna kadar savaşırım."');
        } else if (pType == PersonalityType.mercenary) {
          reaction = '💼';
          buffer.write('"Futbol profesyonel bir iş. Şartlar iki taraf için de uygun olduğu sürece en iyimi veririm, gerisine zaman karar verir."');
        } else {
          reaction = '📜';
          buffer.write('"Sözleşmeme ve kulübün menfaatlerine her zaman saygı gösteririm."');
        }
        break;

      default:
        buffer.write('"Söylediklerinizi not aldım hocam. Sahada görüşürüz."');
    }

    // Deltaları Özetle
    if (deltaMorale > 0) deltas.add('+$deltaMorale Moral');
    if (deltaMorale < 0) deltas.add('$deltaMorale Moral');
    if (deltaLoyalty > 0) deltas.add('+$deltaLoyalty Sadakat');
    if (deltaLoyalty < 0) deltas.add('$deltaLoyalty Sadakat');
    if (deltaForm > 0.0) deltas.add('+${deltaForm.toStringAsFixed(1)} Form');
    if (deltaForm < 0.0) deltas.add('${deltaForm.toStringAsFixed(1)} Form');
    if (deltaSharpness > 0) deltas.add('+$deltaSharpness Keskinlik');
    if (deltaFitness > 0) deltas.add('+$deltaFitness Kondisyon');
    if (deltaFitness < 0) deltas.add('$deltaFitness Kondisyon');
    if (deltaLockerRoom > 0) deltas.add('+$deltaLockerRoom Soyunma Odası');
    if (deltaLockerRoom < 0) deltas.add('$deltaLockerRoom Soyunma Odası');
    if (deltaCash < 0) deltas.add('-₣${deltaCash.abs()} Kasa');
    if (transferDiscountPercent > 0) deltas.add('%$transferDiscountPercent Transfer İndirimi');
    if (statBoost != null && statBoostAmount > 0) deltas.add('+$statBoostAmount $statBoost');

    return DialogueResult(
      playerReplyText: buffer.toString(),
      reactionEmoji: reaction,
      deltaMorale: deltaMorale,
      deltaLoyalty: deltaLoyalty,
      deltaForm: deltaForm,
      deltaSharpness: deltaSharpness,
      deltaFitness: deltaFitness,
      deltaLockerRoom: deltaLockerRoom,
      deltaCash: deltaCash,
      transferDiscountPercent: transferDiscountPercent,
      statBoostAttribute: statBoost,
      statBoostAmount: statBoostAmount,
      summaryDeltas: deltas,
    );
  }
}
