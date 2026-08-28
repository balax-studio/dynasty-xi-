// presentation/screens/head_coach_hiring_screen.dart
// Head Coach Hiring, Firing and Vision Dictation Screen for Club Owner / President (§15.4)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/president/head_coach.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';
import 'head_coach_dialogue_screen.dart';

class HeadCoachHiringScreen extends ConsumerStatefulWidget {
  const HeadCoachHiringScreen({super.key});

  @override
  ConsumerState<HeadCoachHiringScreen> createState() => _HeadCoachHiringScreenState();
}

class _HeadCoachHiringScreenState extends ConsumerState<HeadCoachHiringScreen> {
  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Hata: $err', style: AppTypography.body())),
      ),
      data: (gameState) {
        final club = gameState.userClub;
        final headCoach = gameState.headCoach;
        final candidates = HeadCoachCatalog.getCandidateCoaches();

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.neoCardBg,
            elevation: 0,
            leading: IconButton(
              icon: const Text('◀', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                const Text('[HOCA]', style: TextStyle(fontSize: 12, color: AppColors.neonLime, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TEKNİK DİREKTÖR YÖNETİM MERKEZİ',
                        style: AppTypography.h2(color: Colors.white).copyWith(fontSize: 13),
                      ),
                      Text(
                        'BAŞKANLIK MAKAMINDAN ATAMA VE VİZYON DAYATMA',
                        style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              MetersBarWidget(meters: club.meters),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Görevdeki Teknik Direktör Paneli
                      _buildActiveCoachSection(headCoach, club.meters.cash),
                      const SizedBox(height: 12),

                      // 2. Aday Teknik Direktörler Listesi
                      _buildCandidateCoachesSection(candidates, club.meters.cash, headCoach),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 1. Aktif Teknik Direktör ve Vizyon Paneli
  Widget _buildActiveCoachSection(HeadCoach? coach, int clubCash) {
    if (coach == null) {
      return RetroWindow(
        title: 'KULÜBÜN BAŞINDAKİ TEKNİK HEYET',
        icon: '[UYARI]',
        titleBarColor: AppColors.comicRed,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1014),
            border: Border.all(color: AppColors.comicRed),
          ),
          child: const Column(
            children: [
              Text('[ACIL] KULÜPTE RESMİ BİR TEKNİK DİREKTÖR BULUNMUYOR!', style: TextStyle(color: AppColors.comicRed, fontWeight: FontWeight.bold, fontSize: 11)),
              SizedBox(height: 6),
              Text(
                'Takım şu an geçici antrenörler eşliğinde maçlara çıkıyor. Taktiksel verim ve oyuncu morali düşük. Lütfen aşağıdaki adaylardan kulüp felsefesine uygun bir hoca ile sözleşme imzalayın.',
                style: TextStyle(color: Colors.white70, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RetroWindow(
      title: 'GÖREVDEKİ TEKNİK DİREKTÖR (KULÜP PATRONU: BAŞKAN)',
      icon: '',
      titleBarColor: AppColors.win95TitleNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hoca Bilgi Kartı
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: AppColors.neonLime, width: 1.5),
            ),
            child: Row(
              children: [
                Text(coach.archetype.icon, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(coach.fullName, style: AppTypography.h3(color: AppColors.neonLime)),
                      Text('${coach.archetype.label} • Yaş: ${coach.age} • ${coach.countryCode}', style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Maaş: ₣${coach.weeklyWage}/h', style: AppTypography.monoNumber(color: AppColors.accentGold).copyWith(fontSize: 10.5, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text('Taktik: ${coach.tacticalStyle}', style: const TextStyle(color: AppColors.neonCyan, fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Hocanın Pasif Avantajları
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.neoInnerBg,
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const Text('BOLT', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(coach.archetype.description, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Başkanlık Vizyonu Dikte Etme Seçenekleri
          const Text('[RAPOR] BAŞKANLIK VİZYONU & OYUN FELSEFESİ DİKTE ET:', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: CoachVision.values.map((v) {
              final isSelected = coach.activeVision == v;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: RetroButton(
                    onPressed: () async {
                      await ref.read(gameStateProvider.notifier).dictateCoachVision(v);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.neonLime,
                            content: Text('[RAPOR] Hocaya yeni vizyon dikte edildi: ${v.label}', style: const TextStyle(color: Colors.black)),
                          ),
                        );
                      }
                    },
                    backgroundColor: isSelected ? AppColors.neonCyan : const Color(0xFF1E293B),
                    textColor: isSelected ? Colors.black : Colors.white,
                    child: Text(
                      v.label.split(" ").first,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Hocayla RPG Sohbet & Talimat Butonu
          SizedBox(
            width: double.infinity,
            child: RetroButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HeadCoachDialogueScreen()),
                );
              },
              backgroundColor: AppColors.neonLime,
              textColor: Colors.black,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('[MESAJ]', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'HOCA İLE BİREBİR SOHBET ET & TALİMAT VER (RPG)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Hocayı Kovma Butonu
          SizedBox(
            width: double.infinity,
            child: RetroButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.neoCardBg,
                    title: const Text('TEKNİK DİREKTÖRÜ GÖREVDEN AL?', style: TextStyle(color: AppColors.comicRed, fontWeight: FontWeight.bold)),
                    content: Text(
                      '${coach.fullName} ile yolları ayırmak istiyor musunuz?\n\nKulüp kasasından ₣${coach.severancePay} fesih tazminatı ödenecektir.',
                      style: const TextStyle(color: Colors.white),
                    ),
                    actions: [
                      RetroButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        backgroundColor: AppColors.win95DarkGrey,
                        textColor: Colors.black,
                        child: const Text('VAZGEÇ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      RetroButton(
                        backgroundColor: AppColors.comicRed,
                        textColor: Colors.white,
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('GÖREVDEN AL (KOV)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final ok = await ref.read(gameStateProvider.notifier).fireHeadCoach();
                  if (mounted && ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.comicRed,
                        content: Text('[ACIL] ${coach.fullName} görevden alındı! Tazminat ödendi.', style: const TextStyle(color: Colors.white)),
                      ),
                    );
                  }
                }
              },
              backgroundColor: AppColors.comicRed,
              textColor: Colors.white,
              child: Text(
                '[ACIL] GÖREVDEN AL / KOV (₣${coach.severancePay} Fesih Tazminatı)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Aday Teknik Direktörler Listesi
  Widget _buildCandidateCoachesSection(List<HeadCoach> candidates, int clubCash, HeadCoach? activeCoach) {
    return RetroWindow(
      title: 'BOŞTAKİ TEKNİK DİREKTÖR ADAYLARI',
      icon: '[RAPOR]',
      titleBarColor: AppColors.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kulübün hedeflerine ve oyun vizyonuna en uygun teknik direktörü seçip göreve getirin:', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
          const SizedBox(height: 8),
          ...candidates.map((c) {
            final isHired = activeCoach?.id == c.id;
            final canAfford = clubCash >= c.signingFee;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isHired ? const Color(0xFF0F2E1E) : AppColors.neoInnerBg,
                border: Border.all(color: isHired ? AppColors.neonLime : Colors.white24),
              ),
              child: Row(
                children: [
                  Text(c.archetype.icon, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.fullName, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
                        Text('${c.archetype.label} • Taktik: ${c.tacticalStyle}', style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
                        const SizedBox(height: 3),
                        Text(c.archetype.description, style: const TextStyle(color: AppColors.neonCyan, fontSize: 9.5)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('Maaş: ₣${c.weeklyWage}/h', style: AppTypography.monoNumber(color: AppColors.accentGold).copyWith(fontSize: 9.5, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text('İmza Parası: ₣${c.signingFee}', style: const TextStyle(color: Colors.white70, fontSize: 9.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isHired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: AppColors.neonLime,
                      child: const Text('GÖREVDE', style: TextStyle(color: Colors.black, fontSize: 9.5, fontWeight: FontWeight.bold)),
                    )
                  else
                    RetroButton(
                      onPressed: canAfford
                          ? () async {
                              final ok = await ref.read(gameStateProvider.notifier).hireHeadCoach(c);
                              if (mounted && ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.neonLime,
                                    content: Text('[KUTLAMA] ${c.fullName} kulübün başına getirildi!', style: const TextStyle(color: Colors.black)),
                                  ),
                                );
                              }
                            }
                          : null,
                      backgroundColor: canAfford ? AppColors.neonLime : Colors.grey,
                      textColor: Colors.black,
                      child: const Text('GÖREVE GETİR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5)),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
