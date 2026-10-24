import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/vyom_arrow.dart';
import 'phone_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    // Responsive scale relative to the 393px Figma screen frame
    final scale = size.width / 393.0;

    return Scaffold(
      backgroundColor: AppColors.brandYellow,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Exact Figma Diagonal Stripes Background (#FFD829 on #FFD400)
          CustomPaint(
            size: size,
            painter: DiagonalStripesPainter(scale: scale),
          ),

          // 2. High-Resolution Transparent Grayscale Hero Portrait Layer
          Positioned(
            left: -115.0 * scale,
            top: 365.0 * scale,
            width: 598.0 * scale,
            height: 747.0 * scale,
            child: Image.asset(
              'assets/images/onboarding_girl_transparent.png',
              fit: BoxFit.fill,
            ),
          ),

          // 3. Exact Typography & Brand Lockup
          // "VYOM" - top: 126px, left: 21.8px, width: 261px, height: 70px
          Positioned(
            top: 126.0 * scale,
            left: 21.8 * scale,
            width: 261.0 * scale,
            height: 70.0 * scale,
            child: const FittedBox(
              fit: BoxFit.fitWidth,
              alignment: Alignment.topLeft,
              child: Text(
                'VYOM',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 82.0,
                  fontWeight: FontWeight.w700,
                  height: 0.85,
                  letterSpacing: -0.5,
                  color: AppColors.foreground,
                ),
              ),
            ),
          ),

          // "SHOP" - top: 207.5px, left: 205.8px, width: 164.2px, height: 48px
          // "SH" sits directly underneath "M" of "VYOM", leaving compact margin on right
          Positioned(
            top: 207.5 * scale,
            left: 205.8 * scale,
            width: 164.2 * scale,
            height: 48.0 * scale,
            child: const FittedBox(
              fit: BoxFit.fitWidth,
              alignment: Alignment.topLeft,
              child: Text(
                'SHOP',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 56.0,
                  fontWeight: FontWeight.w700,
                  height: 0.85,
                  letterSpacing: -0.5,
                  color: AppColors.foreground,
                ),
              ),
            ),
          ),

          // "GOOD FINDS. RIGHT NEAR YOU." - top: 277.06px, left: 20px, width: 365px, height: 24px
          Positioned(
            top: 277.06 * scale,
            left: 20.0 * scale,
            width: 365.0 * scale,
            height: 24.0 * scale,
            child: const FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              child: Text(
                'GOOD FINDS. RIGHT NEAR YOU.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 25.01,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                  letterSpacing: 0.0,
                  color: AppColors.foreground,
                ),
              ),
            ),
          ),

          // "Discover great products and hidden gems in your neighbourhood." - top: 307.06px, left: 20px, width: 365px, height: 16px
          Positioned(
            top: 307.06 * scale,
            left: 20.0 * scale,
            width: 365.0 * scale,
            height: 16.0 * scale,
            child: const FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              child: Text(
                'Discover great products and hidden gems in your neighbourhood.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12.1,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                  letterSpacing: 0.0,
                  color: AppColors.foreground,
                ),
              ),
            ),
          ),

          // 4. Compact Neo-Brutalist Call-To-Action Button near bottom
          Positioned(
            left: 20.0 * scale,
            right: 20.0 * scale,
            bottom: mediaQuery.padding.bottom > 0
                ? mediaQuery.padding.bottom + 16.0
                : 36.0 * scale,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) {
                setState(() => _isPressed = false);
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const PhoneLoginScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                transform: Matrix4.translationValues(
                  _isPressed ? 2.5 : 0.0,
                  _isPressed ? 2.5 : 0.0,
                  0.0,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Layered Tactile White Drop Shadow with Black Border
                    if (!_isPressed)
                      Positioned(
                        top: 3.5,
                        left: 3.5,
                        right: -3.5,
                        bottom: -3.5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                              color: AppColors.foreground,
                              width: 2.2,
                            ),
                          ),
                        ),
                      ),

                    // Foreground Yellow Button Container
                    Container(
                      height: 46.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.brandYellow,
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          color: AppColors.foreground,
                          width: 2.2,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'GET STARTED',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppColors.foreground,
                            ),
                          ),
                          SizedBox(width: 8),
                          VyomArrow.forward(
                            color: AppColors.foreground,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter to draw the signature Figma diagonal speed stripes:
/// Stripes slope from the top-right of the screen diagonally down towards the bottom-left.
/// dx / dy = -0.44, wHoriz = 52.57px, period = 75.65px, startX = 219.26px at y=0.
class DiagonalStripesPainter extends CustomPainter {
  final double scale;

  DiagonalStripesPainter({this.scale = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base vibrant brand yellow background (#FFD400)
    final bgPaint = Paint()..color = AppColors.brandYellow;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Diagonal stripes (#FFD829)
    final stripePaint = Paint()
      ..color = AppColors.brandYellowLight
      ..style = PaintingStyle.fill;

    // Measured from Figma actual reference:
    // Slope: dx / dy = -0.44 (slopes from top-right towards bottom-left)
    const dxDy = -0.44;
    final wHoriz = 52.57 * scale;
    final period = 75.65 * scale;
    final firstX0 = 219.26 * scale;

    final h = size.height;
    final dxTotal = dxDy * h;

    // Draw the 6 stripes originating from top-right and covering across the screen to bottom-left
    for (int i = 0; i < 7; i++) {
      final x0 = firstX0 + (i * period);
      final path = Path()
        ..moveTo(x0, 0)
        ..lineTo(x0 + wHoriz, 0)
        ..lineTo(x0 + wHoriz + dxTotal, h)
        ..lineTo(x0 + dxTotal, h)
        ..close();

      canvas.drawPath(path, stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant DiagonalStripesPainter oldDelegate) =>
      oldDelegate.scale != scale;
}
