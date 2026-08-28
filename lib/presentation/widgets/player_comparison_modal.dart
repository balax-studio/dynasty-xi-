// presentation/widgets/player_comparison_modal.dart
// Side-by-side Teammate Attribute and Performance Comparison Modal.

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/entities/player.dart';
import 'retro_window.dart';

class PlayerComparisonModal extends StatefulWidget {
  final Player player;
  final List<Player> squad;

  const PlayerComparisonModal({
    super.key,
    required this.player,
    required this.squad,
  });

  static void show(BuildContext context, Player player, List<Player> squad) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PlayerComparisonModal(player: player, squad: squad),
    );
  }

  @override
  State<PlayerComparisonModal> createState() => _PlayerComparisonModalState();
}

class _PlayerComparisonModalState extends State<PlayerComparisonModal> {
  late Player _compareTarget;

  @override
  void initState() {
    super.initState();
    // Default to the first squad member in same position, or first other player
    final samePos = widget.squad.where((p) => p.id != widget.player.id && p.position == widget.player.position).toList();
    if (samePos.isNotEmpty) {
      _compareTarget = samePos.first;
    } else {
      _compareTarget = widget.squad.firstWhere(
        (p) => p.id != widget.player.id,
        orElse: () => widget.player,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableTargets = widget.squad.where((p) => p.id != widget.player.id).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.primaryDeep,
        border: Border(
          top: BorderSide(color: AppColors.neonCyan, width: 3),
        ),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: AppColors.win95TitleNavy,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('[HUKUK]', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'KADRO İÇİ MEVKİ & OYUNCU KIYASLAMA',
                      style: AppTypography.h3(color: Colors.white).copyWith(fontSize: 12),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Karşılaştırılacak Oyuncu Seçici
          Container(
            padding: const EdgeInsets.all(10),
            color: AppColors.neoInnerBg,
            child: Row(
              children: [
                const Text('Kıyaslanacak Oyuncu:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _compareTarget.id,
                      dropdownColor: Colors.black,
                      isDense: true,
                      style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11),
                      items: availableTargets.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.fullName} (${p.position.code} - ${p.ovr} OVR)'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _compareTarget = widget.squad.firstWhere((p) => p.id == val);
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Karşılaştırma Tablosu
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // İsim ve OVR Başlık Kartları
                  Row(
                    children: [
                      Expanded(child: _buildPlayerMiniHeader(widget.player, AppColors.neonCyan)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildPlayerMiniHeader(_compareTarget, AppColors.accentGold)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nitelik Kıyaslama Satırları
                  RetroWindow(
                    title: 'TEMEL VERİLER VE YETENEK KIYASI',
                    icon: '[GRAFIK]',
                    child: Column(
                      children: [
                        _buildCompareRow('GENEL PUAN (OVR)', widget.player.ovr, _compareTarget.ovr),
                        _buildCompareRow('POTANSİYEL', widget.player.potential, _compareTarget.potential),
                        _buildCompareRow('YAŞ', widget.player.age, _compareTarget.age, isLowerBetter: true),
                        _buildCompareRow('MORAL', widget.player.morale, _compareTarget.morale),
                        _buildCompareRow('FORM (1-10)', (widget.player.form * 10).round(), (_compareTarget.form * 10).round()),
                        _buildCompareRow('HAFTALIK MAAŞ', widget.player.weeklyWage, _compareTarget.weeklyWage, isLowerBetter: true, prefix: '₣'),
                        const Divider(color: AppColors.win95DarkGrey, height: 16),
                        _buildCompareRow('HIZ (PAC)', widget.player.pace, _compareTarget.pace),
                        _buildCompareRow('TEKNİK (TEC)', widget.player.technique, _compareTarget.technique),
                        _buildCompareRow('ŞUT (SHO)', widget.player.shooting, _compareTarget.shooting),
                        _buildCompareRow('PAS (PAS)', widget.player.passing, _compareTarget.passing),
                        _buildCompareRow('DEFANS (DEF)', widget.player.defending, _compareTarget.defending),
                        _buildCompareRow('FİZİK (PHY)', widget.player.physical, _compareTarget.physical),
                        _buildCompareRow('MENTALİTE (MEN)', widget.player.mentality, _compareTarget.mentality),
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
  }

  Widget _buildPlayerMiniHeader(Player p, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            '#${p.jerseyNumber} ${p.fullName}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                color: color,
                child: Text(
                  p.position.code,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${p.ovr} OVR',
                style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompareRow(String label, int val1, int val2, {bool isLowerBetter = false, String prefix = ''}) {
    final diff = val1 - val2;
    final isVal1Better = isLowerBetter ? diff < 0 : diff > 0;
    final isVal2Better = isLowerBetter ? diff > 0 : diff < 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          // Sol Oyuncu Değeri
          SizedBox(
            width: 65,
            child: Text(
              '$prefix$val1',
              style: TextStyle(
                color: isVal1Better ? AppColors.neonLime : (diff == 0 ? Colors.white : Colors.white70),
                fontWeight: isVal1Better ? FontWeight.w900 : FontWeight.normal,
                fontSize: 11,
              ),
              textAlign: TextAlign.left,
            ),
          ),

          // Nitelik Adı
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 9.5, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          // Sağ Oyuncu Değeri
          SizedBox(
            width: 65,
            child: Text(
              '$prefix$val2',
              style: TextStyle(
                color: isVal2Better ? AppColors.accentGold : (diff == 0 ? Colors.white : Colors.white70),
                fontWeight: isVal2Better ? FontWeight.w900 : FontWeight.normal,
                fontSize: 11,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
