import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum NeoPillTone { green, orange, yellow, white, muted, gray }

class NeoPill extends StatelessWidget {
  final String label;
  final Widget? icon;
  final NeoPillTone tone;
  final VoidCallback? onTap;
  final bool isSelected;

  const NeoPill({
    super.key,
    String? label,
    String? text,
    this.icon,
    this.tone = NeoPillTone.white,
    this.onTap,
    this.isSelected = false,
  }) : label = label ?? text ?? '';

  Color get _backgroundColor {
    if (isSelected) return AppColors.primary;
    switch (tone) {
      case NeoPillTone.green:
        return AppColors.tintGreen;
      case NeoPillTone.orange:
        return AppColors.primaryLight;
      case NeoPillTone.yellow:
        return AppColors.accent.withValues(alpha: 0.35);
      case NeoPillTone.muted:
      case NeoPillTone.gray:
        return AppColors.muted;
      case NeoPillTone.white:
        return Colors.white;
    }
  }

  Color get _textColor {
    switch (tone) {
      case NeoPillTone.green:
        return AppColors.tagGreenText;
      case NeoPillTone.orange:
        return const Color(0xFFA34412);
      case NeoPillTone.gray:
      case NeoPillTone.muted:
        return AppColors.mutedText;
      default:
        return AppColors.foreground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppColors.foreground,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: _textColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: pill,
      );
    }
    return pill;
  }
}
