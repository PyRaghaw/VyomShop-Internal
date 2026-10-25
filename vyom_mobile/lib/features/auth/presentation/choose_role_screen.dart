import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/vyom_arrow.dart';
import '../../customer/presentation/customer_registration_screen.dart';
import '../../seller/presentation/seller_registration_screen.dart';

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  bool _isCustomerPressed = false;
  bool _isSellerPressed = false;

  void _navigateToRole(bool isCustomer) {
    if (isCustomer) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const CustomerRegistrationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SellerRegistrationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    // Responsive scale relative to 393px standard Figma width
    final scale = size.width / 393.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
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

          // 2. Title: "HOW WILL YOU"
          // Layout: width: 330px, height: 34px, top: 126px, left: 20px
          Positioned(
            top: 126.0 * scale,
            left: 20.0 * scale,
            width: 330.0 * scale,
            height: 42.0 * scale,
            child: const FittedBox(
              fit: BoxFit.fitHeight,
              alignment: Alignment.topLeft,
              child: Text(
                'HOW WILL YOU',
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

          // 3. Title: "USE VYOM"
          // Layout: width: 233px, height: 34px, top: 172px, left: 20px
          Positioned(
            top: 172.0 * scale,
            left: 20.0 * scale,
            width: 233.0 * scale,
            height: 42.0 * scale,
            child: const FittedBox(
              fit: BoxFit.fitHeight,
              alignment: Alignment.topLeft,
              child: Text(
                'USE VYOM',
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

          // 4. Subtitle: "You can switch roles later in settings"
          // Layout: width: 348px, height: 12px, top: 222px, left: 20px
          Positioned(
            top: 222.0 * scale,
            left: 20.0 * scale,
            right: 20.0 * scale,
            height: 22.0 * scale,
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'You can switch roles later in settings',
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.foreground,
                ),
              ),
            ),
          ),

          // 5. Card 1: "I'M A CUSTOMER"
          // Layout: width: 362px, height: 94px, top: 258px, left: 20px
          Positioned(
            top: 258.0 * scale,
            left: 20.0 * scale,
            right: 20.0 * scale,
            height: 94.0 * scale,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isCustomerPressed = true),
              onTapUp: (_) {
                setState(() => _isCustomerPressed = false);
                _navigateToRole(true);
              },
              onTapCancel: () => setState(() => _isCustomerPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                transform: Matrix4.translationValues(
                  _isCustomerPressed ? 2.5 : 0.0,
                  _isCustomerPressed ? 2.5 : 0.0,
                  0.0,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Tactile Drop Shadow
                    if (!_isCustomerPressed)
                      Positioned(
                        top: 3.5 * scale,
                        left: 3.0 * scale,
                        right: -3.0 * scale,
                        bottom: -3.5 * scale,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.foreground,
                            borderRadius: BorderRadius.circular(14.0 * scale),
                          ),
                        ),
                      ),

                    // White Card Body
                    Container(
                      height: 94.0 * scale,
                      padding: EdgeInsets.only(
                        left: 18.0 * scale,
                        right: 20.0 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.0 * scale),
                        border: Border.all(
                          color: AppColors.foreground,
                          width: 2.0 * scale,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Customer Bag Icon
                          Image.asset(
                            'assets/images/role_customer_icon.png',
                            width: 52.0 * scale,
                            height: 50.0 * scale,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 16.0 * scale),

                          // Text Content
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "I'M A CUSTOMER",
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 16.0 * scale,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                    letterSpacing: 0.0,
                                    color: AppColors.foreground,
                                  ),
                                ),
                                SizedBox(height: 5.0 * scale),
                                Text(
                                  'Discover products at local stores.',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 12.0 * scale,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                    letterSpacing: 0.0,
                                    color: AppColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Arrow Forward
                          VyomArrow.forward(
                            color: AppColors.foreground,
                            size: 22.0 * scale,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 6. Card 2: "I'M A SELLER"
          // Layout: width: 362px, height: 94px, top: 372px, left: 20px
          Positioned(
            top: 372.0 * scale,
            left: 20.0 * scale,
            right: 20.0 * scale,
            height: 94.0 * scale,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isSellerPressed = true),
              onTapUp: (_) {
                setState(() => _isSellerPressed = false);
                _navigateToRole(false);
              },
              onTapCancel: () => setState(() => _isSellerPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                transform: Matrix4.translationValues(
                  _isSellerPressed ? 2.5 : 0.0,
                  _isSellerPressed ? 2.5 : 0.0,
                  0.0,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Tactile Drop Shadow
                    if (!_isSellerPressed)
                      Positioned(
                        top: 3.5 * scale,
                        left: 3.0 * scale,
                        right: -3.0 * scale,
                        bottom: -3.5 * scale,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.foreground,
                            borderRadius: BorderRadius.circular(14.0 * scale),
                          ),
                        ),
                      ),

                    // Yellow Card Body
                    Container(
                      height: 94.0 * scale,
                      padding: EdgeInsets.only(
                        left: 18.0 * scale,
                        right: 20.0 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandYellow,
                        borderRadius: BorderRadius.circular(14.0 * scale),
                        border: Border.all(
                          color: AppColors.foreground,
                          width: 2.0 * scale,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Seller Store Icon
                          Image.asset(
                            'assets/images/role_seller_icon.png',
                            width: 52.0 * scale,
                            height: 50.0 * scale,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 16.0 * scale),

                          // Text Content
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "I'M A SELLER",
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 16.0 * scale,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                    letterSpacing: 0.0,
                                    color: AppColors.foreground,
                                  ),
                                ),
                                SizedBox(height: 5.0 * scale),
                                Text(
                                  'List products and grow your shop.',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 12.0 * scale,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                    letterSpacing: 0.0,
                                    color: AppColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Arrow Forward
                          VyomArrow.forward(
                            color: AppColors.foreground,
                            size: 22.0 * scale,
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
