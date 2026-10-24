import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../core/widgets/neo_pill.dart';
import '../../../core/widgets/neo_button.dart';
import '../../auth/presentation/choose_role_screen.dart';
import '../../seller/presentation/seller_dashboard_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.foreground),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Card
            NeoCard(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.foreground, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        'AK',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alex Kumar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '+91 98765 43210',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Icon(Icons.location_on, size: 13, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Indiranagar, Bengaluru',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
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

            // Switch to Seller Banner
            NeoCard(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        NeoPill(
                          text: 'OWN A BOUTIQUE?',
                          tone: NeoPillTone.orange,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Showcase in your area',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'List products for just ₹10. Reach nearby shoppers.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  NeoButton(
                    text: 'Switch',
                    variant: NeoButtonVariant.dark,
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const SellerDashboardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Discovery Stats & Saved Items
            const Text(
              'MY DISCOVERY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.mutedForeground,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: NeoCard(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: AppColors.softPink,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.favorite, color: Colors.pink, size: 24),
                        SizedBox(height: 8),
                        Text('4', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                        SizedBox(height: 2),
                        Text('Saved Finds', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeoCard(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: AppColors.softYellow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.camera_alt, color: AppColors.foreground, size: 24),
                        SizedBox(height: 8),
                        Text('12', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                        SizedBox(height: 2),
                        Text('Visual Scans', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Settings Menu Items
            const Text(
              'PREFERENCES & SUPPORT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.mutedForeground,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),

            _buildSettingTile(
              icon: Icons.notifications_none,
              title: 'Neighborhood Alerts',
              subtitle: 'New boutique additions and weekly edits',
              trailing: Switch(
                value: true,
                activeTrackColor: AppColors.primary,
                onChanged: (_) {},
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: Icons.history,
              title: 'Search History',
              subtitle: 'Clear recent searches and image cache',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: Icons.shield_outlined,
              title: 'Privacy & Permissions',
              subtitle: 'Camera, location, and storage access',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: Icons.help_outline,
              title: 'How Visual Search Works',
              subtitle: 'Learn about our on-device visual matching',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // Logout & Role Selector
            NeoButton(
              text: 'Switch Role / Re-login',
              variant: NeoButtonVariant.secondary,
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const ChooseRoleScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NeoCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        backgroundColor: Colors.white,
        child: Row(
          children: [
            Icon(icon, color: AppColors.foreground, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing else const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}
