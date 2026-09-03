// presentation/widgets/urgent_phone_call_modal.dart
// Red Telephone / Kırmızı Hat Acil Kriz Çağrısı Modal Widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/president/president_crisis.dart';
import 'retro_window.dart';

class UrgentPhoneCallModal extends ConsumerWidget {
  final PresidentCrisisCall call;

  const UrgentPhoneCallModal({
    super.key,
    required this.call,
  });

  static Future<void> show(BuildContext context, PresidentCrisisCall call) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => UrgentPhoneCallModal(call: call),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: RetroWindow(
        title: '[KIRMIZI] ACİL ÇAĞRI: ${call.callerTitle.toUpperCase()}',
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Arayan Kişi Banner'ı
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.win95Grey,
                    border: Border.all(color: AppColors.comicRed, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Text(call.callerAvatar, style: const TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              call.callerName,
                              style: AppTypography.h3(color: AppColors.comicRed),
                            ),
                            Text(
                              call.callerTitle,
                              style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Telefon Konuşması Diyalog Metni
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: AppColors.win95DarkGrey),
                  ),
                  child: Text(
                    '"${call.dialogQuote}"',
                    style: const TextStyle(
                      color: AppColors.neonLime,
                      fontFamily: 'Courier',
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  'BAŞKANLIK TALİMATI SEÇİNİZ:',
                  style: AppTypography.label(color: Colors.black).copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),

                // 3 Seçenek
                for (final choice in call.choices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: RetroButton(
                        backgroundColor: AppColors.win95Grey,
                        onPressed: () {
                          // Sayaç güncellemeleri ve kriz çözümü
                          ref.read(gameStateProvider.notifier).resolveCrisisCall(choice);

                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.primaryDeep,
                              content: Text(
                                '[KRİZ] ${choice.outcomeMessage}',
                                style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                choice.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.win95TitleNavy,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                choice.description,
                                style: const TextStyle(color: Colors.black54, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: RetroButton(
                    backgroundColor: Colors.white24,
                    textColor: Colors.black,
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).dismissCrisisCall();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'ÇAĞRIYI ERTELE / DAHA SONRA CEVAPLA',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.black87),
                    ),
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
