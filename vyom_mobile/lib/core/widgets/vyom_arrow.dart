import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum VyomArrowDirection { right, left, up, down }

class VyomArrow extends StatelessWidget {
  final double size;
  final Color? color;
  final VyomArrowDirection direction;

  const VyomArrow({
    super.key,
    this.size = 20,
    this.color,
    this.direction = VyomArrowDirection.right,
  });

  const VyomArrow.forward({
    super.key,
    this.size = 20,
    this.color,
  }) : direction = VyomArrowDirection.right;

  const VyomArrow.back({
    super.key,
    this.size = 20,
    this.color,
  }) : direction = VyomArrowDirection.left;

  const VyomArrow.up({
    super.key,
    this.size = 20,
    this.color,
  }) : direction = VyomArrowDirection.up;

  const VyomArrow.down({
    super.key,
    this.size = 20,
    this.color,
  }) : direction = VyomArrowDirection.down;

  @override
  Widget build(BuildContext context) {
    Widget svg = SvgPicture.asset(
      'assets/images/arrow_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );

    switch (direction) {
      case VyomArrowDirection.right:
        return svg;
      case VyomArrowDirection.left:
        return Transform.flip(flipX: true, child: svg);
      case VyomArrowDirection.up:
        return RotatedBox(quarterTurns: 3, child: svg);
      case VyomArrowDirection.down:
        return RotatedBox(quarterTurns: 1, child: svg);
    }
  }
}
