import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'ai_search_scan_screen.dart';
import 'search_results_screen.dart';
import 'product_detail_screen.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/shop_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/shop_service.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../../core/widgets/shop_card_widget.dart';
import '../../../core/widgets/vyom_arrow.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String _selectedNeighborhood = 'Salt Lake, Kolkata';
  final _searchController = TextEditingController();
  final Set<String> _favoriteProductNames = {};
  final Set<String> _favoriteShopNames = {};

  final List<String> _neighborhoods = [
    'Salt Lake, Kolkata',
    'Park Street, Kolkata',
    'New Town, Kolkata',
    'Ballygunge, Kolkata',
    'Indiranagar, Bengaluru',
    'Koramangala, Bengaluru',
  ];

  final List<Map<String, String>> _categories = [
    {'name': 'Clothing', 'icon': 'assets/images/clothing_icon.svg'},
    {'name': 'Footwear', 'icon': 'assets/images/footwear_icon.svg'},
    {'name': 'Accessories', 'icon': 'assets/images/acc_icon.svg'},
    {'name': 'Jewellery', 'icon': 'assets/images/jewellery_icon.svg'},
    {'name': 'Bags', 'icon': 'assets/images/bags_icon.svg'},
    {'name': 'Sportswear', 'icon': 'assets/images/sports_icon.svg'},
    {'name': 'Innerwear', 'icon': 'assets/images/innerwear_icon.svg'},
    {'name': 'Kidswear', 'icon': 'assets/images/kids_icon.svg'},
  ];

  List<ProductModel> _popularProducts = [];
  List<ShopModel> _nearbyShops = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final products = await ProductService().getProducts();
      final shops = await ShopService().getNearbyShops();
      if (mounted) {
        setState(() {
          _popularProducts = products;
          _nearbyShops = shops;
          _isLoadingData = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _popularProducts = MockData.products;
          _nearbyShops = MockData.shops;
          _isLoadingData = false;
        });
      }
    }
  }

  Widget _buildSmartImage(String path, {BoxFit fit = BoxFit.cover, double? width, double? height}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFF7F3E8),
          child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF888888)),
        ),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFF7F3E8),
          child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF888888)),
        ),
      );
    } else if (path.isNotEmpty && File(path).existsSync()) {
      return Image.file(
        File(path),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFF7F3E8),
          child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF888888)),
        ),
      );
    } else {
      return Container(
        color: const Color(0xFFF7F3E8),
        child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF888888)),
      );
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
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Location Bar & Notification Button
              _buildTopBar(),
              const SizedBox(height: 14),

              // 2. Hero Yellow Banner ("VYOM SHOPS - GOOD FINDS. RIGHT NEAR YOU.")
              _buildHeroBanner(),
              const SizedBox(height: 14),

              // 3. Search Bar
              _buildSearchBar(),
              const SizedBox(height: 22),

              // 4. SHOP BY CATEGORY
              _buildShopByCategory(),
              const SizedBox(height: 24),

              // 5. POPULAR NEAR YOU
              _buildPopularNearYou(),
              const SizedBox(height: 26),

              // 6. NEARBY SHOPS
              _buildNearbyShops(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- Top Bar (Location Selector & Notification Bell) ---
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
                // Location Pin Icon
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

        // Notification Bell Button
        NeoPressable(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No new notifications right now'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
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
              'assets/images/notify_icon.svg',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  // --- Hero Banner ---
  // --- Hero Banner ---
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
            // Figma layout: width: 158; height: 148; top: 130px; left: 224px;
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
            // Figma layout: width: 75px; height: 8px; top: 146px; left: 36px;
            const Positioned(
              left: 16,
              top: 14,
              child: Text(
                'VYOM SHOPS',
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
            // Figma layout: width: 148px; height: 28px; top: 164px; left: 36px;
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
            // Figma layout: width: 203px; height: 28px; top: 198px; left: 36px;
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
            // Figma layout: width: 152px; height: 24px; top: 238px; left: 36px; radius: 4px; border: 1px #101010
            Positioned(
              left: 16,
              top: 104,
              child: NeoPressable(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AiSearchScanScreen()),
                  );
                },
                width: 152,
                height: 24,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                      Text(
                        'SCAN A PRODUCT',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          height: 1.0,
                          letterSpacing: 0.0,
                          color: Color(0xFF101010),
                        ),
                      ),
                      VyomArrow.forward(
                        size: 13,
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

  // --- Search Bar ---
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
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SearchResultsScreen(initialQuery: query.trim()),
                    ),
                  );
                }
              },
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SearchResultsScreen(
                    initialQuery: query.isEmpty ? 'All' : query,
                  ),
                ),
              );
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

  // --- SHOP BY CATEGORY ---
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
              return Padding(
                padding: EdgeInsets.only(right: index == _categories.length - 1 ? 0 : 14),
                child: NeoPressable(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SearchResultsScreen(initialQuery: cat['name']!),
                      ),
                    );
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
                            color: Colors.white,
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
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.0,
                            color: Color(0xFF292929),
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

  // --- POPULAR NEAR YOU ---
  Widget _buildPopularNearYou() {
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
                children: const [
                  Text(
                    'POPULAR NEAR YOU',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      letterSpacing: 0.0,
                      color: Color(0xFF101010),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Good finds. Just around the corner.',
                    style: TextStyle(
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
            NeoPressable(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchResultsScreen(initialQuery: 'Popular')),
                );
              },
              child: Row(
                children: const [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.0,
                      color: Color(0xFF292929),
                    ),
                  ),
                  SizedBox(width: 4),
                  VyomArrow.forward(
                    size: 14,
                    color: Color(0xFF292929),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2x2 Grid of Product Cards
        if (_isLoadingData)
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
        else if (_popularProducts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF101010), width: 1.5),
            ),
            child: Row(
              children: const [
                Icon(Icons.storefront_outlined, size: 28, color: Color(0xFF101010)),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'No products listed in this neighbourhood yet.\nReal items will appear here as local boutiques upload products.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _popularProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.71,
            ),
            itemBuilder: (context, index) {
              final p = _popularProducts[index];
              return _buildProductCard(p);
            },
          ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final isFavorite = _favoriteProductNames.contains(product.name);
    final cleanPrice = product.price.toInt();
    final cleanMrp = product.mrp?.toInt();
    final cleanRating = product.rating.toStringAsFixed(1);
    final cleanDistance = '${product.distanceKm.toStringAsFixed(1)} km';

    return NeoPressable(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Star Badge and Heart Button
            Expanded(
              flex: 61,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildSmartImage(product.imageUrl),
                  // Rating Badge (Top Left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD400),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF101010), width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF101010),
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 10, color: Color(0xFF101010)),
                          const SizedBox(width: 2.5),
                          Text(
                            cleanRating,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Color(0xFF101010),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Wishlist Heart (Top Right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: NeoPressable(
                      onTap: () {
                        setState(() {
                          final name = product.name;
                          if (isFavorite) {
                            _favoriteProductNames.remove(name);
                          } else {
                            _favoriteProductNames.add(name);
                          }
                        });
                      },
                      width: 26,
                      height: 26,
                      pressDepth: 1.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF101010), width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF101010),
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 13,
                          color: isFavorite ? const Color(0xFFFF4800) : const Color(0xFF101010),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              flex: 39,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: Color(0xFF939393),
                          ),
                        ),
                        const SizedBox(height: 1.5),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: Color(0xFF101010),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '₹$cleanPrice',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101010),
                              ),
                            ),
                            if (cleanMrp != null) ...[
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  '₹$cleanMrp',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.lineThrough,
                                    color: Color(0xFF292929),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/images/dstns_icon.svg',
                                width: 13,
                                height: 13,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  product.shopName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6E6E6E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/images/direction.svg',
                              width: 11,
                              height: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              cleanDistance,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6E6E6E),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // --- NEARBY SHOPS ---
  Widget _buildNearbyShops() {
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
                children: const [
                  Text(
                    'NEARBY SHOPS',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      letterSpacing: 0.0,
                      color: Color(0xFF101010),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your neighbourhood. Your next favourite store.',
                    style: TextStyle(
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
            NeoPressable(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchResultsScreen(initialQuery: 'Shops')),
                );
              },
              child: Row(
                children: const [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.0,
                      color: Color(0xFF292929),
                    ),
                  ),
                  SizedBox(width: 4),
                  VyomArrow.forward(
                    size: 14,
                    color: Color(0xFF292929),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // List of Store Cards
        if (_isLoadingData)
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
        else if (_nearbyShops.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF101010), width: 1.5),
            ),
            child: Row(
              children: const [
                Icon(Icons.location_on_outlined, size: 28, color: Color(0xFF101010)),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'No local boutiques in this radius yet.\nReal shops will appear here once verified.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
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
            itemCount: _nearbyShops.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final shop = _nearbyShops[index];
              return _buildShopCard(shop);
            },
          ),
      ],
    );
  }

  Widget _buildShopCard(ShopModel shop) {
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
  }
}
