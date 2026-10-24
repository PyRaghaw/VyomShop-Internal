import 'package:flutter/material.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../../core/widgets/vyom_arrow.dart';
import 'shop_setup_screen.dart';

class SellerRegistrationScreen extends StatefulWidget {
  const SellerRegistrationScreen({super.key});

  @override
  State<SellerRegistrationScreen> createState() => _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopNameController = TextEditingController();
  bool _isConfirmed = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!_isConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please confirm that you own or manage this business',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF101010),
            ),
          ),
          backgroundColor: const Color(0xFFFFD400),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF101010), width: 1.5),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navigate to Page 18 (Shop setup) with Dissolve 300ms
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ShopSetupScreen(
              ownerName: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
              initialShopName: _shopNameController.text.trim(),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Back Button on the Right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NeoPressable(
                    onTap: () => Navigator.of(context).pop(),
                    width: 44,
                    height: 44,
                    pressDepth: 2.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF101010), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF101010),
                          offset: Offset(2.0, 2.5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: VyomArrow.back(
                        size: 20,
                        color: Color(0xFF101010),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title: GROW YOUR
              const Text(
                'GROW YOUR',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 48,
                  height: 0.95,
                  letterSpacing: -0.5,
                  color: Color(0xFF101010),
                ),
              ),

              // Title: BUSINESS
              const Text(
                'BUSINESS',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 48,
                  height: 0.95,
                  letterSpacing: -0.5,
                  color: Color(0xFF101010),
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Text(
                "Let's give your shop a place on VYOM",
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF323232),
                ),
              ),
              const SizedBox(height: 28),

              // Field 1: Owner's full name
              _buildFormField(
                label: "Owner's full name",
                hint: 'e.g. Aarav Sharma',
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),

              // Field 2: Email address
              _buildFormField(
                label: 'Email address',
                hint: 'aarav@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Field 3: Contact number
              _buildFormField(
                label: 'Contact number',
                hint: '98765 43210',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Field 4: Shop name
              _buildFormField(
                label: 'Shop name',
                hint: 'e.g. Sole Zone',
                controller: _shopNameController,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),

              // Checkbox: "I confirm that I own or manage this business"
              GestureDetector(
                onTap: () => setState(() => _isConfirmed = !_isConfirmed),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF000000),
                          width: 1.0,
                        ),
                      ),
                      child: _isConfirmed
                          ? const Center(
                              child: Icon(
                                Icons.check,
                                size: 14,
                                color: Color(0xFF101010),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'I confirm that I own or manage this business',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF323232),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Continue Button: CONTINUE TO SHOP SETUP →
              NeoPressable(
                onTap: _onContinue,
                height: 46,
                width: double.infinity,
                pressDepth: 2.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD400),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF101010), width: 1.4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF101010),
                      offset: Offset(2.0, 2.5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'CONTINUE TO SHOP SETUP',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 0.0,
                        color: Color(0xFF101010),
                      ),
                    ),
                    SizedBox(width: 6),
                    VyomArrow.forward(
                      size: 16,
                      color: Color(0xFF101010),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF323232),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF101010), width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF101010),
                offset: Offset(2.0, 2.5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF101010),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF939393),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
