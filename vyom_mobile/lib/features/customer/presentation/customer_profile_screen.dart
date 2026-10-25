import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/services/customer_service.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../../core/widgets/vyom_arrow.dart';
import '../../auth/presentation/choose_role_screen.dart';
import '../../auth/presentation/phone_login_screen.dart';
import '../../seller/presentation/seller_dashboard_screen.dart';
import 'customer_registration_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  @override
  void initState() {
    super.initState();
    CustomerService().loadProfile().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _navigateToRegister() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CustomerRegistrationScreen(isFromProfile: true),
      ),
    );
    await CustomerService().loadProfile();
    if (mounted) setState(() {});
  }

  Future<void> _navigateToLogin() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PhoneLoginScreen(),
      ),
    );
    await CustomerService().loadProfile();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final customer = CustomerService();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Custom Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PROFILE & SETTINGS',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF101010),
                    ),
                  ),
                  NeoPressable(
                    onTap: () {},
                    width: 44,
                    height: 44,
                    pressDepth: 1.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF101010), width: 1.6),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF101010),
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.settings_outlined, size: 20, color: Color(0xFF101010)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. User Info Neo-Card (Registered vs Guest)
              if (customer.isRegistered)
                _buildRegisteredCard(customer)
              else
                _buildGuestCard(),

              const SizedBox(height: 16),

              // 3. Switch to Seller Banner (Golden Yellow Neo-Card)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD400),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF101010), width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF101010),
                      offset: Offset(2.5, 3.0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF101010),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'OWN A BOUTIQUE?',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Showcase to local buyers',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101010),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'List inventory and reach customers around your shop.',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101010),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    NeoPressable(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SellerDashboardScreen(),
                          ),
                        );
                      },
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      pressDepth: 1.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF101010),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF101010), width: 1.5),
                      ),
                      child: const Center(
                        child: Text(
                          'Switch',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. Discovery Stats
              const Text(
                'MY DISCOVERY STATS',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF939393),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF101010), width: 1.6),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF101010),
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.favorite, color: Colors.red, size: 22),
                          const SizedBox(height: 8),
                          Text(
                            customer.isRegistered ? '4' : '0',
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101010),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Saved Finds',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B6B65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF101010), width: 1.6),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF101010),
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.camera_alt_outlined, color: Color(0xFF101010), size: 22),
                          const SizedBox(height: 8),
                          Text(
                            customer.isRegistered ? '12' : '0',
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101010),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Visual Scans',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B6B65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 5. Preferences & Settings
              const Text(
                'PREFERENCES & SUPPORT',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF939393),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 10),

              _buildNeoSettingTile(
                icon: Icons.notifications_none,
                title: 'Neighborhood Alerts',
                subtitle: 'New boutique additions and local updates',
                trailing: Switch(
                  value: true,
                  activeThumbColor: const Color(0xFF101010),
                  activeTrackColor: const Color(0xFFFFD400),
                  onChanged: (context) {},
                ),
              ),
              const SizedBox(height: 10),
              _buildNeoSettingTile(
                icon: Icons.history,
                title: 'Search History',
                subtitle: 'Clear recent searches and image scans',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _buildNeoSettingTile(
                icon: Icons.shield_outlined,
                title: 'Privacy & Permissions',
                subtitle: 'Camera, location, and storage settings',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _buildNeoSettingTile(
                icon: Icons.help_outline,
                title: 'How Visual Search Works',
                subtitle: 'Learn about our local computer vision matching',
                onTap: () {},
              ),

              const SizedBox(height: 24),

              // 6. Role Switch / Logout Button
              NeoPressable(
                onTap: () async {
                  final nav = Navigator.of(context);
                  if (customer.isRegistered) {
                    await CustomerService().resetProfile();
                  }
                  if (!mounted) return;
                  nav.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const ChooseRoleScreen()),
                    (route) => false,
                  );
                },
                height: 50,
                pressDepth: 2.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF101010), width: 1.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF101010),
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    customer.isRegistered ? 'LOGOUT / SWITCH ROLE' : 'SWITCH ROLE / CHOOSE ACCOUNT',
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF101010),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisteredCard(CustomerService customer) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF101010), width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF101010),
            offset: Offset(2.5, 3.0),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD400),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF101010), width: 2),
            ),
            child: Center(
              child: Text(
                customer.initials,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101010),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name.isNotEmpty ? customer.name : 'Shopper',
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101010),
                  ),
                ),
                const SizedBox(height: 2),
                if (customer.phone.isNotEmpty)
                  Text(
                    customer.phone,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B6B65),
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/lcn_icon.svg',
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF101010),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      customer.neighborhood,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101010),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          NeoPressable(
            onTap: _navigateToRegister,
            width: 36,
            height: 36,
            pressDepth: 1.5,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F3E8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF101010), width: 1.4),
            ),
            child: const Center(
              child: Icon(
                Icons.edit_outlined,
                size: 16,
                color: Color(0xFF101010),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF101010), width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF101010),
            offset: Offset(2.5, 3.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3E8),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF101010), width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 28,
                    color: Color(0xFF101010),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'GUEST SHOPPER',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            color: Color(0xFF101010),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD400),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF101010), width: 1.0),
                          ),
                          child: const Text(
                            'GUEST',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Color(0xFF101010),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Exploring local boutique catalog',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B6B65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F3E8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF101010), width: 1.2),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFF101010)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Create a profile or login to save favorites & get local boutique drops',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF323232),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 2 Prominent Buttons: REGISTER & LOGIN
          Row(
            children: [
              // REGISTER BUTTON
              Expanded(
                child: NeoPressable(
                  onTap: _navigateToRegister,
                  height: 44,
                  pressDepth: 2.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD400),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF101010), width: 1.6),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_alt_1_outlined, size: 16, color: Color(0xFF101010)),
                      SizedBox(width: 6),
                      Text(
                        'REGISTER',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          color: Color(0xFF101010),
                        ),
                      ),
                      SizedBox(width: 4),
                      VyomArrow.forward(
                        size: 13,
                        color: Color(0xFF101010),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // LOGIN BUTTON
              Expanded(
                child: NeoPressable(
                  onTap: _navigateToLogin,
                  height: 44,
                  pressDepth: 2.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF101010), width: 1.6),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login_rounded, size: 16, color: Color(0xFF101010)),
                      SizedBox(width: 6),
                      Text(
                        'LOGIN',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          color: Color(0xFF101010),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNeoSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF101010), width: 1.6),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF101010),
              offset: Offset(2.0, 2.0),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF101010), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101010),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B6B65),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing else const Icon(Icons.chevron_right, color: Color(0xFF101010)),
          ],
        ),
      ),
    );
  }
}
