// domain/president/clubs_association.dart
// Super League Clubs Association Summit, Broadcasting Rights & Coalition Voting

class AssociationSummitAgenda {
  final String id;
  final String title;
  final String description;
  final List<SummitVoteOption> options;

  const AssociationSummitAgenda({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
  });

  static List<AssociationSummitAgenda> getActiveAgendas() {
    return [
      const AssociationSummitAgenda(
        id: 'tv_rights_share',
        title: 'YAYIN GELİRLERİ VE HAVUZ DAĞILIM ORANI',
        description: 'Anadolu kulüpleri havuz gelirlerinin eşit dağıtılmasını, büyük kulüpler ise şampiyonluk ve izlenme oranına göre pay verilmesini talep ediyor.',
        options: [
          SummitVoteOption(
            title: 'BÜYÜK KULÜPLERİN HAKKINI SAVUN (PERFORMANS ODAKLI DAĞILIM)',
            supportPercent: 45,
            cashDelta: 50000,
            boardDelta: 8,
            fansDelta: 5,
            outcomeText: 'Büyük kulüpler bloğu galip geldi! Yayın havuzundan +₣50.000 ekstra gelir elde ettiniz.',
          ),
          SummitVoteOption(
            title: 'ANADOLU KULÜPLERİNE DESTEK VER & BİRLİK SAĞLA',
            supportPercent: 70,
            cashDelta: 15000,
            boardDelta: 4,
            fansDelta: 10,
            outcomeText: 'Kulüpler Birliği başkanı olarak seçilme ihtimaliniz güçlendi. Ligde büyük saygı kazandınız.',
          ),
        ],
      ),
      const AssociationSummitAgenda(
        id: 'foreign_player_limit',
        title: 'YABANCI OYUNCU KONTENJANI OYLAMASI',
        description: 'TFF yabancı sınırını 8\'e düşürmek istiyor. Kulüpler Birliği serbest piyasa (14 yabancı) talep ediyor.',
        options: [
          SummitVoteOption(
            title: 'SERBESTLİK İÇİN BİRLİK İLE BİRLİKTE TFF\'YE REST ÇEK',
            supportPercent: 85,
            cashDelta: 0,
            boardDelta: 10,
            fansDelta: 8,
            outcomeText: 'TFF geri adım attı ve 14 yabancı serbestliği devam ettirildi!',
          ),
          SummitVoteOption(
            title: 'YERLİ TEŞVİK PRİMİ İSTEYEREK UZLAŞ',
            supportPercent: 55,
            cashDelta: 25000,
            boardDelta: 5,
            fansDelta: 4,
            outcomeText: 'Yerli oyuncu oynatan kulüplere ek federasyon teşvik primi bağlandı.',
          ),
        ],
      ),
    ];
  }
}

class SummitVoteOption {
  final String title;
  final int supportPercent;
  final int cashDelta;
  final int boardDelta;
  final int fansDelta;
  final String outcomeText;

  const SummitVoteOption({
    required this.title,
    required this.supportPercent,
    required this.cashDelta,
    required this.boardDelta,
    required this.fansDelta,
    required this.outcomeText,
  });
}
