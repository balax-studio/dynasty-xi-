// domain/president/board_factions.dart
// Boardroom Political Factions, Loyalty Ratings, and Early Election Kongre Motions.

enum BoardFactionType {
  traditionalists,   // Muhafazakar Sanayiciler & Eski Üyeler (Mali Disiplin)
  youngTycoons,      // Genç Milyonerler & Risk Sermayedarları (Yıldız Transfer & Hızlı Büyüme)
  independentBlock,  // Bağımsız Taraftar Temsilcileri & Delegeler
}

class BoardMember {
  final String id;
  final String name;
  final String role;
  final String avatar;
  final BoardFactionType faction;
  final int votingPowerPercent; // % oy ağırlığı
  final int loyaltyScore;       // 0-100 başkana sadakat
  final String philosophy;

  const BoardMember({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    required this.faction,
    required this.votingPowerPercent,
    required this.loyaltyScore,
    required this.philosophy,
  });
}

class BoardFactionsState {
  final List<BoardMember> members;
  final int generalAssemblySupportPercent; // Genel Kurul Delege Desteği (0-100)
  final bool isEarlyElectionMotionActive;

  const BoardFactionsState({
    required this.members,
    required this.generalAssemblySupportPercent,
    this.isEarlyElectionMotionActive = false,
  });

  static BoardFactionsState createInitialState() {
    return const BoardFactionsState(
      generalAssemblySupportPercent: 68,
      isEarlyElectionMotionActive: false,
      members: [
        BoardMember(
          id: 'member_1',
          name: 'Hacı Veli Bey',
          role: '2. Başkan / Sanayi Grubu Lideri',
          avatar: '',
          faction: BoardFactionType.traditionalists,
          votingPowerPercent: 28,
          loyaltyScore: 75,
          philosophy: 'Mali disiplin esastır. Borçlanmaya ve lüks transfere karşıdır.',
        ),
        BoardMember(
          id: 'member_2',
          name: 'Bora Tekin',
          role: 'Asbaşkan / Teknoloji Yatırımcısı',
          avatar: '[MENAJER]',
          faction: BoardFactionType.youngTycoons,
          votingPowerPercent: 24,
          loyaltyScore: 60,
          philosophy: 'Yıldız oyuncu getirelim, formalar satsın, dünya çapında ses getirelim.',
        ),
        BoardMember(
          id: 'member_3',
          name: 'Av. Selin Gök',
          role: 'Genel Sekreter & Hukuk İşleri',
          avatar: '[HUKUK]',
          faction: BoardFactionType.independentBlock,
          votingPowerPercent: 18,
          loyaltyScore: 80,
          philosophy: 'Tüzüğe ve mevzuata tam uyum ister; lobicilik faaliyetlerini yönetir.',
        ),
        BoardMember(
          id: 'member_4',
          name: 'Murat Reis',
          role: 'Tribün & Altyapı Sorumlusu',
          avatar: '',
          faction: BoardFactionType.independentBlock,
          votingPowerPercent: 15,
          loyaltyScore: 70,
          philosophy: 'Gençler oynasın, bilet fiyatları ucuz tutulsun, taraftar küstürülmesin.',
        ),
        BoardMember(
          id: 'member_5',
          name: 'Kemal Zengin',
          role: 'Mali İşler & Muhasebe Üyesi',
          avatar: '',
          faction: BoardFactionType.traditionalists,
          votingPowerPercent: 15,
          loyaltyScore: 50,
          philosophy: 'Her kuruşun hesabını sorar. Harcamalar bütçeyi aşarsa muhalefet başlatır.',
        ),
      ],
    );
  }

  int get totalPresidentialSupportPercent {
    int total = 0;
    for (final m in members) {
      if (m.loyaltyScore >= 50) {
        total += m.votingPowerPercent;
      }
    }
    return total;
  }
}
