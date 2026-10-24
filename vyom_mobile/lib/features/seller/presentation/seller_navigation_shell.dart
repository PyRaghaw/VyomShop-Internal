import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'seller_dashboard_screen.dart';
import 'my_products_screen.dart';
import 'seller_analytics_screen.dart';
import 'shop_profile_screen.dart';

class SellerNavigationShell extends StatefulWidget {
  final int initialIndex;

  const SellerNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<SellerNavigationShell> createState() => _SellerNavigationShellState();
}

class _SellerNavigationShellState extends State<SellerNavigationShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    SellerDashboardScreen(),
    MyProductsScreen(),
    SellerAnalyticsScreen(),
    ShopProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.foreground, width: 2.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, -2),
              blurRadius: 4,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(index: 0, icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
                _buildNavItem(index: 1, icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Products'),
                _buildNavItem(index: 2, icon: Icons.insights_outlined, activeIcon: Icons.insights, label: 'Analytics'),
                _buildNavItem(index: 3, icon: Icons.storefront_outlined, activeIcon: Icons.storefront, label: 'Boutique'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.mutedForeground,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
