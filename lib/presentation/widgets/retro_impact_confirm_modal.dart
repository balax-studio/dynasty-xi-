// presentation/widgets/retro_impact_confirm_modal.dart
// Neo-Brutalist Action & Impact Preview Modal.
// Prevents accidental fire-and-forget clicks by summarizing financial, meters, and squad consequences.

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/audio/audio_synthesizer.dart';
import 'retro_pixel_icon.dart';
import 'retro_window.dart';

class RetroImpactConfirmModal extends StatefulWidget {
  final String title;
  final String actionTitle;
  final String description;
  final RetroPixelIconType iconType;
  final Color iconColor;
  final int cashDelta;
  final int weeklyWageDelta;
  final int? fanDelta;
  final int? moraleDelta;
  final int? boardTrustDelta;
  final String? targetItemName;
  final String? targetItemDetails;
  final String confirmButtonText;
  final Color confirmButtonColor;
  final VoidCallback onConfirmed;

  const RetroImpactConfirmModal({
    super.key,
    required this.title,
    required this.actionTitle,
    required this.description,
    this.iconType = RetroPixelIconType.shield,
    this.iconColor = AppColors.neonCyan,
    this.cashDelta = 0,
    this.weeklyWageDelta = 0,
    this.fanDelta,
    this.moraleDelta,
    this.boardTrustDelta,
    this.targetItemName,
    this.targetItemDetails,
    this.confirmButtonText = 'İŞLEMİ ONAYLA',
    this.confirmButtonColor = AppColors.comicRed,
    required this.onConfirmed,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String actionTitle,
    required String description,
    RetroPixelIconType iconType = RetroPixelIconType.shield,
    Color iconColor = AppColors.neonCyan,
    int cashDelta = 0,
    int weeklyWageDelta = 0,
    int? fanDelta,
    int? moraleDelta,
    int? boardTrustDelta,
    String? targetItemName,
    String? targetItemDetails,
    String confirmButtonText = 'İŞLEMİ ONAYLA',
    Color confirmButtonColor = AppColors.comicRed,
    required VoidCallback onConfirmed,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RetroImpactConfirmModal(
        title: title,
        actionTitle: actionTitle,
        description: description,
        iconType: iconType,
        iconColor: iconColor,
        cashDelta: cashDelta,
        weeklyWageDelta: weeklyWageDelta,
        fanDelta: fanDelta,
        moraleDelta: moraleDelta,
        boardTrustDelta: boardTrustDelta,
        targetItemName: targetItemName,
        targetItemDetails: targetItemDetails,
        confirmButtonText: confirmButtonText,
        confirmButtonColor: confirmButtonColor,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<RetroImpactConfirmModal> createState() => _RetroImpactConfirmModalState();
}

class _RetroImpactConfirmModalState extends State<RetroImpactConfirmModal> {
  bool _isProcessing = false;

  Future<void> _handleConfirm() async {
    setState(() => _isProcessing = true);
    AudioSynthesizer.playMoney();
    await Future.delayed(const Duration(milliseconds: 450));
    if (mounted) {
      widget.onConfirmed();
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: RetroWindow(
        title: widget.title,
        icon: 'shield',
        titleBarColor: AppColors.win95TitleNavy,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Başlık & İkon
            Row(
              children: [
                RetroPixelIcon(type: widget.iconType, size: 28, color: widget.iconColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.actionTitle, style: AppTypography.h3(color: Colors.white).copyWith(fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(widget.description, style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 10.5)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Hedef Öğe Kartı (Oyuncu / Personel / Tesis)
            if (widget.targetItemName != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neoInnerBg,
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const RetroPixelIcon(type: RetroPixelIconType.user, size: 16, color: AppColors.accentGold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.targetItemName!, style: AppTypography.label(color: Colors.white).copyWith(fontSize: 11)),
                          if (widget.targetItemDetails != null)
                            Text(widget.targetItemDetails!, style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // 3. Finansal ve Metre Etki Özeti
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('İŞLEMİN KULÜBE DOĞRUDAN ETKİSİ', style: TextStyle(color: AppColors.neonCyan, fontSize: 9.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kasa Nakit Değişimi:', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        widget.cashDelta >= 0 ? '+₣${widget.cashDelta}' : '-₣${widget.cashDelta.abs()}',
                        style: TextStyle(
                          color: widget.cashDelta >= 0 ? AppColors.neonLime : AppColors.comicRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (widget.weeklyWageDelta != 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Haftalık Maaş Bütçesi:', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        Text(
                          widget.weeklyWageDelta >= 0 ? '+₣${widget.weeklyWageDelta}/h' : '-₣${widget.weeklyWageDelta.abs()}/h',
                          style: TextStyle(
                            color: widget.weeklyWageDelta <= 0 ? AppColors.neonLime : AppColors.comicRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (widget.fanDelta != null || widget.moraleDelta != null || widget.boardTrustDelta != null) ...[
                    const SizedBox(height: 6),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      children: [
                        if (widget.fanDelta != null)
                          Text('Fan: ${widget.fanDelta! >= 0 ? "+${widget.fanDelta}%" : "${widget.fanDelta}%"}',
                              style: TextStyle(color: widget.fanDelta! >= 0 ? AppColors.neonLime : AppColors.comicRed, fontSize: 9.5, fontWeight: FontWeight.bold)),
                        if (widget.moraleDelta != null)
                          Text('Moral: ${widget.moraleDelta! >= 0 ? "+${widget.moraleDelta}%" : "${widget.moraleDelta}%"}',
                              style: TextStyle(color: widget.moraleDelta! >= 0 ? AppColors.neonLime : AppColors.comicRed, fontSize: 9.5, fontWeight: FontWeight.bold)),
                        if (widget.boardTrustDelta != null)
                          Text('Güven: ${widget.boardTrustDelta! >= 0 ? "+${widget.boardTrustDelta}%" : "${widget.boardTrustDelta}%"}',
                              style: TextStyle(color: widget.boardTrustDelta! >= 0 ? AppColors.neonLime : AppColors.comicRed, fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 4. İşlem Butonları
            if (_isProcessing)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.black, border: Border.all(color: AppColors.neonLime)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonLime)),
                    SizedBox(width: 8),
                    Text('İŞLEM İLETİLİYOR VE KAYDEDİLİYOR...', style: TextStyle(color: AppColors.neonLime, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: RetroButton(
                      backgroundColor: AppColors.win95LightGrey,
                      textColor: Colors.black,
                      onPressed: () {
                        AudioSynthesizer.playClick();
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('VAZGEÇ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: RetroButton(
                      backgroundColor: widget.confirmButtonColor,
                      textColor: Colors.white,
                      onPressed: _handleConfirm,
                      child: Text(widget.confirmButtonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
