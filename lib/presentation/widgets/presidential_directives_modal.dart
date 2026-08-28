// presentation/widgets/presidential_directives_modal.dart
// Presidential Directives: Squad Exclusions, A2 Banishing, Captaincy Mandates (§8, §10).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/player.dart';
import 'retro_window.dart';

class PresidentialDirectivesModal extends ConsumerStatefulWidget {
  final List<Player> players;

  const PresidentialDirectivesModal({
    super.key,
    required this.players,
  });

  static Future<void> show(BuildContext context, List<Player> players) {
    return showDialog(
      context: context,
      builder: (_) => PresidentialDirectivesModal(players: players),
    );
  }

  @override
  ConsumerState<PresidentialDirectivesModal> createState() => _PresidentialDirectivesModalState();
}

class _PresidentialDirectivesModalState extends ConsumerState<PresidentialDirectivesModal> {
  String? _selectedBannedPlayerId;
  String? _selectedCaptainId;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: RetroWindow(
        title: 'CROWN BAŞKANLIK KADRO TALİMATLARI & VETO',
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black,
                  child: const Row(
                    children: [
                      Text('[HUKUK]', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Teknik direktörün yetkilerini ezip doğrudan başkanlık talimatı verin. Hoca itiraz edebilir fakat emir kesindir.',
                          style: TextStyle(color: AppColors.neonLime, fontSize: 10.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 1. Kadro Dışı Bırakma / A2'ye Gönderme
                Text(
                  '1. KADRO DIŞI BIRAK / A2 TAKIMINA SÜR:',
                  style: AppTypography.label(color: AppColors.comicRed).copyWith(fontWeight: FontWeight.bold, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.win95DarkGrey),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedBannedPlayerId,
                      hint: const Text('Kadro dışı bırakılacak oyuncuyu seçin', style: TextStyle(fontSize: 11)),
                      items: widget.players.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.fullName} (${p.position.code} - OVR ${p.overall})', style: const TextStyle(fontSize: 11)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedBannedPlayerId = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Takım Kaptanlığı Ataması
                Text(
                  '2. BAŞKANLIK EMRİYLE KAPTAN ATA:',
                  style: AppTypography.label(color: AppColors.win95TitleNavy).copyWith(fontWeight: FontWeight.bold, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.win95DarkGrey),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedCaptainId,
                      hint: const Text('Yeni takım kaptanını seçin', style: TextStyle(fontSize: 11)),
                      items: widget.players.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.fullName} (${p.position.code} - MNT ${p.mentality})', style: const TextStyle(fontSize: 11)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedCaptainId = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Onay Butonu
                SizedBox(
                  width: double.infinity,
                  child: RetroButton(
                    onPressed: () {
                      final notifier = ref.read(gameStateProvider.notifier);

                      if (_selectedBannedPlayerId != null) {
                        notifier.adjustLockerRoom(-5);
                        notifier.adjustBoardTrust(4);
                      }
                      if (_selectedCaptainId != null) {
                        notifier.adjustLockerRoom(3);
                      }

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.primaryDeep,
                          content: Text(
                            ' Başkanlık Kararnamesi Resmi Olarak Tebliğ Edildi!',
                            style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    child: const Text('TALİMATLARI RESMİLEŞTİR & TEBLİĞ ET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
