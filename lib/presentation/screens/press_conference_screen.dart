// presentation/screens/press_conference_screen.dart
// Dedicated full-screen Press Conference & Media Simulator screen for Club Chairman.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';

class PressConferenceScreen extends StatefulWidget {
  const PressConferenceScreen({super.key});

  @override
  State<PressConferenceScreen> createState() => _PressConferenceScreenState();
}

class _PressConferenceScreenState extends State<PressConferenceScreen> {
  int _questionIndex = 0;

  final List<({
    String journalist,
    String outlet,
    String question,
    List<({String text, int deltaFans, int deltaLockerRoom, int deltaBoardTrust, String log})> options
  })> _questions = const [
    (
      journalist: 'Ahmet Yılmaz',
      outlet: 'SPOR TV',
      question: 'Sayın Başkan, bu sezon transfer bütçesini yetersiz bulan taraftarlar var. Ne düşünüyorsunuz?',
      options: [
        (
          text: 'Kulübümüzün mali istikrarı her şeyden önemlidir. Hesapsız harcama yapmayız.',
          deltaFans: -3,
          deltaLockerRoom: 0,
          deltaBoardTrust: 5,
          log: 'Başkan mali disiplin vurgusu yaptı.'
        ),
        (
          text: 'Gerektiğinde elimizi taşın altına koyar, en büyük yıldızları takıma katarız!',
          deltaFans: 8,
          deltaLockerRoom: 2,
          deltaBoardTrust: -4,
          log: 'Başkan taraftara transfer sözü verdi.'
        ),
        (
          text: 'Bu konuları basın önünde değil, yönetim odasında konuşuruz.',
          deltaFans: 0,
          deltaLockerRoom: 0,
          deltaBoardTrust: 1,
          log: 'Başkan soruları yanıtlamaktan kaçındı.'
        ),
      ],
    ),
    (
      journalist: 'Elif Kaya',
      outlet: 'FUTBOL GAZETESİ',
      question: 'Teknik Direktörünüzün son haftalardaki performansından memnun musunuz?',
      options: [
        (
          text: 'Hocamıza güvenimiz %100 tamdır. Arkasındayız.',
          deltaFans: 2,
          deltaLockerRoom: 6,
          deltaBoardTrust: 2,
          log: 'Başkan teknik direktöre tam destek açıkladı.'
        ),
        (
          text: 'Futbolda kimse vazgeçilmez değildir. Sonuçlar düzelmezse gereği yapılır.',
          deltaFans: 5,
          deltaLockerRoom: -5,
          deltaBoardTrust: 0,
          log: 'Başkan teknik ekibe ültimatom verdi.'
        ),
      ],
    ),
    (
      journalist: 'Metin Derbi',
      outlet: 'DERBİ ARENA',
      question: 'Gelecek haftaki dev derbi öncesi rakip başkanın iddialı açıklamalarına ne diyorsunuz?',
      options: [
        (
          text: 'Sahada cevabımızı vereceğiz, boş lafa gerek yok! (+%15 Derbi Coşkusu, -₣5.000 Ceza)',
          deltaFans: 12,
          deltaLockerRoom: 5,
          deltaBoardTrust: -2,
          log: 'Başkan derbi öncesi rakip takıma sert meydan okudu!'
        ),
        (
          text: 'Biz Türk futbolunun dostluk ve centilmenlik içinde gelişmesini istiyoruz.',
          deltaFans: -2,
          deltaLockerRoom: 1,
          deltaBoardTrust: 6,
          log: 'Başkan dostluk ve centilmenlik mesajı verdi.'
        ),
      ],
    ),
    (
      journalist: 'Zafer Hakem',
      outlet: 'DÜDÜK SPOR',
      question: 'Son maçtaki hakem kararları kulübünüzün tepkisini çekti. Federasyona başvuracak mısınız?',
      options: [
        (
          text: 'Hakem hataları artık bardağı taşırdı! TFF yönetimine resmi şikayette bulunacağız! (+Yönetim Güven)',
          deltaFans: 8,
          deltaLockerRoom: 4,
          deltaBoardTrust: 4,
          log: 'Başkan federasyon ve hakem yönetimine sert bildiri yayınladı.'
        ),
        (
          text: 'Hakemler de insandır, hata yapabilirler. Önümüzdeki maçlara bakıyoruz.',
          deltaFans: -4,
          deltaLockerRoom: -2,
          deltaBoardTrust: 2,
          log: 'Başkan hakem tartışmalarını büyütmek istemedi.'
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (ctx, ref, _) {
        final stateAsync = ref.watch(gameStateProvider);

        return stateAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
          data: (gameState) {
            final currentQ = _questions[_questionIndex % _questions.length];

            return Scaffold(
              backgroundColor: AppColors.primaryDeep,
              appBar: AppBar(
                backgroundColor: AppColors.neoCardBg,
                title: Text('BASIN SALONU & MEDYA İLİŞKİLERİ', style: AppTypography.h2(color: Colors.white)),
              ),
              body: Column(
                children: [
                  MetersBarWidget(meters: gameState.userClub.meters),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Basın Odası Başlık Frame
                          RetroWindow(
                            title: 'CANLI BASIN TOPLANTISI SALONU',
                            icon: '🎙️',
                            child: Row(
                              children: [
                                const Text('📺', style: TextStyle(fontSize: 32)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'MEDYA MİKROFONLARI SİZE YÖNELTİLDİ',
                                        style: AppTypography.label(color: AppColors.neonPink).copyWith(fontSize: 12),
                                      ),
                                      Text(
                                        'Vereceğiniz cevaplar taraftar coşkusunu, soyunma odası moralini ve yönetim güvenini doğrudan etkiler.',
                                        style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 2. Gazeteci Soru Kartı
                          RetroWindow(
                            title: 'GAZETECİ SORUSU (${currentQ.outlet})',
                            icon: '❓',
                            titleBarColor: AppColors.neoCardBg,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('👤', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${currentQ.journalist} (${currentQ.outlet})',
                                      style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF141A24),
                                    border: Border.all(color: Colors.white24, width: 1.5),
                                  ),
                                  child: Text(
                                    '"${currentQ.question}"',
                                    style: AppTypography.body(color: Colors.white).copyWith(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                Text(
                                  'BAŞKANIN CEVABI:',
                                  style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 11),
                                ),
                                const SizedBox(height: 8),

                                ...currentQ.options.map(
                                  (opt) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: RetroButton(
                                      onPressed: () {
                                        ref.read(gameStateProvider.notifier).applyPressResponse(
                                              deltaFans: opt.deltaFans,
                                              deltaLockerRoom: opt.deltaLockerRoom,
                                              deltaBoardTrust: opt.deltaBoardTrust,
                                              logText: opt.log,
                                            );

                                        setState(() {
                                          _questionIndex++;
                                        });

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('🎙️ Basın açıklaması yapıldı: "${opt.log}"')),
                                        );
                                      },
                                      backgroundColor: const Color(0xFF1B2230),
                                      textColor: Colors.white,
                                      child: Row(
                                        children: [
                                          const Text('▶', style: TextStyle(color: AppColors.neonAmber, fontSize: 11)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              opt.text,
                                              style: AppTypography.body(color: Colors.white).copyWith(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
