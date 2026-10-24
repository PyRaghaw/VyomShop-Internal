import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/shop_model.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/shop_service.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../../core/widgets/shop_card_widget.dart';
import '../../../core/widgets/vyom_arrow.dart';
import 'product_detail_screen.dart';

enum SearchTab { products, shops }

class SearchResultsScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchResultsScreen({super.key, this.initialQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _searchController;
  SearchTab _activeTab = SearchTab.products;
  final Set<String> _favoriteProductNames = {};
  final Set<String> _favoriteShopNames = {};

  // Recent searches list
  final List<String> _recentSearches = [
    'Sneakers',
    'Cotton T-Shirt',
    'Denim Jacket',
    'Sole Zone',
    'Bags',
  ];

  // Filter options
  String _selectedCategory = 'All';
  String _selectedPriceRange = 'All prices';
  String _selectedDistance = 'Within 5 km';
  double _maxDistance = 5.0;

  List<ProductModel> _apiProducts = [];
  List<ShopModel> _apiShops = [];

  void _triggerSearch(String query) async {
    try {
      final cleanQuery = query == 'All' || query == 'Popular' || query == 'Shops' ? '' : query;
      final res = await ProductService().search(
        query: cleanQuery,
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        maxDistance: _maxDistance,
      );
      if (mounted) {
        final products = res['products'] as List<ProductModel>;
        final shops = res['shops'] as List<ShopModel>;
        setState(() {
          _apiProducts = products;
          _apiShops = shops;
        });
      }
    } catch (_) {
      if (mounted) {
        if (MockData.enableMockData) {
          final q = query.toLowerCase().trim();
          setState(() {
            _apiProducts = MockData.products.where((p) =>
              q.isEmpty || p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q) || p.shopName.toLowerCase().contains(q)
            ).toList();
            _apiShops = MockData.shops.where((s) =>
              q.isEmpty || s.name.toLowerCase().contains(q) || s.category.toLowerCase().contains(q) || s.neighborhood.toLowerCase().contains(q)
            ).toList();
          });
        } else {
          setState(() {
            _apiProducts = [];
            _apiShops = [];
          });
        }
      }
    }
  }

  Map<String, dynamic> _productModelToMap(ProductModel p) {
    return {
      'id': p.id,
      'shopId': p.shopId,
      'image': p.imageUrl,
      'rating': p.rating.toStringAsFixed(1),
      'category': p.category.toUpperCase(),
      'name': p.name,
      'price': p.price.toInt().toString(),
      'originalPrice': p.mrp != null ? p.mrp!.toInt().toString() : (p.price * 1.4).toInt().toString(),
      'shopName': p.shopName,
      'distance': '${p.distanceKm} km',
      'description': p.description,
      'sizes': p.sizes,
      'colors': p.colors,
    };
  }

  Map<String, dynamic> _shopModelToMap(ShopModel s) {
    return {
      'id': s.id,
      'image': s.imageUrl,
      'category': s.category.toUpperCase(),
      'rating': s.rating.toStringAsFixed(1),
      'name': s.name,
      'distance': '${s.distanceKm} km away',
      'walkTime': '${(s.distanceKm * 12).toInt()} min walk',
      'status': s.isOpen ? 'Open now' : 'Closed',
      'closingTime': 'Closes at 10:00 PM',
      'tag': s.tag,
      'reviewsCount': s.reviewsCount,
      'address': s.address,
      'neighborhood': s.neighborhood,
      'phone': s.phone,
    };
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery == 'Shops') {
      _activeTab = SearchTab.shops;
    }
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _triggerSearch(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      if (!_recentSearches.contains(trimmed)) {
        setState(() {
          _recentSearches.insert(0, trimmed);
        });
      }
    }
    _triggerSearch(trimmed);
  }

  void _selectRecent(String query) {
    setState(() {
      _searchController.text = query;
    });
    _onSearchSubmitted(query);
  }

  void _removeRecent(String query) {
    setState(() {
      _recentSearches.remove(query);
    });
  }

  void _clearAllRecents() {
    setState(() {
      _recentSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final bool hasQuery = query.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Search Bar + Filter Button Row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  // Search Box
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF101010), width: 2.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF101010),
                            offset: Offset(2.5, 2.5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.search,
                            size: 22,
                            color: Color(0xFF101010),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: _onSearchSubmitted,
                              onChanged: (val) => setState(() {}),
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF101010),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Products, brands or shops',
                                hintStyle: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xFF939393),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (hasQuery)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.close, size: 18, color: Color(0xFF939393)),
                              ),
                            ),
                          // Right Search Action Arrow Button
                          GestureDetector(
                            onTap: () => _onSearchSubmitted(_searchController.text),
                            child: Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF101010),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: VyomArrow.forward(
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Filter Button
                  NeoPressable(
                    onTap: _showFilterModal,
                    width: 52,
                    height: 52,
                    pressDepth: 2.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF101010), width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF101010),
                          offset: Offset(2.5, 2.5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/images/filter_icon.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Content Area: Either Page 1 (Recent Searches) or Pages 2/3 (Results Frame)
            Expanded(
              child: hasQuery
                  ? _buildSearchResultsFrame(query)
                  : _buildRecentSearchesPage(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PAGE 1: RECENT SEARCHES (Exact Figma Specs)
  // ==========================================
  Widget _buildRecentSearchesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Header: RECENT SEARCHES (left) and Clear All (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'RECENT SEARCHES',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  height: 1.0,
                  letterSpacing: 0.0,
                  color: Color(0xFF101010),
                ),
              ),
              if (_recentSearches.isNotEmpty)
                GestureDetector(
                  onTap: _clearAllRecents,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1.0,
                      letterSpacing: 0.0,
                      color: Color(0xFF323232),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // List of Recent Searches
          if (_recentSearches.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Column(
                  children: const [
                    Icon(Icons.history, size: 40, color: Color(0xFF939393)),
                    SizedBox(height: 10),
                    Text(
                      'No recent searches',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color(0xFF939393),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_recentSearches.length, (index) {
              final item = _recentSearches[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    // Clock SVG Icon
                    SvgPicture.asset(
                      'assets/images/recent_icon.svg',
                      width: 22,
                      height: 22,
                    ),
                    const SizedBox(width: 14),

                    // Query Text
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _selectRecent(item),
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.0,
                            letterSpacing: 0.0,
                            color: Color(0xFF323232),
                          ),
                        ),
                      ),
                    ),

                    // Cross / Remove Icon
                    GestureDetector(
                      onTap: () => _removeRecent(item),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Color(0xFF323232),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ==========================================
  // PAGES 2 & 3: SEARCH RESULTS FRAME
  // ==========================================
  Widget _buildSearchResultsFrame(String query) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle Tabs: [ Products ] vs [ Shops ]
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              // Products Tab
              Expanded(
                child: NeoPressable(
                  onTap: () => setState(() => _activeTab = SearchTab.products),
                  height: 42,
                  pressDepth: 2.0,
                  decoration: BoxDecoration(
                    color: _activeTab == SearchTab.products
                        ? const Color(0xFFFFD400)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF101010), width: 1.8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Products',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF101010),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Shops Tab
              Expanded(
                child: NeoPressable(
                  onTap: () => setState(() => _activeTab = SearchTab.shops),
                  height: 42,
                  pressDepth: 2.0,
                  decoration: BoxDecoration(
                    color: _activeTab == SearchTab.shops
                        ? const Color(0xFFFFD400)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF101010), width: 1.8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Shops',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF101010),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Result Content: Products Grid (Page 3) or Shops List (Page 2)
        Expanded(
          child: _activeTab == SearchTab.products
              ? _buildProductsView(query)
              : _buildShopsView(query),
        ),
      ],
    );
  }

  // --- Products Grid View (Exact match with Customer Home Screen) ---
  Widget _buildProductsView(String query) {
    final q = query.toLowerCase().trim();
    final List<ProductModel> sourceList =
        _apiProducts.isNotEmpty ? _apiProducts : ProductService().cachedProducts;

    final filtered = sourceList.where((p) {
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.shopName.toLowerCase().contains(q);
      final matchesCategory = _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesDist = p.distanceKm <= _maxDistance;
      return matchesQuery && matchesCategory && matchesDist;
    }).toList();

    final products = filtered.map((p) => _productModelToMap(p)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title: MATCHING PRODUCTS
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'MATCHING PRODUCTS',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF101010),
            ),
          ),
        ),

        Expanded(
          child: products.isEmpty
              ? _buildEmptyState('No products matching "$query"')
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.71,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return _buildProductCard(p);
                  },
                ),
        ),
      ],
    );
  }

  // --- Product Card (EXACTLY same as Customer Home Screen _buildProductCard) ---
  Widget _buildProductCard(Map<String, dynamic> product) {
    final isFavorite = _favoriteProductNames.contains(product['name']);
    final cleanPrice = double.tryParse(product['price'].toString().replaceAll(',', '')) ?? 549.0;
    final cleanMrp = double.tryParse(product['originalPrice'].toString().replaceAll(',', '')) ?? 849.0;
    final cleanRating = double.tryParse(product['rating'].toString()) ?? 4.5;
    final cleanDistance = double.tryParse(product['distance'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 1.2;

    final productModel = ProductModel(
      id: product['id'] ?? 'prod_${product['name'].hashCode}',
      shopId: product['shopId'] ?? 'shop_01',
      shopName: product['shopName'] ?? 'Sole Zone',
      name: product['name'] ?? '',
      category: product['category'] ?? 'Lifestyle',
      price: cleanPrice,
      mrp: cleanMrp,
      rating: cleanRating,
      distanceKm: cleanDistance,
      imageUrl: product['image'] ?? '',
      description: product['description'] ??
          'Curated boutique lifestyle piece available in-store at ${product['shopName']}. Drop by today to try it on in person!',
      sizes: (product['sizes'] as List<String>?) ?? const ['UK 7', 'UK 8', 'UK 9', 'UK 10'],
      colors: (product['colors'] as List<String>?) ?? const ['Default'],
    );

    return NeoPressable(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: productModel),
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
                  _buildImage(product['image'] ?? ''),
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
                            product['rating'] ?? '4.5',
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
                          final name = product['name'] as String;
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
                          product['category'] ?? '',
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
                          product['name'] ?? '',
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
                              '₹${product['price']}',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101010),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                '₹${product['originalPrice']}',
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
                                  product['shopName'] ?? '',
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
                              product['distance'] ?? '',
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

  // --- Shops List View (Exact match with Customer Home Screen) ---
  Widget _buildShopsView(String query) {
    final q = query.toLowerCase().trim();
    final List<ShopModel> sourceList =
        _apiShops.isNotEmpty ? _apiShops : ShopService().cachedShops;

    final filtered = sourceList.where((s) {
      final matchesQuery = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q) ||
          s.neighborhood.toLowerCase().contains(q);
      final matchesDist = s.distanceKm <= _maxDistance;
      return matchesQuery && matchesDist;
    }).toList();

    final shops = filtered.map((s) => _shopModelToMap(s)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title: SHOPS MATCHING
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'SHOPS MATCHING',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF101010),
            ),
          ),
        ),

        Expanded(
          child: shops.isEmpty
              ? _buildEmptyState('No shops matching "$query"')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  itemCount: shops.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final shop = shops[index];
                    return _buildShopCard(shop);
                  },
                ),
        ),
      ],
    );
  }

  // --- Shop Card (uses unified ShopCardWidget) ---
  Widget _buildShopCard(Map<String, dynamic> shop) {
    final cleanDist = double.tryParse(shop['distance']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '1.2') ?? 1.2;
    final sampleShop = ShopModel(
      id: shop['id'] ?? 'shop_${shop['name'].hashCode}',
      name: shop['name'] ?? '',
      category: shop['category'] ?? 'Footwear',
      tag: shop['tag'] ?? 'COMMUNITY FAVOURITE',
      rating: double.tryParse(shop['rating']?.toString() ?? '4.8') ?? 4.8,
      reviewsCount: shop['reviewsCount'] ?? 124,
      distanceKm: cleanDist,
      address: shop['address'] ?? 'Salt Lake, Sector V, Kolkata',
      neighborhood: shop['neighborhood'] ?? 'Salt Lake',
      latitude: 22.5800,
      longitude: 88.4200,
      isOpen: shop['status']?.toString().toLowerCase().contains('open') ?? true,
      imageUrl: shop['image'] ?? '',
      phone: shop['phone'] ?? '+91 98765 43210',
      closingTime: shop['closingTime'] ?? '10:00 PM',
      openTime: shop['openTime'] ?? '10:00 AM',
    );

    final isFavorite = _favoriteShopNames.contains(sampleShop.name);
    return ShopCardWidget(
      shop: sampleShop,
      isFavorite: isFavorite,
      onFavoriteTap: () {
        setState(() {
          if (isFavorite) {
            _favoriteShopNames.remove(sampleShop.name);
          } else {
            _favoriteShopNames.add(sampleShop.name);
          }
        });
      },
    );
  }

  // --- Helper: Render Image (Asset or Network) ---
  Widget _buildImage(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.cover);
    } else if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        errorWidget: (context, urlStr, error) => Container(
          color: const Color(0xFFEEEEEE),
          child: const Center(
            child: Icon(Icons.image_not_supported, color: Color(0xFF939393)),
          ),
        ),
      );
    }
    return Container(
      color: const Color(0xFFEEEEEE),
      child: const Center(
        child: Icon(Icons.shopping_bag_outlined, color: Color(0xFF939393)),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Color(0xFF939393)),
            const SizedBox(height: 12),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101010),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching for another product or boutique brand',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: Color(0xFF939393),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Filter Modal (Strictly per Figma Specifications) ---
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String tempCategory = _selectedCategory;
        String tempPrice = _selectedPriceRange;
        String tempDistance = _selectedDistance;

        final categories = [
          {'name': 'Clothing', 'icon': 'assets/images/clothing_icon.svg'},
          {'name': 'Footwear', 'icon': 'assets/images/footwear_icon.svg'},
          {'name': 'Accessories', 'icon': 'assets/images/acc_icon.svg'},
          {'name': 'Jewellery', 'icon': 'assets/images/jewellery_icon.svg'},
          {'name': 'Bags', 'icon': 'assets/images/bags_icon.svg'},
          {'name': 'Sportswear', 'icon': 'assets/images/sports_icon.svg'},
          {'name': 'Innerwear', 'icon': 'assets/images/innerwear_icon.svg'},
          {'name': 'Kidswear', 'icon': 'assets/images/kids_icon.svg'},
        ];

        final priceRanges = [
          'Under ₹500',
          '₹500-₹1,000',
          '₹1,000+',
        ];

        final distanceRanges = [
          'Within 1 km',
          '1 km to 3 km',
          '3 km to 5 km',
          '5 km to 10 km',
        ];

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F3E8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: Color(0xFF101010), width: 2.5),
                  left: BorderSide(color: Color(0xFF101010), width: 2.0),
                  right: BorderSide(color: Color(0xFF101010), width: 2.0),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Top Header + Close Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'FILTERS',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  height: 1.0,
                                  letterSpacing: 0.0,
                                  color: Color(0xFF101010),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Find your perfect match',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.0,
                                  letterSpacing: 0.0,
                                  color: Color(0xFF323232),
                                ),
                              ),
                            ],
                          ),

                          // Close Button (Square with 2px border and shadow)
                          NeoPressable(
                            onTap: () => Navigator.of(ctx).pop(),
                            width: 44,
                            height: 44,
                            pressDepth: 2.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF101010), width: 2.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF101010),
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: Color(0xFF101010),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider Line
                    Container(
                      height: 1.0,
                      color: const Color(0x2E101010),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                    ),

                    // Scrollable Sections
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. CATEGORY
                            const Text(
                              'CATEGORY',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                height: 1.0,
                                letterSpacing: 0.0,
                                color: Color(0xFF101010),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 8 Category Boxes in 4x2 Grid
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: categories.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.95,
                              ),
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                final isSelected = tempCategory.toLowerCase() == cat['name']!.toLowerCase();
                                return NeoPressable(
                                  onTap: () {
                                    setModalState(() {
                                      tempCategory = cat['name']!;
                                    });
                                  },
                                  pressDepth: 2.0,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFFD400)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF101010),
                                      width: 1.6,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF000000),
                                        offset: Offset(2.0, 2.0),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        cat['icon']!,
                                        width: 28,
                                        height: 28,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFF101010),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        cat['name']!,
                                        style: const TextStyle(
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                          height: 1.19,
                                          letterSpacing: 0.0,
                                          color: Color(0xFF101010),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // 2. PRICE RANGE
                            const Text(
                              'PRICE RANGE',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                height: 1.0,
                                letterSpacing: 0.0,
                                color: Color(0xFF101010),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 3 Price Pills
                            Row(
                              children: priceRanges.map((price) {
                                final isSelected = tempPrice == price;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: NeoPressable(
                                      onTap: () {
                                        setModalState(() {
                                          tempPrice = price;
                                        });
                                      },
                                      height: 32,
                                      pressDepth: 2.0,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFFFD400)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF101010),
                                          width: 1.2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0xFF000000),
                                            offset: Offset(2.0, 2.0),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        price,
                                        style: const TextStyle(
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          height: 1.33,
                                          letterSpacing: 0.0,
                                          color: Color(0xFF000000),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 24),

                            // 3. DISTANCE
                            const Text(
                              'DISTANCE',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                height: 1.0,
                                letterSpacing: 0.0,
                                color: Color(0xFF101010),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 4 Distance Pills (2x2 Grid)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDistancePill(
                                        distanceRanges[0],
                                        tempDistance,
                                        (val) => setModalState(() => tempDistance = val),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDistancePill(
                                        distanceRanges[1],
                                        tempDistance,
                                        (val) => setModalState(() => tempDistance = val),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDistancePill(
                                        distanceRanges[2],
                                        tempDistance,
                                        (val) => setModalState(() => tempDistance = val),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDistancePill(
                                        distanceRanges[3],
                                        tempDistance,
                                        (val) => setModalState(() => tempDistance = val),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Action Button: SHOW RESULT →
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                      child: NeoPressable(
                        onTap: () {
                          setState(() {
                            _selectedCategory = tempCategory;
                            _selectedPriceRange = tempPrice;
                            _selectedDistance = tempDistance;
                            if (tempDistance == 'Within 1 km') {
                              _maxDistance = 1.0;
                            } else if (tempDistance == '1 km to 3 km') {
                              _maxDistance = 3.0;
                            } else if (tempDistance == '3 km to 5 km') {
                              _maxDistance = 5.0;
                            } else {
                              _maxDistance = 10.0;
                            }
                            if (_searchController.text.trim().isEmpty) {
                              _searchController.text = tempCategory;
                            }
                          });
                          Navigator.of(ctx).pop();
                        },
                        height: 46,
                        width: double.infinity,
                        pressDepth: 2.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD400),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF101010), width: 2.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF101010),
                              offset: Offset(2.5, 2.5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'SHOW RESULT',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                height: 1.0,
                                letterSpacing: 0.0,
                                color: Color(0xFF101010),
                              ),
                            ),
                            SizedBox(width: 8),
                            VyomArrow.forward(
                              size: 14,
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
          },
        );
      },
    );
  }

  Widget _buildDistancePill(String title, String selected, ValueChanged<String> onSelected) {
    final isSelected = title == selected;
    return NeoPressable(
      onTap: () => onSelected(title),
      height: 32,
      pressDepth: 2.0,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFD400) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF101010), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF000000),
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Color(0xFF101010),
        ),
      ),
    );
  }
}

