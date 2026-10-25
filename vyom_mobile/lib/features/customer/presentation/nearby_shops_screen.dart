import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/shop_model.dart';
import '../../../core/services/shop_service.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../../core/widgets/shop_card_widget.dart';
import '../../../core/widgets/vyom_arrow.dart';
import 'ai_search_scan_screen.dart';
import 'search_results_screen.dart';

class NearbyShopsScreen extends StatefulWidget {
  const NearbyShopsScreen({super.key});

  @override
  State<NearbyShopsScreen> createState() => _NearbyShopsScreenState();
}

class _NearbyShopsScreenState extends State<NearbyShopsScreen> {
  String _selectedNeighborhood = 'Salt Lake, Kolkata';
  String _selectedCategory = 'All';
  double _maxDistance = 10.0;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _favoriteShopNames = {};

  final List<String> _neighborhoods = [
    'Salt Lake, Kolkata',
    'Park Street, Kolkata',
    'New Town, Kolkata',
    'Ballygunge, Kolkata',
    'Indiranagar, Bengaluru',
    'Koramangala, Bengaluru',
  ];

  // Exact same categories and SVGs used in CustomerHomeScreen
  final List<Map<String, String>> _categories = [
    {'name': 'All', 'icon': 'assets/images/nav-shop_icon.svg'},
    {'name': 'Clothing', 'icon': 'assets/images/clothing_icon.svg'},
    {'name': 'Footwear', 'icon': 'assets/images/footwear_icon.svg'},
    {'name': 'Accessories', 'icon': 'assets/images/acc_icon.svg'},
    {'name': 'Jewellery', 'icon': 'assets/images/jewellery_icon.svg'},
    {'name': 'Bags', 'icon': 'assets/images/bags_icon.svg'},
    {'name': 'Sportswear', 'icon': 'assets/images/sports_icon.svg'},
    {'name': 'Innerwear', 'icon': 'assets/images/innerwear_icon.svg'},
    {'name': 'Kidswear', 'icon': 'assets/images/kids_icon.svg'},
  ];

