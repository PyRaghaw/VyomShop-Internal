import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/models/shop_model.dart';
import '../../../core/services/shop_service.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../../core/widgets/shop_card_widget.dart';
import '../../../core/widgets/vyom_arrow.dart';

class NearbyShopsScreen extends StatefulWidget {
  const NearbyShopsScreen({super.key});

  @override
  State<NearbyShopsScreen> createState() => _NearbyShopsScreenState();
}

class _NearbyShopsScreenState extends State<NearbyShopsScreen> {
  String _selectedNeighborhood = 'Salt Lake, Kolkata';
  String _selectedCategory = 'All';
  double _maxDistance = 5.0;
  bool _onlyOpenNow = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _neighborhoods = [
    'Salt Lake, Kolkata',
    'Park Street, Kolkata',
    'New Town, Kolkata',
    'Ballygunge, Kolkata',
    'Indiranagar, Bengaluru',
    'Koramangala, Bengaluru',
  ];

  final List<String> _categories = [
    'All',
    'Clothing',
    'Footwear',
    'Accessories',
    'Jewellery',
    'Bags',
    'Lifestyle',
  ];

  final ShopService _shopService = ShopService();
  List<ShopModel> _shops = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _shops = _shopService.cachedShops.isNotEmpty
        ? _shopService.cachedShops
        : (MockData.enableMockData ? MockData.shops : []);
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
          _shops = fetched;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (MockData.enableMockData) {
            _shops = MockData.shops;
          }
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
                  const SizedBox(height: 16),
                  // Open Now Toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF101010), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Only Open Stores',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101010),
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _onlyOpenNow,
                          activeThumbColor: const Color(0xFF101010),
                          activeTrackColor: const Color(0xFFFFD400),
                          onChanged: (val) {
                            setModalState(() => _onlyOpenNow = val);
                            setState(() => _onlyOpenNow = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  NeoPressable(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _loadShops();
                    },
                    height: 52,
                    pressDepth: 2.5,
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
      final matchesOpen = !_onlyOpenNow || shop.isOpen;
      final matchesSearch = query.isEmpty ||
          shop.name.toLowerCase().contains(query) ||
          shop.category.toLowerCase().contains(query) ||
          shop.address.toLowerCase().contains(query) ||
          shop.neighborhood.toLowerCase().contains(query);

      return matchesCategory && matchesDistance && matchesOpen && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadShops,
          color: const Color(0xFF101010),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // 1. Top Bar: Neighborhood Selector + Filter Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Row(
                    children: [
                      // Location selector box
                      Expanded(
                        child: NeoPressable(
                          onTap: _showNeighborhoodPicker,
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/images/lcn_icon.svg',
                                width: 18,
                                height: 18,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF101010),
                                  BlendMode.srcIn,
                                ),
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
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF939393),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      _selectedNeighborhood,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF101010),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const VyomArrow.down(
                                size: 16,
                                color: Color(0xFF101010),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Filter Button
                      NeoPressable(
                        onTap: _showFilterModal,
                        width: 52,
                        height: 52,
                        pressDepth: 2.0,
                        decoration: BoxDecoration(
                          color: _onlyOpenNow || _maxDistance < 5.0
                              ? const Color(0xFFFFD400)
                              : Colors.white,
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
                          child: SvgPicture.asset(
                            'assets/images/filter_icon.svg',
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF101010),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Yellow Neo-Hero Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF101010),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'NEIGHBOURHOOD BOUTIQUES',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Explore shops right around your corner.',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            color: Color(0xFF101010),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_shops.length} verified physical boutiques near $_selectedNeighborhood',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF101010),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Container(
                    height: 50,
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
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(Icons.search, size: 20, color: Color(0xFF101010)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() {}),
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101010),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search boutique by name or street...',
                              hintStyle: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF939393),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.close, size: 18, color: Color(0xFF939393)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Horizontal Category Chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 42,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _selectedCategory;
                      return NeoPressable(
                        onTap: () => setState(() => _selectedCategory = cat),
                        pressDepth: 1.5,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF101010) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF101010), width: 1.6),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF101010),
                              offset: Offset(1.5, 1.5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF101010),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 5. Active Filter Indicator Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredShops.length} ${filteredShops.length == 1 ? 'store' : 'stores'} found',
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101010),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showFilterModal,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF101010), width: 1.2),
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
                                  const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF101010)),
                                ],
                              ),
                            ),
                          ),
                          if (_onlyOpenNow) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDF4E9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF101010), width: 1.2),
                              ),
                              child: const Text(
                                'Open Now',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF376035),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 6. Shops List
              if (filteredShops.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(32),
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isLoading) ...[
                            const CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Color(0xFF101010),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Finding Boutiques...',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101010),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Scanning nearby verified local stores.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                color: Color(0xFF939393),
                              ),
                            ),
                          ] else ...[
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD400),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF101010), width: 2),
                              ),
                              child: const Center(
                                child: Icon(Icons.storefront_outlined, size: 30, color: Color(0xFF101010)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Boutiques Found',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101010),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Try expanding the distance or clearing your search filters.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                color: Color(0xFF939393),
                              ),
                            ),
                            const SizedBox(height: 20),
                            NeoPressable(
                              onTap: () {
                              setState(() {
                                _selectedCategory = 'All';
                                _maxDistance = 10.0;
                                _onlyOpenNow = false;
                                _searchController.clear();
                              });
                            },
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            pressDepth: 1.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD400),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF101010), width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF101010),
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Reset Filters',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101010),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final shop = filteredShops[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ShopCardWidget(shop: shop),
                        );
                      },
                      childCount: filteredShops.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }
}
