import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/shop_model.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../../core/widgets/shop_card_widget.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/shop_service.dart';
import 'product_detail_screen.dart';

class AiMatchingResultsScreen extends StatefulWidget {
  final String queryImageUrl;

  const AiMatchingResultsScreen({
    super.key,
    required this.queryImageUrl,
  });

  @override
  State<AiMatchingResultsScreen> createState() => _AiMatchingResultsScreenState();
}

class _AiMatchingResultsScreenState extends State<AiMatchingResultsScreen> {
  // 0: Products, 1: Shops
  int _selectedTabIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<ProductModel> _footwearProducts = [];
  List<ShopModel> _footwearShops = [];

  final Set<String> _favoriteProductIds = {};
  final Set<String> _favoriteShopIds = {};

  @override
  void initState() {
    super.initState();
    _loadFootwearMatches();
  }

  void _loadFootwearMatches() async {
    try {
      final realProducts = await ProductService().getProducts(category: 'Footwear');
      final realShops = await ShopService().getShops(category: 'Footwear');

      final productsToUse = realProducts.isNotEmpty
          ? realProducts
          : (MockData.enableMockData
              ? MockData.products.where((p) => p.category.toLowerCase().contains('footwear')).toList()
              : <ProductModel>[]);

      final shopsToUse = realShops.isNotEmpty
          ? realShops
          : (MockData.enableMockData
              ? MockData.shops.where((s) => s.category.toLowerCase().contains('footwear')).toList()
              : <ShopModel>[]);

      productsToUse.sort((a, b) {
        final scoreA = a.matchPercentage ?? 80;
        final scoreB = b.matchPercentage ?? 80;
        return scoreB.compareTo(scoreA);
      });

      if (mounted) {
        setState(() {
          _footwearProducts = productsToUse;
          _footwearShops = shopsToUse;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _footwearProducts = MockData.enableMockData
              ? MockData.products.where((p) => p.category.toLowerCase().contains('footwear')).toList()
              : [];
          _footwearShops = MockData.enableMockData
              ? MockData.shops.where((s) => s.category.toLowerCase().contains('footwear')).toList()
              : [];
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> get _displayedProducts {
    if (_searchQuery.trim().isEmpty) return _footwearProducts;
    final q = _searchQuery.toLowerCase();
    return _footwearProducts.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.shopName.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();
  }

  List<ShopModel> get _displayedShops {
    if (_searchQuery.trim().isEmpty) return _footwearShops;
    final q = _searchQuery.toLowerCase();
    return _footwearShops.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.address.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q);
    }).toList();
  }

  Widget _buildQueryThumbnail(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: 66,
        height: 66,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => _buildFallbackThumbnail(),
      );
    } else if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: 66,
        height: 66,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail(),
      );
    } else if (url.isNotEmpty && File(url).existsSync()) {
      return Image.file(
        File(url),
        width: 66,
        height: 66,
        fit: BoxFit.cover,
      );
    } else {
      return _buildFallbackThumbnail();
    }
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      width: 66,
      height: 66,
      color: const Color(0xFFFFD400),
      child: const Icon(Icons.camera_alt, size: 28, color: Color(0xFF101010)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _displayedProducts;
    final shops = _displayedShops;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  NeoPressable(
                    onTap: () => Navigator.of(context).pop(),
                    width: 44,
                    height: 44,
                    pressDepth: 1.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF101010), width: 1.4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF101010),
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Color(0xFF101010),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MATCHING RESULTS',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: -0.2,
                          color: Color(0xFF101010),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Found based on your photo.',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visual Matches Banner Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF101010), width: 1.4),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF101010),
                            offset: Offset(2.5, 2.5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _buildQueryThumbnail(widget.queryImageUrl),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Visual Matches',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: Color(0xFF101010),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Found ${products.length} matches in ${shops.length} local shops',
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Based on the photo you scanned',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF9E9E9E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // CHANGE > button
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'CHANGE',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                      color: Color(0xFF101010),
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: Color(0xFF101010),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Search & Filter Row
                    Row(
                      children: [
                        // Search bar
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF101010), width: 1.4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF101010),
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.search, size: 20, color: Color(0xFF101010)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (val) {
                                      setState(() {
                                        _searchQuery = val;
                                      });
                                    },
                                    style: const TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF101010),
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Products, brands or shops',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF9E9E9E),
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.only(right: 6),
                                      child: Icon(Icons.close, size: 18, color: Color(0xFF888888)),
                                    ),
                                  ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF101010),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Filter button
                        NeoPressable(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Filters: Footwear only (AI Visual match)'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          width: 46,
                          height: 46,
                          pressDepth: 1.5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF101010), width: 1.4),
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
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Products vs Shops Toggle Pills
                    Row(
                      children: [
                        // Products Tab
                        Expanded(
                          child: NeoPressable(
                            onTap: () => setState(() => _selectedTabIndex = 0),
                            height: 44,
                            pressDepth: 1.5,
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 0
                                  ? const Color(0xFFFFD400)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF101010), width: 1.4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF101010),
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Products',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: Color(0xFF101010),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Shops Tab
                        Expanded(
                          child: NeoPressable(
                            onTap: () => setState(() => _selectedTabIndex = 1),
                            height: 44,
                            pressDepth: 1.5,
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 1
                                  ? const Color(0xFFFFD400)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF101010), width: 1.4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF101010),
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Shops',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: Color(0xFF101010),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section Heading: PRODUCTS FOUND vs SHOPS FOUND
                    Text(
                      _selectedTabIndex == 0 ? 'PRODUCTS FOUND' : 'SHOPS FOUND',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.2,
                        color: Color(0xFF101010),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Content View: Products Grid or Shops List
                    if (_selectedTabIndex == 0)
                      _buildProductsSection(products)
                    else
                      _buildShopsSection(shops),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Products Section ---

  Widget _buildProductsSection(List<ProductModel> products) {
    if (products.isEmpty) {
      return _buildEmptyState(
        title: 'NO MATCHING PRODUCTS FOUND',
        message: _searchQuery.isNotEmpty
            ? 'No footwear styles match "$_searchQuery". Try checking your spelling or clear the search.'
            : 'No matching footwear products found nearby. Try scanning from another angle.',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.64,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        final isFav = _favoriteProductIds.contains(product.id);

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF101010), width: 1.4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF101010),
                  offset: Offset(2.0, 2.5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with Match Badge & Heart Icon
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14.5)),
                  child: AspectRatio(
                    aspectRatio: 1.15,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFFF0EFEA),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFFFD400),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFFF0EFEA),
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                        ),

                        // Match % Badge at top-left
                        if (product.matchPercentage != null)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD400),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF101010), width: 1.2),
                              ),
                              child: Text(
                                '${product.matchPercentage}% Match',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF101010),
                                ),
                              ),
                            ),
                          ),

                        // Favorite Heart Icon at top-right
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isFav) {
                                  _favoriteProductIds.remove(product.id);
                                } else {
                                  _favoriteProductIds.add(product.id);
                                }
                              });
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF101010), width: 1.2),
                              ),
                              child: Center(
                                child: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  size: 15,
                                  color: isFav ? Colors.red : const Color(0xFF101010),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Details
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.category.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF888888),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101010),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹${product.price.toInt()}',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF101010),
                            ),
                          ),
                          if (product.mrp != null) ...[
                            const SizedBox(width: 5),
                            Text(
                              '₹${product.mrp!.toInt()}',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9E9E9E),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/dstns_icon.svg',
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.shopName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            'assets/images/direction.svg',
                            width: 12,
                            height: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${product.distanceKm} km',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF555555),
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
        );
      },
    );
  }

  // --- Shops Section ---

  Widget _buildShopsSection(List<ShopModel> shops) {
    if (shops.isEmpty) {
      return _buildEmptyState(
        title: 'NO SHOPS FOUND',
        message: _searchQuery.isNotEmpty
            ? 'No local shops match "$_searchQuery". Try clearing your search.'
            : 'No nearby shops found for this category.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shops.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final shop = shops[index];
        final isFav = _favoriteShopIds.contains(shop.id);

        return ShopCardWidget(
          shop: shop,
          isFavorite: isFav,
          onFavoriteTap: () {
            setState(() {
              if (isFav) {
                _favoriteShopIds.remove(shop.id);
              } else {
                _favoriteShopIds.add(shop.id);
              }
            });
          },
        );
      },
    );
  }

  // --- Empty State ---

  Widget _buildEmptyState({required String title, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF101010), width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF101010),
            offset: Offset(2.5, 2.5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD400),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF101010), width: 1.4),
            ),
            child: const Center(
              child: Icon(
                Icons.search_off_rounded,
                size: 30,
                color: Color(0xFF101010),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w900,
              fontSize: 15,
              letterSpacing: 0.3,
              color: Color(0xFF101010),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF777777),
              height: 1.4,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            NeoPressable(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              pressDepth: 1.5,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD400),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF101010), width: 1.2),
              ),
              child: const Center(
                child: Text(
                  'Reset Search',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101010),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
