import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../auth/presentation/choose_role_screen.dart';
import '../../seller/presentation/seller_dashboard_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

              // 2. User Info Neo-Card
              Container(
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
                      child: const Center(
                        child: Text(
                          'AK',
                          style: TextStyle(
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
                          const Text(
                            'Alex Kumar',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101010),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '+91 98765 43210',
                            style: TextStyle(
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
                              const Text(
                                'Salt Lake, Kolkata',
                                style: TextStyle(
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
                  ],
                ),
              ),

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
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.favorite, color: Colors.red, size: 22),
                          SizedBox(height: 8),
                          Text(
                            '4',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101010),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
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
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: Color(0xFF101010), size: 22),
                          SizedBox(height: 8),
                          Text(
                            '12',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101010),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
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
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
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
                child: const Center(
                  child: Text(
                    'SWITCH ROLE / LOGOUT',
                    style: TextStyle(
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
