import 'package:flutter/material.dart';
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
        color: const Color(0xFF101010),
        child: SafeArea(
          top: false,
          child: Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
                _buildNavItem(1, Icons.inventory_2_outlined, Icons.inventory_2, 'Products'),
                _buildNavItem(2, Icons.insights_outlined, Icons.insights, 'Analytics'),
                _buildNavItem(3, Icons.storefront_outlined, Icons.storefront, 'Shop'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentIndex = index),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    activeIcon,
                    size: 20,
                    color: const Color(0xFF101010),
                  ),
                ),
              )
            else
              SizedBox(
                width: 32,
                height: 32,
                child: Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: const Color(0xFF8E8E8E),
                  ),
                ),
              ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? const Color(0xFFFFD400) : const Color(0xFF8E8E8E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
