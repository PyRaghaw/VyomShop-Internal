import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'customer_home_screen.dart';
import 'search_results_screen.dart';
import 'ai_search_scan_screen.dart';
import 'nearby_shops_screen.dart';
import 'customer_profile_screen.dart';
import '../../../core/widgets/neo_pressable.dart';

class CustomerNavigationShell extends StatefulWidget {
  final int initialIndex;

  const CustomerNavigationShell({super.key, this.initialIndex = 0});

  @override
  CustomerNavigationShellState createState() => CustomerNavigationShellState();
}

class CustomerNavigationShellState extends State<CustomerNavigationShell> {
  late int _currentIndex;

  void switchTab(int index) {
    if (mounted) setState(() => _currentIndex = index);
  }

  final List<Widget> _screens = const [
    CustomerHomeScreen(),
    SearchResultsScreen(),
    AiSearchScanScreen(),
    NearbyShopsScreen(),
    CustomerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
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
                _buildNavItem(0, 'assets/images/nav-home_icon.svg', 'Home'),
                _buildNavItem(1, 'assets/images/nav-search_icon.svg', 'Search'),
                _buildNavItem(2, 'assets/images/nav-scan_icon.svg', 'Scan'),
                _buildNavItem(3, 'assets/images/nav-shop_icon.svg', 'Shop'),
                _buildNavItem(4, 'assets/images/nav-profile_icon.svg', 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconAsset, String label) {
    final isSelected = _currentIndex == index;
    return NeoPressable(
      pressDepth: 1.5,
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
                  child: SvgPicture.asset(
                    iconAsset,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF101010),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 32,
                child: Center(
                  child: SvgPicture.asset(
                    iconAsset,
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF939393),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFFFFD400) : const Color(0xFF939393),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
