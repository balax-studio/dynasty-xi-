// domain/generation/name_pools.dart
// Pure Dart. Name, surname, fictional city and NPC character databases.

class NamePools {
  static const List<String> trFirstNames = [
    'Ahmet', 'Mehmet', 'Mustafa', 'Emre', 'Burak', 'Kaan', 'Arda', 'Cem',
    'Deniz', 'Efe', 'Ege', 'Eren', 'Furkan', 'Hakan', 'Halil', 'İbrahim',
    'Kerem', 'Koray', 'Levent', 'Mert', 'Murat', 'Onur', 'Ozan', 'Özgür',
    'Sercan', 'Serkan', 'Sinan', 'Taner', 'Tolga', 'Uğur', 'Ümit', 'Volkan',
    'Yiğit', 'Yusuf', 'Barış', 'Berk', 'Can', 'Doruk', 'Gökhan', 'Alper',
    'Batuhan', 'Cihan', 'Doğukan', 'Enes', 'Görkem', 'Harun', 'Kadir', 'Melih',
    'Oğuzhan', 'Ramazan', 'Samet', 'Taha', 'Umut', 'Yasin', 'Zafer'
  ];

  static const List<String> trLastNames = [
    'Yılmaz', 'Demir', 'Kaya', 'Şahin', 'Çelik', 'Yıldız', 'Yıldırım', 'Öztürk',
    'Aydın', 'Özdemir', 'Arslan', 'Doğan', 'Kılıç', 'Aslan', 'Çetin', 'Kara',
    'Koç', 'Kurt', 'Özkan', 'Şimşek', 'Polat', 'Korkmaz', 'Erdoğan', 'Bulut',
    'Güneş', 'Karaca', 'Aksoy', 'Turan', 'Sarı', 'Ateş', 'Bozkurt', 'Çakır',
    'Duman', 'Ekinci', 'Gül', 'Işık', 'Kaplan', 'Mert', 'Sönmez', 'Tekin',
    'Yavuz', 'Aktaş', 'Bayram', 'Coşkun', 'Erdem', 'Güler', 'Karakaya', 'Önal'
  ];

  static const List<String> fictionalCities = [
    'Angora', 'Meriç', 'Selçuk', 'Karaköy', 'Yeşilova', 'Akdeniz', 'Toros',
    'Sakarya', 'Fırat', 'Dicle', 'Ege', 'Marmara', 'Anadolu', 'Çukurova',
    'Karadeniz', 'Hisar', 'Altıntepe', 'Vadi', 'Kuzeyyıldızı', 'Göksu',
    'Bozkır', 'Taşpınar', 'Enderun', 'Beylerbeyi', 'Yelkenli'
  ];

  static const List<String> clubSuffixes = [
    'spor', ' FK', ' Gücü', ' İdman Yurdu', ' Birlik', ' Gençlik', ' Yıldızları'
  ];

  static const List<String> badgeIcons = [
    'SHIELD', 'BOLT', 'EAGLE', 'LION', 'STAR', '[KUPA]', 'ANCHOR', 'SWORDS', '', '[FORM]', 'CROWN', 'WOLF'
  ];

  static const List<String> primaryColors = [
    '#0B2E20', '#1E3A8A', '#991B1B', '#7C2D12', '#14532D', '#4C1D95',
    '#0F172A', '#831843', '#164E63', '#713F12', '#365314', '#581C87'
  ];

  static const List<String> secondaryColors = [
    '#D9A62E', '#F2C75C', '#E23D3D', '#2FBF71', '#38BDF8', '#F472B6',
    '#FBBF24', '#A78BFA', '#34D399', '#FB923C', '#F3F4F6', '#94A3B8'
  ];

  /// 12 Kilit NPC Karakter Tanımları — Ek D.3
  static const Map<String, Map<String, String>> coreNpcs = {
    'recep_vardar': {
      'name': 'Recep Vardar',
      'role': 'Kulüp Başkanı',
      'avatar': '',
      'trait': 'Duygusal, sabırsız, popülist.',
    },
    'nihal_aksu': {
      'name': 'Nihal Aksu',
      'role': 'Baş Gazeteci',
      'avatar': '[BASIN]',
      'trait': 'Keskin, adil ama acımasız.',
    },
    'baba_kadir': {
      'name': '"Baba" Kadir',
      'role': 'Ultra Taraftar Lideri',
      'avatar': '[DUYURU]',
      'trait': 'Sadık, ateşli, samimi.',
    },
    'ayse_doktor': {
      'name': 'Dr. Ayşe Tanrıkulu',
      'role': 'Kulüp Doktoru',
      'avatar': '',
      'trait': 'Titiz, koruyucu, bilimsel.',
    },
    'selim_hoca': {
      'name': 'Selim Aydoğan',
      'role': 'Asistan Menajer',
      'avatar': '[RAPOR]',
      'trait': 'Sadık, gerçekçi, taktiksel.',
    },
    'hatice_scout': {
      'name': 'Hatice Ergin',
      'role': 'Baş Scout',
      'avatar': '[ARAMA]',
      'trait': 'Sezgisel, gizemli, keskin göz.',
    },
    'nazim_hoca': {
      'name': 'Nazım Bey',
      'role': 'Altyapı Direktörü',
      'avatar': '',
      'trait': 'Sabırlı, idealist, yetiştirici.',
    },
    'serdar_mali': {
      'name': 'Serdar Koçak',
      'role': 'Mali Müşavir',
      'avatar': '[MENAJER]',
      'trait': 'Soğuk, sayısal, kuralcı.',
    },
    'bulent_menajer': {
      'name': 'Bülent Tosun',
      'role': 'Oyuncu Temsilcisi (Ajan)',
      'avatar': '',
      'trait': 'Kurnaz, ısrarcı, fırsatçı.',
    },
    'zeynep_sponsor': {
      'name': 'Zeynep Arık',
      'role': 'Sponsorluk Direktörü',
      'avatar': '[ANLASMA]',
      'trait': 'Profesyonel, hırslı, kurumsal.',
    },
    'cemal_usta': {
      'name': 'Cemal Usta',
      'role': 'Saha Bakım Sorumlusu',
      'avatar': '',
      'trait': 'Yaşlı, bilge, kulüp hafızası.',
    },
    'deniz_medya': {
      'name': 'Deniz Aktaş',
      'role': 'Sosyal Medya Direktörü',
      'avatar': '',
      'trait': 'Genç, hızlı, trend odaklı.',
    },
  };
}
