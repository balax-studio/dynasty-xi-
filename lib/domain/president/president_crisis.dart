// domain/president/president_crisis.dart
// Executive Crisis Management, Urgent Red Telephone Calls, and Ref Tunnel Confrontations.

enum CrisisCallerType {
  policeChief,       // İl Emniyet Müdürü
  mayor,             // Belediye Başkanı
  federationHead,    // TFF / Federasyon Başkanı
  ultraLeader,       // Amigo / Tribün Lideri
  rivalPresident,    // Ezeli Rakip Kulüp Başkanı
  starPlayerAgent,   // Yıldız Oyuncu Menajeri
}

class CrisisChoice {
  final String title;
  final String description;
  final int cashDelta;
  final int fansDelta;
  final int lockerRoomDelta;
  final int boardTrustDelta;
  final String outcomeMessage;

  const CrisisChoice({
    required this.title,
    required this.description,
    this.cashDelta = 0,
    this.fansDelta = 0,
    this.lockerRoomDelta = 0,
    this.boardTrustDelta = 0,
    required this.outcomeMessage,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'cashDelta': cashDelta,
        'fansDelta': fansDelta,
        'lockerRoomDelta': lockerRoomDelta,
        'boardTrustDelta': boardTrustDelta,
        'outcomeMessage': outcomeMessage,
      };

  factory CrisisChoice.fromJson(Map<String, dynamic> json) => CrisisChoice(
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        cashDelta: json['cashDelta'] as int? ?? 0,
        fansDelta: json['fansDelta'] as int? ?? 0,
        lockerRoomDelta: json['lockerRoomDelta'] as int? ?? 0,
        boardTrustDelta: json['boardTrustDelta'] as int? ?? 0,
        outcomeMessage: json['outcomeMessage'] as String? ?? '',
      );
}

class PresidentCrisisCall {
  final String id;
  final CrisisCallerType caller;
  final String callerName;
  final String callerTitle;
  final String callerAvatar;
  final String dialogQuote;
  final List<CrisisChoice> choices;

