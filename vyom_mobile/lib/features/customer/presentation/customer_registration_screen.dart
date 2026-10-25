import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/services/customer_service.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../../core/widgets/vyom_arrow.dart';
import 'customer_navigation_shell.dart';

class CustomerRegistrationScreen extends StatefulWidget {
  final String? initialPhone;

  const CustomerRegistrationScreen({
    super.key,
    this.initialPhone,
  });

  @override
  State<CustomerRegistrationScreen> createState() => _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState extends State<CustomerRegistrationScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  String _selectedNeighborhood = 'Salt Lake, Kolkata';
  final Set<String> _selectedCategories = {'Clothing', 'Footwear'};
  bool _isOffersAgreed = true;

  final List<String> _neighborhoods = [
    'Salt Lake, Kolkata',
    'Park Street, Kolkata',
    'New Town, Kolkata',
    'Ballygunge, Kolkata',
    'Indiranagar, Bengaluru',
    'Koramangala, Bengaluru',
  ];

  final List<String> _availableCategories = [
    'Clothing',
    'Footwear',
    'Accessories',
    'Jewellery',
    'Bags',
    'Sportswear',
    'Innerwear',
    'Kidswear',
  ];

  @override
  void initState() {
    super.initState();
    final customer = CustomerService();
    _nameController = TextEditingController(text: customer.isRegistered ? customer.name : '');
    _phoneController = TextEditingController(
      text: widget.initialPhone ?? (customer.isRegistered ? customer.phone : ''),
    );
    _emailController = TextEditingController(text: customer.isRegistered ? customer.email : '');
    _selectedNeighborhood = customer.neighborhood;
    if (customer.favoriteCategories.isNotEmpty) {
      _selectedCategories.addAll(customer.favoriteCategories);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showNeighborhoodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F3E8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Color(0xFF101010), width: 2.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PRIMARY SHOPPING AREA',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF939393),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose your neighborhood',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101010),
                ),
              ),
              const SizedBox(height: 16),
              ..._neighborhoods.map((n) {
                final isSelected = n == _selectedNeighborhood;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_on_outlined, color: Color(0xFF101010)),
                  title: Text(
                    n,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: const Color(0xFF101010),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFFFFD400))
                      : null,
                  onTap: () {
                    setState(() => _selectedNeighborhood = n);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onStartShopping() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showWarning('Please enter your full name');
      return;
    }
    if (phone.isEmpty) {
      _showWarning('Please enter your contact number');
      return;
    }

    // Save profile to CustomerService and SharedPreferences
    await CustomerService().saveProfile(
      name: name,
      phone: phone,
      email: _emailController.text.trim(),
      neighborhood: _selectedNeighborhood,
      favoriteCategories: _selectedCategories.toList(),
    );

    if (!mounted) return;

    // Navigate to CustomerNavigationShell
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CustomerNavigationShell(),
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
      (route) => false,
    );
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CUSTOMER ONBOARDING',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF939393),
                      letterSpacing: 0.5,
                    ),
                  ),
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

              // Title: EXPLORE LOCAL
              const Text(
                'EXPLORE LOCAL',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 48,
                  height: 0.95,
                  letterSpacing: -0.5,
                  color: Color(0xFF101010),
                ),
              ),

              // Title: BOUTIQUES
              const Text(
                'BOUTIQUES',
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
                'Tell us a bit about you to discover nearby gems',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF323232),
                ),
              ),
              const SizedBox(height: 28),

              // Field 1: Full name
              _buildFormField(
                label: 'Your full name',
                hint: 'e.g. Alex Kumar',
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),

              // Field 2: Contact number
              _buildFormField(
                label: 'Phone number',
                hint: '98765 43210',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Field 3: Email address
              _buildFormField(
                label: 'Email address (optional)',
                hint: 'alex@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Field 4: Shopping neighborhood picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Primary shopping area',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF323232),
                    ),
                  ),
                  const SizedBox(height: 8),
                  NeoPressable(
                    onTap: _showNeighborhoodPicker,
                    height: 54,
                    pressDepth: 2.0,
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
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/lcn_icon.svg',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedNeighborhood,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF101010),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: Color(0xFF101010),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Field 5: Favorite categories
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Favorite categories to explore',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF323232),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableCategories.map((cat) {
                      final isSelected = _selectedCategories.contains(cat);
                      return NeoPressable(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              if (_selectedCategories.length > 1) {
                                _selectedCategories.remove(cat);
                              }
                            } else {
                              _selectedCategories.add(cat);
                            }
                          });
                        },
                        pressDepth: 1.5,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFD400) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF101010), width: 1.2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF101010),
                              offset: Offset(1.5, 1.5),
                            ),
                          ],
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 12,
                            color: const Color(0xFF101010),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Checkbox: "Keep me updated on local boutique offers"
              GestureDetector(
                onTap: () => setState(() => _isOffersAgreed = !_isOffersAgreed),
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
                      child: _isOffersAgreed
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
                        'Keep me updated on new local drops, sales & boutique arrivals',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Color(0xFF323232),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Continue Button: START SHOPPING →
              NeoPressable(
                onTap: _onStartShopping,
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
                      'START SHOPPING',
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
              const SizedBox(height: 12),

              // Skip option
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const CustomerNavigationShell(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B6B65),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
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
