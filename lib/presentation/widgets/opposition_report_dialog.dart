// presentation/widgets/opposition_report_dialog.dart
// Pre-Match Tactical Opposition Scouting Report Dialog (§13.4, §11.2)

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/tactics/opposition_scout.dart';
import 'retro_button.dart';
import 'retro_window.dart';

class OppositionReportDialog extends StatelessWidget {
  final OppositionScoutReport report;

  const OppositionReportDialog({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: RetroWindow(
        title: 'SCOUT ANALİZİ: ${report.opponentClubName.toUpperCase()}',
        icon: '🛰️',
        titleBarColor: const Color(0xFF1E3A8A),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(report.opponentBadge, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report.opponentClubName, style: AppTypography.h3(color: Colors.white)),
                        Text(
                          'Diziliş: ${report.dominantFormation} • Stil: ${report.tacticalStyle}',
                          style: const TextStyle(color: AppColors.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.white24),

              // Key Threat
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: const Color(0xFF1F1D14),
                child: Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('EN TEHLİKELİ OYUNCU:', style: TextStyle(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text('${report.keyThreatPlayerName} (${report.keyThreatOvr} OVR)', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Weakness
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: const Color(0xFF261014),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🎯 TESPİT EDİLEN ZAYIF NOKTA:', style: TextStyle(color: AppColors.comicRed, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(report.primaryWeakness, style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Recommended Counter
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: const Color(0xFF0C241B),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ÖNERİLEN KARŞI TAKTİK:', style: TextStyle(color: AppColors.neonLime, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(report.recommendedCounterTactic, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: RetroButton(
                  onPressed: () => Navigator.of(context).pop(),
                  backgroundColor: AppColors.neonLime,
                  textColor: Colors.black,
                  child: const Text('ANLAŞILDI', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
