import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/app_theme.dart';

enum NeoButtonVariant { primary, dark, accent, secondary }

class NeoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final NeoButtonVariant variant;
  final Widget? icon;
  final double? width;
  final double height;
  final bool isLoading;

  const NeoButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = NeoButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 54,
    this.isLoading = false,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  Color get _backgroundColor {
    switch (widget.variant) {
      case NeoButtonVariant.primary:
        return AppColors.primary;
      case NeoButtonVariant.dark:
        return AppColors.foreground;
      case NeoButtonVariant.accent:
        return AppColors.accent;
      case NeoButtonVariant.secondary:
        return Colors.white;
    }
  }

  Color get _textColor {
    switch (widget.variant) {
      case NeoButtonVariant.dark:
        return Colors.white;
      default:
        return AppColors.foreground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        width: widget.width,
        height: widget.height,
        transform: Matrix4.translationValues(
          _isPressed ? 2.0 : 0.0,
          _isPressed ? 2.0 : 0.0,
          0.0,
        ),
        decoration: BoxDecoration(
          color: enabled ? _backgroundColor : _backgroundColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(
            color: AppColors.foreground,
            width: AppTheme.borderWidth,
          ),
          boxShadow: _isPressed
              ? [
                  const BoxShadow(
                    color: AppColors.foreground,
                    offset: Offset(1.0, 1.0),
                    blurRadius: 0,
                  )
                ]
              : AppTheme.neoShadow,
        ),
        alignment: Alignment.center,
        child: widget.isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _textColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    widget.icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