  final ShopService _shopService = ShopService();
  List<ShopModel> _shops = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate with mock shops so UI always has rich boutique data
    _shops = _shopService.cachedShops.isNotEmpty
        ? _shopService.cachedShops
        : MockData.shops;
    _loadShops();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadShops() async {
    setState(() => _isLoading = true);
    try {
      final fetched = await _shopService.getNearbyShops(maxDistance: _maxDistance);
      if (mounted) {
        setState(() {
          _shops = fetched.isNotEmpty ? fetched : MockData.shops;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _shops = MockData.shops;
          _isLoading = false;
        });
      }
    }
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
                'SHOPPING NEAR',
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
                'Choose your shopping neighborhood',
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
                    _loadShops();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F3E8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Color(0xFF101010), width: 2.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FILTER SHOPS',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101010),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF101010), width: 1.5),
                          ),
                          child: const Icon(Icons.close, size: 18, color: Color(0xFF101010)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'MAXIMUM DISTANCE',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF939393),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Within ${_maxDistance.toInt()} km',
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101010),
                        ),
                      ),
                      Text(
                        '${_maxDistance.toStringAsFixed(1)} km radius',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B6B65),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF101010),
                      inactiveTrackColor: const Color(0xFFE0DDD5),
                      thumbColor: const Color(0xFFFFD400),
                      overlayColor: const Color(0xFFFFD400).withValues(alpha: 0.2),
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      value: _maxDistance,
                      min: 1.0,
                      max: 15.0,
                      divisions: 14,
                      onChanged: (val) {
                        setModalState(() => _maxDistance = val);
                        setState(() => _maxDistance = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  NeoPressable(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _loadShops();
                    },
                    height: 48,
                    pressDepth: 2.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD400),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF101010), width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF101010),
                          offset: Offset(2.5, 3.0),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'APPLY FILTERS',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Color(0xFF101010),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final filteredShops = _shops.where((shop) {
      final matchesCategory = _selectedCategory == 'All' ||
          shop.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchesDistance = shop.distanceKm <= _maxDistance;
      final matchesSearch = query.isEmpty ||
          shop.name.toLowerCase().contains(query) ||
          shop.category.toLowerCase().contains(query) ||
          shop.address.toLowerCase().contains(query) ||
          shop.neighborhood.toLowerCase().contains(query);

      return matchesCategory && matchesDistance && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar: EXACT same tokens as CustomerHomeScreen
              _buildTopBar(),
              const SizedBox(height: 14),

              // 2. Hero Yellow Banner: EXACT same Figma layout and BebasNeue as CustomerHomeScreen
              _buildHeroBanner(),
              const SizedBox(height: 14),

              // 3. Search Bar: EXACT same tokens as CustomerHomeScreen with black arrow forward button
              _buildSearchBar(),
              const SizedBox(height: 22),

              // 4. SHOP BY CATEGORY: EXACT same 58x58 square animated cards with SVGs as CustomerHomeScreen
              _buildShopByCategory(),
              const SizedBox(height: 24),

              // 5. NEARBY SHOPS SECTION: Section title and list of ShopCardWidget
              _buildNearbyShopsSection(filteredShops),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. Top Bar: EXACT CustomerHomeScreen copy ---
  Widget _buildTopBar() {
    return Row(
      children: [
        // Location Selector Box
        Expanded(
          child: NeoPressable(
            onTap: _showNeighborhoodPicker,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            pressDepth: 2.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                // Location Pin Icon - exact same asset and size, NO colorFilter
                SvgPicture.asset(
                  'assets/images/lcn_icon.svg',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SHOPPING NEAR',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF939393),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _selectedNeighborhood,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101010),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: Color(0xFF101010),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Filter Button: Exact same dimensions, radius, border, and shadow as Notification Button in Home
        NeoPressable(
          onTap: _showFilterModal,
          width: 52,
          height: 52,
          pressDepth: 2.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF101010), width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF101010),
                offset: Offset(2.5, 3.0),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/images/filter_icon.svg',
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. Hero Yellow Banner: EXACT same Figma design as CustomerHomeScreen ---
  Widget _buildHeroBanner() {
    return Container(
      height: 148,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD400),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF101010), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF101010),
            offset: Offset(3.0, 3.5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Right Fashion Model Cutout Image
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 158,
              child: Image.asset(
                'assets/images/cropped image vyom model.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
              ),
            ),

            // Text: VYOM SHOPS
            const Positioned(
              left: 16,
              top: 14,
              child: Text(
                'LOCAL BOUTIQUES',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  height: 1.0,
                  letterSpacing: 0.0,
                  color: Color(0xFF101010),
                ),
              ),
            ),

            // Text: GOOD FINDS.
            const Positioned(
              left: 16,
              top: 30,
              child: Text(
                'GOOD FINDS.',
                softWrap: false,
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontWeight: FontWeight.w400,
                  fontSize: 40,
                  height: 0.95,
                  letterSpacing: 0.0,
                  color: Color(0xFF101010),
                ),
              ),
            ),

            // Text: RIGHT NEAR YOU.
            const Positioned(
              left: 16,
              top: 64,
              child: Text(
                'RIGHT NEAR YOU.',
                softWrap: false,
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontWeight: FontWeight.w400,
                  fontSize: 40,
                  height: 0.95,
                  letterSpacing: 0.0,
                  color: Color(0xFF101010),
                ),
              ),
            ),

            // Button: SCAN A PRODUCT →
            Positioned(
              left: 16,
              top: 104,
              child: NeoPressable(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AiSearchScanScreen()),
                  );
                },
                height: 26,
                pressDepth: 1.5,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF101010), width: 1.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF101010),
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      'SCAN A PRODUCT',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: Color(0xFF101010),
                      ),
                    ),
                    SizedBox(width: 6),
                    VyomArrow.forward(
                      size: 10,
                      color: Color(0xFF101010),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. Search Bar: EXACT CustomerHomeScreen copy with black arrow button ---
  Widget _buildSearchBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 14, right: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          const Icon(
            Icons.search,
            size: 22,
            color: Color(0xFF101010),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {}),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101010),
              ),
              decoration: const InputDecoration(
                hintText: 'Search products, brands or shops',
                hintStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF939393),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // Black Arrow Button
          NeoPressable(
            onTap: () {
              final query = _searchController.text.trim();
              if (query.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SearchResultsScreen(initialQuery: query),
                  ),
                );
              }
            },
            width: 36,
            height: 36,
            pressDepth: 1.8,
            decoration: BoxDecoration(
              color: const Color(0xFF101010),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF323232),
                  offset: Offset(1.5, 1.5),
                ),
              ],
            ),
            child: const Center(
              child: VyomArrow.forward(
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. SHOP BY CATEGORY: EXACT CustomerHomeScreen copy with 58x58 square animated cards ---
  Widget _buildShopByCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SHOP BY CATEGORY',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.0,
            color: Color(0xFF101010),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: _categories.asMap().entries.map((entry) {
              final index = entry.key;
              final cat = entry.value;
              final isSelected = _selectedCategory.toLowerCase() == cat['name']!.toLowerCase();

              return Padding(
                padding: EdgeInsets.only(right: index == _categories.length - 1 ? 0 : 14),
                child: NeoPressable(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat['name']!;
                    });
                  },
                  pressDepth: 2.5,
                  builder: (context, isPressed) {
                    return Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 70),
                          curve: Curves.easeInOut,
                          width: 58,
                          height: 58,
                          transform: Matrix4.translationValues(
                            isPressed ? 2.5 : 0.0,
                            isPressed ? 2.5 : 0.0,
                            0.0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFFD400) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF101010), width: 2.0),
                            boxShadow: isPressed
                                ? const []
                                : const [
                                    BoxShadow(
                                      color: Color(0xFF101010),
                                      offset: Offset(2.5, 2.5),
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              cat['icon']!,
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat['name']!,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.0,
                            color: isSelected ? const Color(0xFF101010) : const Color(0xFF292929),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- 5. NEARBY SHOPS SECTION: EXACT same list style as CustomerHomeScreen ---
  Widget _buildNearbyShopsSection(List<ShopModel> filteredShops) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NEARBY SHOPS',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      letterSpacing: 0.0,
                      color: Color(0xFF101010),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${filteredShops.length} boutique${filteredShops.length == 1 ? '' : 's'} near $_selectedNeighborhood',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      letterSpacing: 0.0,
                      color: Color(0xFF292929),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _showFilterModal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF101010), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF101010),
                      offset: Offset(1.5, 1.5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      '≤ ${_maxDistance.toInt()} km',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101010),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF101010)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // List of Store Cards
        if (_isLoading)
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF101010), width: 1.5),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF101010),
              ),
            ),
          )
        else if (filteredShops.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF101010), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF101010),
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
            child: Row(
              children: const [
                Icon(Icons.storefront_outlined, size: 30, color: Color(0xFF888888)),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'No stores found matching this category or distance in your area.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12.5,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: filteredShops.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final shop = filteredShops[index];
              final isFavorite = _favoriteShopNames.contains(shop.name);
              return ShopCardWidget(
                shop: shop,
                isFavorite: isFavorite,
                onFavoriteTap: () {
                  setState(() {
                    if (isFavorite) {
                      _favoriteShopNames.remove(shop.name);
                    } else {
                      _favoriteShopNames.add(shop.name);
                    }
                  });
                },
              );
            },
          ),
      ],
    );
  }
}
