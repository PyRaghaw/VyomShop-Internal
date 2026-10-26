import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'ai_search_scan_screen.dart';
import 'search_results_screen.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/shop_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/customer_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/shop_service.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../../core/widgets/product_card_widget.dart';
import '../../../core/widgets/shop_card_widget.dart';
import '../../../core/widgets/vyom_arrow.dart';
import 'interactive_map_picker_sheet.dart';

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

  List<ProductModel> _allProducts = [];
  List<ShopModel> _allShops = [];
  List<ProductModel> _popularProducts = [];
  List<ShopModel> _nearbyShops = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _selectedNeighborhood = CustomerService().neighborhood;
    _favoriteProductNames.addAll(CustomerService().likedProductNames);
    // Pre-populate with rich mock data so the app displays immediately
    _allProducts = MockData.products;
    _allShops = MockData.shops;
    _applyLocationFilter();
    _initLiveLocation();
    _loadData();
  }

  /// Automatically requests and checks device GPS location on launch
  Future<void> _initLiveLocation() async {
    try {
      final pos = await LocationService().determinePosition(requestIfNeeded: true);
      if (pos != null && mounted) {
        final nearest = LocationService().findNearestNeighborhood(pos.latitude, pos.longitude);
        setState(() {
          _selectedNeighborhood = nearest.fullName;
        });
        CustomerService().neighborhood = nearest.fullName;
        _applyLocationFilter(userPosition: pos);
      }
    } catch (_) {}
  }

  /// Dynamically filters and recalculates shop distance for current location
  void _applyLocationFilter({Position? userPosition}) {
    final pos = userPosition ?? LocationService().currentPosition;
    final rankedShops = LocationService().filterAndRankShops(
      _allShops.isNotEmpty ? _allShops : MockData.shops,
      _selectedNeighborhood,
      userPosition: pos,
    );
    final rankedProducts = LocationService().filterAndRankProducts(
      _allProducts.isNotEmpty ? _allProducts : MockData.products,
      rankedShops,
    );
    if (mounted) {
      setState(() {
        _nearbyShops = rankedShops;
        _popularProducts = rankedProducts;
        _isLoadingData = false;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      final products = await ProductService().getProducts();
      final shops = await ShopService().getNearbyShops();
      if (mounted) {
        _allProducts = products.isNotEmpty ? products : MockData.products;
        _allShops = shops.isNotEmpty ? shops : MockData.shops;
        _applyLocationFilter();
      }
    } catch (_) {
      if (mounted) {
        _allProducts = MockData.products;
        _allShops = MockData.shops;
        _applyLocationFilter();
      }
    }
  }



  void _showNeighborhoodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SHOPPING NEAR',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF939393),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Select Neighborhood',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101010),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close, color: Color(0xFF101010)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // "USE LIVE GPS LOCATION" Button
              NeoPressable(
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final pos = await LocationService().determinePosition(requestIfNeeded: true);
                  if (pos != null && mounted) {
                    final nearest = LocationService().findNearestNeighborhood(pos.latitude, pos.longitude);
                    setState(() {
                      _selectedNeighborhood = nearest.fullName;
                    });
                    CustomerService().neighborhood = nearest.fullName;
                    _applyLocationFilter(userPosition: pos);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Live location updated: ${nearest.fullName}',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: const Color(0xFF101010),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                height: 54,
                pressDepth: 1.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD400),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF101010), width: 1.6),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF101010),
                      offset: Offset(2.0, 2.5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF101010),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.my_location, size: 18, color: Color(0xFFFFD400)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'USE LIVE GPS LOCATION',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: Color(0xFF101010),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Automatically detect closest shops',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600,
                                fontSize: 10.5,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF101010)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // "CHOOSE ON MAP" Button
              NeoPressable(
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final point = await InteractiveMapPickerSheet.show(context);
                  if (point != null && mounted) {
                    final nearest = LocationService().findNearestNeighborhood(point.latitude, point.longitude);
                    setState(() {
                      _selectedNeighborhood = nearest.fullName;
                    });
                    CustomerService().neighborhood = nearest.fullName;
                    final pos = Position(
                      latitude: point.latitude,
                      longitude: point.longitude,
                      timestamp: DateTime.now(),
                      accuracy: 5.0,
                      altitude: 0,
                      altitudeAccuracy: 0,
                      heading: 0,
                      headingAccuracy: 0,
                      speed: 0,
                      speedAccuracy: 0,
                    );
                    LocationService().setCustomPosition(pos, isLive: true);
                    _applyLocationFilter(userPosition: pos);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Location pinned on Map: ${nearest.fullName}',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: const Color(0xFF101010),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                height: 54,
                pressDepth: 1.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF101010), width: 1.6),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF101010),
                      offset: Offset(2.0, 2.5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD400),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF101010), width: 1.2),
                        ),
                        child: const Icon(Icons.map_outlined, size: 18, color: Color(0xFF101010)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CHOOSE ON MAP',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: Color(0xFF101010),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Drop a pin anywhere on OpenStreetMap',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600,
                                fontSize: 10.5,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF101010)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2DDD0), thickness: 1.2),
              const SizedBox(height: 8),

              ..._neighborhoods.map((n) {
                final isSelected = n == _selectedNeighborhood;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFD400) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF101010), width: 1.2),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      size: 18,
                      color: Color(0xFF101010),
                    ),
                  ),
                  title: Text(
                    n,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: const Color(0xFF101010),
                      fontSize: 14,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF101010), size: 22)
                      : null,
                  onTap: () {
                    setState(() => _selectedNeighborhood = n);
                    CustomerService().neighborhood = n;
                    _applyLocationFilter();
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

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final notifs = CustomerService().notifications;
            final unreadCount = notifs.where((n) => !(n['isRead'] as bool)).length;

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F3E8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: Color(0xFF101010), width: 2.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF101010),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'NOTIFICATIONS',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101010),
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD400),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF101010), width: 1.2),
                              ),
                              child: Text(
                                '$unreadCount NEW',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF101010),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF101010), width: 1.5),
                          ),
                          child: const Icon(Icons.close, size: 18, color: Color(0xFF101010)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Local shop offers, alerts, and updates',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B6B65),
                        ),
                      ),
                      if (unreadCount > 0)
                        GestureDetector(
                          onTap: () {
                            setModalState(() {
                              CustomerService().markAllNotificationsRead();
                            });
                            setState(() {});
                          },
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101010),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: notifs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = notifs[index];
                        final bool isRead = item['isRead'] as bool;
                        final String type = item['type'] as String;

                        IconData icon;
                        switch (type) {
                          case 'discount':
                            icon = Icons.local_offer_outlined;
                            break;
                          case 'match':
                            icon = Icons.auto_awesome;
                            break;
                          case 'order':
                            icon = Icons.shopping_bag_outlined;
                            break;
                          default:
                            icon = Icons.storefront_outlined;
                        }

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isRead ? Colors.white : const Color(0xFFFFFDEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF101010),
                              width: isRead ? 1.4 : 1.8,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF101010),
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD400),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF101010), width: 1.2),
                                ),
                                child: Icon(icon, size: 18, color: const Color(0xFF101010)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['title'] as String,
                                            style: const TextStyle(
                                              fontFamily: 'SpaceGrotesk',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF101010),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          item['time'] as String,
                                          style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF939393),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item['message'] as String,
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF555555),
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
                          if (LocationService().isLiveGpsActive) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF101010),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'GPS',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFFD400),
                                ),
                              ),
                            ),
                          ],
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
          onTap: () => _showNotificationsModal(context),
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
                    'No products listed in this neighbourhood yet.\nReal items will appear here as local shops upload products.',
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
    return ProductCardWidget(
      product: product,
      isFavorite: _favoriteProductNames.contains(product.name),
      onFavoriteTap: () {
        CustomerService().toggleFavoriteProduct(product.name);
        setState(() {
          if (_favoriteProductNames.contains(product.name)) {
            _favoriteProductNames.remove(product.name);
          } else {
            _favoriteProductNames.add(product.name);
          }
        });
      },
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
                    'No local shops in this radius yet.\nReal shops will appear here once verified.',
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
