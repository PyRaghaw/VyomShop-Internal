import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/vyom_arrow.dart';
import 'choose_role_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final TextEditingController _pinController;
  bool _isContinuePressed = false;
  bool _isBackPressed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Blank by default so the user can enter their own OTP
    _pinController = TextEditingController();
  }

  void _handleVerify() {
    final code = _pinController.text.trim();
    if (code.length != 4) {
      setState(() {
        _errorMessage = 'Please enter the 4-digit verification code';
      });
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ChooseRoleScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String raw) {
    final clean = raw.replaceAll(' ', '');
    if (clean.length == 10) {
      return '${clean.substring(0, 5)} ${clean.substring(5)}';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    // Responsive scale relative to 393px standard Figma width
    final scale = size.width / 393.0;

    final defaultPinTheme = PinTheme(
      width: 72.0 * scale,
      height: 82.0 * scale,
      textStyle: const TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        color: AppColors.foreground,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: AppColors.foreground,
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.foreground,
            offset: Offset(2.5, 2.5),
            blurRadius: 0,
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: AppColors.foreground,
        width: 2.4,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Bottom Building Image Layer
          // Layout: width: 618px, height: 404px, top: 521px, left: -124px
          Positioned(
            left: -124.0 * scale,
            top: 521.0 * scale,
            width: 618.0 * scale,
            height: 404.0 * scale,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/login_street_bg.png',
                fit: BoxFit.fill,
              ),
            ),
          ),

          // 2. Top Right Back Button
          // Size: 44x44, White bg, 2px black border, 2.5px black tactile shadow
          Positioned(
            top: mediaQuery.padding.top > 0
                ? mediaQuery.padding.top + 8.0
                : 54.0 * scale,
            right: 20.0 * scale,
            width: 44.0 * scale,
            height: 44.0 * scale,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isBackPressed = true),
              onTapUp: (_) {
                setState(() => _isBackPressed = false);
                Navigator.of(context).pop();
              },
              onTapCancel: () => setState(() => _isBackPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                transform: Matrix4.translationValues(
                  _isBackPressed ? 2.5 : 0.0,
                  _isBackPressed ? 2.5 : 0.0,
                  0.0,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Tactile Drop Shadow
                    if (!_isBackPressed)
                      Positioned(
                        top: 2.5,
                        left: 2.5,
                        right: -2.5,
                        bottom: -2.5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.foreground,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),

                    // White container with black border
                    Container(
                      width: 44.0 * scale,
                      height: 44.0 * scale,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: AppColors.foreground,
                          width: 2.0,
                        ),
                      ),
                      child: const Center(
                        child: VyomArrow.back(
                          color: AppColors.foreground,
                          size: 20.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Title: "OTP"
          // Layout: width: 89px, height: 34px, top: 126px, left: 20px
          Positioned(
            top: 126.0 * scale,
            left: 20.0 * scale,
            width: 120.0 * scale,
            height: 42.0 * scale,
            child: const FittedBox(
              fit: BoxFit.fitHeight,
              alignment: Alignment.topLeft,
              child: Text(
                'OTP',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 48.0,
                  fontWeight: FontWeight.w700,
                  height: 0.9,
                  letterSpacing: -0.5,
                  color: AppColors.foreground,
                ),
              ),
            ),
          ),

          // 4. Title: "VERIFICATION"
          // Layout: width: 301px, height: 34px, top: 172px, left: 20px
          Positioned(
            top: 172.0 * scale,
            left: 20.0 * scale,
            width: 320.0 * scale,
            height: 42.0 * scale,
            child: const FittedBox(
              fit: BoxFit.fitHeight,
              alignment: Alignment.topLeft,
              child: Text(
                'VERIFICATION',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 48.0,
                  fontWeight: FontWeight.w700,
                  height: 0.9,
                  letterSpacing: -0.5,
                  color: AppColors.foreground,
                ),
              ),
            ),
          ),

          // 5. Subtitle: "We've sent a 4-digit code to (+91 98765 43210)"
          // Strictly single line with scaleDown so it never wraps
          Positioned(
            top: 224.0 * scale,
            left: 20.0 * scale,
            right: 20.0 * scale,
            height: 22.0 * scale,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "We've sent a 4-digit code to (+91 ${_formatPhoneNumber(widget.phoneNumber)})",
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.foreground,
                ),
              ),
            ),
          ),

          // 6. 4-Digit OTP Input Boxes (Blank by default for user entry)
          // Top: 260px, Left: 20px, Right: 20px, Height: 82px
          Positioned(
            top: 260.0 * scale,
            left: 20.0 * scale,
            right: 20.0 * scale,
            child: Center(
              child: Pinput(
                length: 4,
                controller: _pinController,
                autofocus: true,
                keyboardType: TextInputType.number,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                separatorBuilder: (index) => SizedBox(width: 14.0 * scale),
                cursor: Container(
                  width: 2.0,
                  height: 32.0,
                  color: AppColors.foreground,
                ),
                onCompleted: (pin) => _handleVerify(),
              ),
            ),
          ),

          // Error Message (if any)
          if (_errorMessage != null)
            Positioned(
              top: 344.0 * scale,
              left: 24.0 * scale,
              right: 20.0 * scale,
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),

          // 7. VERIFY AND CONTINUE Button
          // Layout: width: 362px (left: 20, right: 20), height: 46px, top: 362px
          Positioned(
            top: 362.0 * scale,
            left: 20.0 * scale,
            right: 20.0 * scale,
            height: 46.0 * scale,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isContinuePressed = true),
              onTapUp: (_) {
                setState(() => _isContinuePressed = false);
                _handleVerify();
              },
              onTapCancel: () => setState(() => _isContinuePressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                transform: Matrix4.translationValues(
                  _isContinuePressed ? 2.5 : 0.0,
                  _isContinuePressed ? 2.5 : 0.0,
                  0.0,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Tactile Black Drop Shadow
                    if (!_isContinuePressed)
                      Positioned(
                        top: 2.5,
                        left: 2.5,
                        right: -2.5,
                        bottom: -2.5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.foreground,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),

                    // Yellow Button Body
                    Container(
                      height: 46.0 * scale,
                      decoration: BoxDecoration(
                        color: AppColors.brandYellow,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: AppColors.foreground,
                          width: 2.0,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'VERIFY AND CONTINUE',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppColors.foreground,
                            ),
                          ),
                          SizedBox(width: 8),
                          VyomArrow.forward(
                            color: AppColors.foreground,
                            size: 18.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 8. Resend OTP Row
          // Left: "Didn't receive the OTP?", Right: "Resend OTP" (underlined)
          // Top: 424px, Left: 20px, Right: 20px
          Positioned(
            top: 424.0 * scale,
            left: 20.0 * scale,
            right: 20.0 * scale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Didn't receive the OTP?",
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF767676),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('OTP resent successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.foreground,
                      decorationThickness: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
