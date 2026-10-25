import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/vyom_arrow.dart';
import 'otp_verification_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  final bool isFromProfile;

  const PhoneLoginScreen({
    super.key,
    this.isFromProfile = false,
  });

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  bool _isContinuePressed = false;
  bool _isBackPressed = false;
  String? _errorMessage;

  void _handleContinue() {
    final phone = _phoneController.text.trim().replaceAll(' ', '');
    if (phone.isNotEmpty && (phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone))) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit number';
      });
      return;
    }

    final validPhone = phone.isEmpty ? '9876543210' : phone;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OtpVerificationScreen(
              phoneNumber: validPhone,
              isFromProfile: widget.isFromProfile,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    // Responsive scale relative to 393px standard Figma width
    final scale = size.width / 393.0;

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
          // Top: 54px (or safe-area aware), right: 20px, size: 44x44
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

                    // White Container with solid black border
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

          // 3. Title: "LET'S GET"
          // Layout: width: 223px, height: 34px, top: 126px, left: 20px
          Positioned(
            top: 126.0 * scale,
            left: 20.0 * scale,
            width: 223.0 * scale,
            height: 42.0 * scale,
            child: const FittedBox(
              fit: BoxFit.fitHeight,
              alignment: Alignment.topLeft,
              child: Text(
                "LET'S GET",
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

          // 4. Title: "STARTED"
          // Layout: width: 201px, height: 34px, top: 172px, left: 20px
          Positioned(
            top: 172.0 * scale,
            left: 20.0 * scale,
            width: 201.0 * scale,
            height: 42.0 * scale,
            child: const FittedBox(
              fit: BoxFit.fitHeight,
              alignment: Alignment.topLeft,
              child: Text(
                'STARTED',
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

          // 5. Subtitle: "Enter your mobile number to continue"
          // Positioned nicely under the "STARTED" title
          Positioned(
            top: 224.0 * scale,
            left: 20.0 * scale,
            right: 20.0 * scale,
            child: const Text(
              'Enter your mobile number to continue',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: AppColors.foreground,
              ),
            ),
          ),

          // 6. Phone Number Input Box
          // Top: 258px, Left: 20px, Right: 20px, Height: 48px
          Positioned(
            top: 258.0 * scale,
            left: 20.0 * scale,
            right: 20.0 * scale,
            height: 48.0 * scale,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Tactile Drop Shadow
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

                // White Input Container
                Container(
                  height: 48.0 * scale,
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: AppColors.foreground,
                      width: 2.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Phone Icon
                      const Icon(
                        Icons.call_outlined,
                        color: AppColors.foreground,
                        size: 20.0,
                      ),
                      const SizedBox(width: 8),

                      // Country code: +91
                      const Text(
                        '+91',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(width: 2),

                      // Chevron Down
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.foreground,
                        size: 18.0,
                      ),
                      const SizedBox(width: 8),

                      // Divider
                      Container(
                        width: 1.2,
                        height: 22.0,
                        color: const Color(0xFFD4D4D4),
                      ),
                      const SizedBox(width: 12),

                      // Editable Phone Input Field with placeholder "98765 43210"
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          cursorColor: AppColors.foreground,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintText: '98765 43210',
                            hintStyle: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Error Message (if any)
          if (_errorMessage != null)
            Positioned(
              top: 310.0 * scale,
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

          // 7. CONTINUE Button
          // Layout: width: 362px (left: 20, right: 20), height: 46px, top: 324px
          Positioned(
            top: 324.0 * scale,
            left: 20.0 * scale,
            right: 20.0 * scale,
            height: 46.0 * scale,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isContinuePressed = true),
              onTapUp: (_) {
                setState(() => _isContinuePressed = false);
                _handleContinue();
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
                            'CONTINUE',
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

          // 8. Legal Text: "By continuing, you agree to our Terms and Privacy Policy."
          // Layout: width: 362px, height: 29px, top: 390px, left: 20px
          // Underline on "Terms and Privacy Policy."
          Positioned(
            top: 390.0 * scale,
            left: 20.0 * scale,
            right: 20.0 * scale,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: Color(0xFF767676),
                ),
                children: [
                  TextSpan(text: 'By continuing, you agree to our\n'),
                  TextSpan(
                    text: 'Terms and Privacy Policy.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.foreground,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.foreground,
                      decorationThickness: 1.2,
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
}
