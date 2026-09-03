// presentation/widgets/contractor_tender_modal.dart
// Facility Construction Contractor Tenders & Municipal Permit Dialog

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../domain/entities/facility.dart';
import 'retro_window.dart';

class ContractorTenderModal extends StatelessWidget {
  final FacilityType facilityType;
  final int baseCost;
  final Function(int finalCost, int durationWeeks, String contractorName) onContractorSelected;

  const ContractorTenderModal({
    super.key,
    required this.facilityType,
    required this.baseCost,
    required this.onContractorSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required FacilityType facilityType,
    required int baseCost,
    required Function(int finalCost, int durationWeeks, String contractorName) onSelected,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ContractorTenderModal(
        facilityType: facilityType,
        baseCost: baseCost,
        onContractorSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: RetroWindow(
        title: '[TESİS] İNŞAAT MÜTEAHHİT İHALESİ & İMAR ONAYI',
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
                  child: Text(
                    '${facilityType.label.toUpperCase()} için 3 farklı inşaat firması teklif verdi. Kalite, süre ve maliyet dengesine göre müteahhidinizi seçin.',
                    style: const TextStyle(color: AppColors.neonLime, fontSize: 10.5),
                  ),
                ),
                const SizedBox(height: 12),

                // Müteahhit 1: Yerel Müteahhit
                _buildTenderCard(
                  context: context,
                  name: 'Öz-Kardeşler İnşaat (Yerel)',
                  avatar: '[İNŞAAT]',
                  cost: (baseCost * 0.85).toInt(),
                  weeks: 8,
                  desc: 'Maliyet %15 daha ucuz fakat inşaat süresi 8 hafta sürer.',
                  onSelect: () {
                    Navigator.of(context).pop();
                    onContractorSelected((baseCost * 0.85).toInt(), 8, 'Öz-Kardeşler İnşaat');
                  },
                ),
                const SizedBox(height: 8),

                // Müteahhit 2: Standart Konsorsiyum
                _buildTenderCard(
                  context: context,
                  name: 'Yapı-Merkez Taahhüt A.Ş.',
                  avatar: '[TESİS]',
                  cost: baseCost,
                  weeks: 6,
                  desc: 'Standart piyasa maliyeti ve 6 haftalık teslim süresi.',
                  onSelect: () {
                    Navigator.of(context).pop();
                    onContractorSelected(baseCost, 6, 'Yapı-Merkez Taahhüt A.Ş.');
                  },
                ),
                const SizedBox(height: 8),

                // Müteahhit 3: Uluslararası Hızlı Yapım
                _buildTenderCard(
                  context: context,
                  name: 'Hochtief German Engineering',
                  avatar: '[KULÜP]',
                  cost: (baseCost * 1.35).toInt(),
                  weeks: 4,
                  desc: 'Hızlı teslim (4 hafta) ve üstün Alman kalitesi (+%35 Maliyet).',
                  onSelect: () {
                    Navigator.of(context).pop();
                    onContractorSelected((baseCost * 1.35).toInt(), 4, 'Hochtief German Engineering');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTenderCard({
    required BuildContext context,
    required String name,
    required String avatar,
    required int cost,
    required int weeks,
    required String desc,
    required VoidCallback onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.win95Grey,
        border: Border.all(color: AppColors.win95DarkGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(avatar, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.win95TitleNavy)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.black,
                child: Text(
                  '₣${(cost / 1000).toInt()}K ($weeks HF)',
                  style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 10, color: Colors.black87)),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: RetroButton(
              onPressed: onSelect,
              child: const Text('İHALEYİ VER & İNŞAATI BAŞLAT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
