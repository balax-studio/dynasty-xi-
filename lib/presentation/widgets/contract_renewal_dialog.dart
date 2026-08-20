// presentation/widgets/contract_renewal_dialog.dart
// Interactive Contract Extension, Wage Slider & Role Promise Negotiation Dialog (§10.6, §10.7)

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/entities/player.dart';
import '../../domain/progression/player_growth.dart';
import 'face_avatar_widget.dart';
import 'retro_window.dart';

class ContractRenewalDialog extends StatefulWidget {
  final Player player;
  final Function(int newWage, int contractWeeks, SquadRole role, int signingBonus) onContractSigned;

  const ContractRenewalDialog({
    super.key,
    required this.player,
    required this.onContractSigned,
  });

  @override
  State<ContractRenewalDialog> createState() => _ContractRenewalDialogState();
}

class _ContractRenewalDialogState extends State<ContractRenewalDialog> {
  late int _offeredWage;
  int _contractWeeks = 42; // 2 seasons default
  SquadRole _promisedRole = SquadRole.first11;
  int _signingBonus = 5000;

  @override
  void initState() {
    super.initState();
    _offeredWage = widget.player.weeklyWage;
  }

  @override
  Widget build(BuildContext context) {
    final expectedWage = (widget.player.ovr * 110).clamp(500, 50000);
    final evaluation = evaluateContractOffer(
      player: widget.player,
      offeredWage: _offeredWage,
      expectedWage: expectedWage,
      promisedRole: _promisedRole,
      signingBonus: _signingBonus,
    );

    final statusColor = evaluation.accepted
        ? AppColors.neonLime
        : (evaluation.satisfactionScore >= 45 ? AppColors.neonAmber : AppColors.comicRed);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: RetroWindow(
        title: 'SÖZLEŞME GÖRÜŞMESİ: ${widget.player.fullName.toUpperCase()}',
        icon: '📝',
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player Header with Face
              Row(
                children: [
                  FaceAvatarWidget(seed: widget.player.faceSeed, size: 54),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.player.fullName, style: AppTypography.h3(color: Colors.white)),
                        Text(
                          '${widget.player.position.code} • ${widget.player.ovr} OVR • Kişilik: ${widget.player.personality.label}',
                          style: const TextStyle(color: AppColors.neutral300, fontSize: 11),
                        ),
                        Text(
                          'Mevcut Maaş: ₣${widget.player.weeklyWage}/h | Talep: ~₣$expectedWage/h',
                          style: const TextStyle(color: AppColors.accentGold, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white24),

              // 1. Offered Wage Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Haftalık Maaş Teklifi:', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('₣$_offeredWage / hafta', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Slider(
                value: _offeredWage.toDouble().clamp((expectedWage * 0.4).floorToDouble(), (expectedWage * 2.2).ceilToDouble()),
                min: (expectedWage * 0.4).floorToDouble(),
                max: (expectedWage * 2.2).ceilToDouble(),
                divisions: 30,
                activeColor: AppColors.neonLime,
                inactiveColor: Colors.white24,
                onChanged: (val) => setState(() => _offeredWage = val.toInt()),
              ),

              // 2. Signing Bonus Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('İmza Parası (Bonus):', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('₣$_signingBonus', style: const TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Slider(
                value: _signingBonus.toDouble(),
                min: 0,
                max: 50000,
                divisions: 25,
                activeColor: AppColors.neonCyan,
                inactiveColor: Colors.white24,
                onChanged: (val) => setState(() => _signingBonus = val.toInt()),
              ),

              // 3. Promised Squad Role
              const Text('Taahhüt Edilen Kadro Rolü:', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: SquadRole.values.map((role) {
                  final isSelected = _promisedRole == role;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _promisedRole = role),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.neonLime : Colors.black,
                          border: Border.all(color: isSelected ? Colors.white : Colors.white24),
                        ),
                        child: Text(
                          role.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Evaluation Reaction Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: statusColor, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('OYUNCU & MENAJER YANITI:', style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text('Memnuniyet: %${evaluation.satisfactionScore}', style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"${evaluation.responseMessage}"',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('İPTAL', style: TextStyle(color: Colors.white60)),
                  ),
                  const SizedBox(width: 8),
                  RetroButton(
                    onPressed: evaluation.accepted
                        ? () {
                            widget.onContractSigned(_offeredWage, _contractWeeks, _promisedRole, _signingBonus);
                            Navigator.of(context).pop();
                          }
                        : null,
                    backgroundColor: evaluation.accepted ? AppColors.neonLime : Colors.grey,
                    textColor: Colors.black,
                    child: const Text('İMZALA', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
