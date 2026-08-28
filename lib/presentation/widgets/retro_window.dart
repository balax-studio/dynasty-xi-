// presentation/widgets/retro_window.dart
// Reusable Neo-Brutalist 16-Bit Arcade Window, Button, Panel, and Badge components.

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/audio/audio_synthesizer.dart';
import 'retro_pixel_icon.dart';

/// Neo-Brutalist 16-Bit Arcade Pencere Çerçevesi
class RetroWindow extends StatelessWidget {
  final String title;
  final String icon;
  final Widget? leadingIcon;
  final Widget child;
  final VoidCallback? onClose;
  final VoidCallback? onMinimize;
  final VoidCallback? onMaximize;
  final Color titleBarColor;
  final Color backgroundColor;
  final Widget? bottomStatusBar;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const RetroWindow({
    super.key,
    required this.title,
    this.icon = 'BOLT',
    this.leadingIcon,
    required this.child,
    this.onClose,
    this.onMinimize,
    this.onMaximize,
    this.titleBarColor = AppColors.neoCardBg,
    this.backgroundColor = AppColors.neoCardBg,
    this.bottomStatusBar,
    this.padding = const EdgeInsets.all(10.0),
    this.margin = const EdgeInsets.symmetric(vertical: 6.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: AppColors.neoBoxDecoration(
        backgroundColor: backgroundColor,
        borderColor: Colors.black,
        shadowColor: Colors.black,
        shadowOffset: const Offset(4, 4),
        borderWidth: 2.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Neo-Brutalist Başlık Şeridi (Titlebar)
          Builder(
            builder: (context) {
              final isTitleDark = ThemeData.estimateBrightnessForColor(titleBarColor) == Brightness.dark;
              final titleTextColor = isTitleDark ? Colors.white : Colors.black;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: titleBarColor,
                  border: const Border(
                    bottom: BorderSide(color: Colors.black, width: 2.5),
                  ),
                ),
                child: Row(
                  children: [
                    leadingIcon ??
                        RetroPixelIcon.fromEmoji(
                          icon,
                          size: 15,
                          color: titleTextColor,
                          secondaryColor: isTitleDark ? Colors.black : Colors.white,
                        ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: AppTypography.label(color: titleTextColor).copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Neo-Brutalist Kontrol Butonları [_] [▲] []
                    if (onMinimize != null) _buildNeoButton('_', onMinimize),
                    if (onMaximize != null) ...[
                      const SizedBox(width: 4),
                      _buildNeoButton('▲', onMaximize),
                    ],
                    if (onClose != null) ...[
                      const SizedBox(width: 4),
                      _buildNeoButton('', onClose, isClose: true),
                    ],
                  ],
                ),
              );
            },
          ),

          // 2. İçerik Alanı
          Padding(
            padding: padding,
            child: child,
          ),

          // 3. Alt Durum Çubuğu (Status Bar)
          if (bottomStatusBar != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(color: Colors.black, width: 2.0),
                ),
              ),
              child: bottomStatusBar!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNeoButton(String label, VoidCallback? onTap, {bool isClose = false}) {
    return GestureDetector(
      onTap: () {
        AudioSynthesizer.playClick();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isClose ? AppColors.comicRed : AppColors.neonLime,
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(1.5, 1.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isClose ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

/// Neo-Brutalist 16-Bit Arcade Butonu
class RetroButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final double borderWidth;
  final bool isNeon;

  const RetroButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor = AppColors.neonLime,
    this.textColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.borderWidth = 2.0,
    this.isNeon = false,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final bg = isDisabled ? AppColors.neutral700 : widget.backgroundColor;
    final isBgDark = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark;
    final fg = isDisabled
        ? AppColors.neutral300
        : (widget.textColor != Colors.black
            ? widget.textColor
            : (isBgDark ? Colors.white : Colors.black));

    return GestureDetector(
      onTapDown: !isDisabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: !isDisabled
          ? (_) {
              setState(() => _isPressed = false);
              AudioSynthesizer.playClick();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        padding: widget.padding,
        decoration: AppColors.neoBoxDecoration(
          backgroundColor: bg,
          borderColor: Colors.black,
          shadowColor: _isPressed || isDisabled ? Colors.transparent : Colors.black,
          shadowOffset: _isPressed || isDisabled ? Offset.zero : const Offset(3.5, 3.5),
          borderWidth: widget.borderWidth,
        ),
        transform: _isPressed ? Matrix4.translationValues(2, 2, 0) : Matrix4.identity(),
        child: DefaultTextStyle(
          style: AppTypography.label(color: fg).copyWith(fontWeight: FontWeight.w900),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Sert Kontürlü Neo-Brutalist Panel (Puanlar, Terminal ve Girdiler için)
class RetroInsetPanel extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final Color borderColor;

  const RetroInsetPanel({
    super.key,
    required this.child,
    this.backgroundColor = Colors.black,
    this.borderColor = AppColors.neonLime,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 2.0),
      ),
      child: child,
    );
  }
}

/// Neo-Brutalist Çıkartma Rozeti
class RetroBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final String? icon;

  const RetroBadge({
    super.key,
    required this.text,
    this.backgroundColor = AppColors.neonPink,
    this.textColor = Colors.white,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isBgDark = ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark;
    final fg = textColor != Colors.white && textColor != Colors.black
        ? textColor
        : (isBgDark ? Colors.white : Colors.black);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: AppColors.neoBoxDecoration(
        backgroundColor: backgroundColor,
        borderColor: Colors.black,
        shadowColor: Colors.black,
        shadowOffset: const Offset(2, 2),
        borderWidth: 1.8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
          ],
          Text(
            text.toUpperCase(),
            style: AppTypography.label(color: fg).copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
