import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A neo-brutalist pressable widget that animates like a physical button
/// by depressing along the X & Y axes and collapsing its drop shadow on press.
class NeoPressable extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget? child;
  final Widget Function(BuildContext context, bool isPressed)? builder;
  final BoxDecoration? decoration;
  final double pressDepth;
  final Duration duration;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final bool enableHaptic;

  const NeoPressable({
    super.key,
    this.onTap,
    this.child,
    this.builder,
    this.decoration,
    this.pressDepth = 2.0,
    this.duration = const Duration(milliseconds: 70),
    this.width,
    this.height,
    this.padding,
    this.alignment,
    this.enableHaptic = true,
  }) : assert(
          child != null || builder != null,
          'Either child or builder must be provided',
        );

  @override
  State<NeoPressable> createState() => _NeoPressableState();
}

class _NeoPressableState extends State<NeoPressable> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;

    Widget content;
    if (widget.builder != null) {
      content = widget.builder!(context, _isPressed);
    } else {
      final baseDec = widget.decoration ?? const BoxDecoration();
      final hasShadows = baseDec.boxShadow != null && baseDec.boxShadow!.isNotEmpty;

      content = AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeInOut,
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        alignment: widget.alignment,
        transform: Matrix4.translationValues(
          _isPressed ? widget.pressDepth : 0.0,
          _isPressed ? widget.pressDepth : 0.0,
          0.0,
        ),
        decoration: baseDec.copyWith(
          boxShadow: _isPressed
              ? (hasShadows
                  ? [
                      const BoxShadow(
                        color: Colors.transparent,
                        offset: Offset.zero,
                        blurRadius: 0,
                      )
                    ]
                  : null)
              : baseDec.boxShadow,
        ),
        child: widget.child,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? _handleTapDown : null,
      onTapUp: enabled ? _handleTapUp : null,
      onTapCancel: enabled ? _handleTapCancel : null,
      onTap: enabled ? widget.onTap : null,
      child: content,
    );
  }
}