  const PresidentCrisisCall({
    required this.id,
    required this.caller,
    required this.callerName,
    required this.callerTitle,
    required this.callerAvatar,
    required this.dialogQuote,
    required this.choices,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'caller': caller.index,
        'callerName': callerName,
        'callerTitle': callerTitle,
        'callerAvatar': callerAvatar,
        'dialogQuote': dialogQuote,
        'choices': choices.map((c) => c.toJson()).toList(),
      };

  factory PresidentCrisisCall.fromJson(Map<String, dynamic> json) => PresidentCrisisCall(
        id: json['id'] as String? ?? '',
        caller: CrisisCallerType.values[(json['caller'] as int?) ?? 0],
        callerName: json['callerName'] as String? ?? '',
        callerTitle: json['callerTitle'] as String? ?? '',
        callerAvatar: json['callerAvatar'] as String? ?? '',
        dialogQuote: json['dialogQuote'] as String? ?? '',
        choices: (json['choices'] as List<dynamic>?)
                ?.map((e) => CrisisChoice.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  static List<PresidentCrisisCall> getPredefinedCalls() {
    return [
      const PresidentCrisisCall(
        id: 'police_derby_security',
        caller: CrisisCallerType.policeChief,
        callerName: 'Emniyet Müdürü Kemal',
        callerTitle: 'İl Güvenlik Şube Müdürü',
        callerAvatar: '',
        dialogQuote: 'Sayın Başkan, derbi öncesi rakip taraftarlarla bizim holiganlar meydanda toplanıyor. Maç günü 500 özel güvenlik kiralamazsanız tribünleri kapatırım!',
        choices: [
          CrisisChoice(
            title: 'Özel Güvenlik Fonu Ayır (50.000 €)',
            description: 'Masrafı karşılayarak stadyumu güvenceye al.',
            cashDelta: -50000,
            boardTrustDelta: 5,
            fansDelta: 3,
            outcomeMessage: 'Emniyet memnun oldu, maç olaysız geçti.',
          ),
          CrisisChoice(
            title: 'Emniyete Rest Çek ("Bu sizin göreviniz")',
            description: 'Devletin polisine güven ve para ödemeyi reddet.',
            fansDelta: 5,
            boardTrustDelta: -5,
            outcomeMessage: 'Tribünlerde ufak arbede çıktı, federasyon para cezası kesti.',
          ),
          CrisisChoice(
            title: 'Tribün Liderlerini Çağırıp Uyar',
            description: 'Amigolarla bizzat görüşüp sağduyu çağrısı yap.',
            lockerRoomDelta: 3,
            fansDelta: -2,
            outcomeMessage: 'Holiganlar sakinleşti ama amigo lideri bedava bilet talep etti.',
          ),
        ],
      ),
      const PresidentCrisisCall(
        id: 'mayor_stadium_metro',
        caller: CrisisCallerType.mayor,
        callerName: 'Büyükşehir Belediye Başkanı',
        callerTitle: 'Büyükşehir Belediyesi',
        callerAvatar: '[YÖNETİM]',
        dialogQuote: 'Başkanım, stadın önüne metro durağı projemiz var. Fakat kulüp olarak altyapı fonuna 75.000 € katkı vermeniz gerekiyor, yoksa hat başka mahalleye kayacak.',
        choices: [
          CrisisChoice(
            title: 'Katkı Payını Öde (75.000 €)',
            description: 'Metro hattını stadyumun kapısına getirt.',
            cashDelta: -75000,
            fansDelta: 10,
            boardTrustDelta: 5,
            outcomeMessage: 'Metro durağı stada bağlandı, maç günü seyirci sayısı arttı!',
          ),
          CrisisChoice(
            title: 'Medyada Belediye Başkanını Eleştir',
            description: 'Kamuoyu baskısı oluşturup belediyeyi zorla.',
            fansDelta: 4,
            boardTrustDelta: -8,
            outcomeMessage: 'Siyasi gerilim tırmandı, belediye otopark ruhsatını beklemeye aldı.',
          ),
          CrisisChoice(
            title: 'Stadyum Otopark Gelirlerini Hibe Et',
            description: 'Nakit vermeden otopark gelirini 1 yıllık belediyeye devret.',
            cashDelta: -20000,
            boardTrustDelta: 3,
            outcomeMessage: 'Protokol imzalandı, metro inşaatı başladı.',
          ),
        ],
      ),
      const PresidentCrisisCall(
        id: 'tff_referee_scandal',
        caller: CrisisCallerType.federationHead,
        callerName: 'Federasyon Başkanı',
        callerTitle: 'TFF Yönetim Kurulu',
        callerAvatar: '[HUKUK]',
        dialogQuote: 'Sayın Başkan, dünkü hakem açıklamalarınız sınırları aştı. Disiplin Kurulu 45 gün hak mahrumiyeti hazırlıyor. Basın toplantısında geri adım atacak mısınız?',
        choices: [
          CrisisChoice(
            title: 'Geri Adım At ve Özür Dile',
            description: 'Cezayı iptal ettir ama taraftar nezdinde zayıf görün.',
            fansDelta: -6,
            boardTrustDelta: 6,
            outcomeMessage: 'Federasyon cezayı kaldırdı ama taraftar öfkeli.',
          ),
          CrisisChoice(
            title: 'Daha Sert Açıklama Yap ("Hodri Meydan")',
            description: 'Federasyonun üzerine git, savaş ilan et.',
            fansDelta: 12,
            boardTrustDelta: -10,
            lockerRoomDelta: 5,
            outcomeMessage: 'Taraftar arkanızda kenetlendi, takım hırslandı!',
          ),
          CrisisChoice(
            title: 'Kapalı Kapılar Ardında Lobi Yap',
            description: 'Federasyon binasında gizli yemek ye.',
            cashDelta: -25000,
            boardTrustDelta: 2,
            outcomeMessage: 'Gizli uzlaşma sağlandı, ceza sembolik para cezasına çevrildi.',
          ),
        ],
      ),
      const PresidentCrisisCall(
        id: 'ultra_free_tickets',
        caller: CrisisCallerType.ultraLeader,
        callerName: 'Amigo Reis',
        callerTitle: 'Tribün Derneği Lideri',
        callerAvatar: '[DUYURU]',
        dialogQuote: 'Büyük Başkan! Deplasman tribünü için 2.000 bedava bilet ve 10 otobüs parası istiyoruz. Vermezseniz hafta sonu tribünler "Yönetim İstifa" diye inler!',
        choices: [
          CrisisChoice(
            title: 'Otobüs ve Biletleri Karşıla (30.000 €)',
            description: 'Tribün liderlerini memnun et ve tezahürat desteği al.',
            cashDelta: -30000,
            fansDelta: 8,
            boardTrustDelta: -4,
            outcomeMessage: 'Deplasman tribünü 90 dakika "Büyük Başkan" diye bağırdı.',
          ),
          CrisisChoice(
            title: 'Talebi Reddet ve Güvenliği Artır',
            description: 'Şantaja boyun eğme, tribün terörüne dur de.',
            fansDelta: -8,
            boardTrustDelta: 8,
            lockerRoomDelta: 3,
            outcomeMessage: 'Tribün 10 dakika istifa diye bağırdı ama yönetim duruşunuzu takdir etti.',
          ),
          CrisisChoice(
            title: 'Pazarlık Yap (Yalnızca 5 Otobüs)',
            description: 'Orta yolda anlaşarak ortamı yumuşat.',
            cashDelta: -15000,
            fansDelta: 2,
            outcomeMessage: 'Tribünler tatmin oldu, dostane anlaşma sağlandı.',
          ),
        ],
      ),
    ];
  }
}

/// Hakem Odası ve Koridor Baskını Sonuç Modeli
class RefTunnelOutcome {
  final String title;
  final String narrative;
  final int refereeBiasDelta; // 2. yarı maç lehte/aleyhte etki
  final int boardTrustDelta;
  final int lockerRoomDelta;
  final int cashFine;

  const RefTunnelOutcome({
    required this.title,
    required this.narrative,
    required this.refereeBiasDelta,
    required this.boardTrustDelta,
    required this.lockerRoomDelta,
    required this.cashFine,
  });

  static RefTunnelOutcome executeConfrontation(int approachIndex) {
    switch (approachIndex) {
      case 0: // Sert Gözdağı
        return const RefTunnelOutcome(
          title: 'Sert Koridor Fırçası',
          narrative: 'Hakemin gözünün içine bakıp "Bu şehirden çıkamazsın" imasında bulundunuz. Hakem korkudan ikinci yarı penaltı çaldı ama federasyon 40.000 € ceza kesti!',
          refereeBiasDelta: 2,
          boardTrustDelta: -5,
          lockerRoomDelta: 6,
          cashFine: 40000,
        );
      case 1: // Diplomatik & Kural Hatası Uyarısı
        return const RefTunnelOutcome(
          title: 'Diplomatik Kural Hatası Uyarısı',
          narrative: 'Hakeme pozisyonun tekrarını tabletle gösterip sakin bir şekilde hakem gözlemcisine şikayet ettiniz. Hakem ikinci yarı daha adil yönetti.',
          refereeBiasDelta: 1,
          boardTrustDelta: 4,
          lockerRoomDelta: 2,
          cashFine: 0,
        );
      case 2: // Hakem Odası Kapısını Yumruklama
      default:
        return const RefTunnelOutcome(
          title: 'Hakem Odası Kapısı Kilitlendi',
          narrative: 'Kapıyı tekmeleyip temsilciye bağırdınız. Olay TV haberlerine düştü. Takım kenetlendi fakat kulüp 1 maç seyircisiz oynama cezası aldı.',
          refereeBiasDelta: 3,
          boardTrustDelta: -10,
          lockerRoomDelta: 8,
          cashFine: 60000,
        );
    }
  }
}
