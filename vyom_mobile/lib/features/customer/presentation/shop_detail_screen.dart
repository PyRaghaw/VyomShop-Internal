import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/shop_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/product_service.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../../core/widgets/product_card_widget.dart';
import '../../../core/widgets/vyom_arrow.dart';

class ShopDetailScreen extends StatefulWidget {
  final ShopModel shop;

  const ShopDetailScreen({
    super.key,
    required this.shop,
  });

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  final ProductService _productService = ProductService();
  List<ProductModel> _shopProducts = [];
  bool _isLoading = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _shopProducts = _productService.cachedProducts
        .where((p) =>
            p.shopId == widget.shop.id ||
            p.shopName.toLowerCase() == widget.shop.name.toLowerCase())
        .toList();

    if (_shopProducts.isEmpty && MockData.enableMockData) {
      _shopProducts = MockData.products
          .where((p) =>
              p.shopId == widget.shop.id ||
              p.shopName.toLowerCase() == widget.shop.name.toLowerCase())
          .toList();
    }

    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final fetched = await _productService.getProducts(shopId: widget.shop.id);
      if (mounted) {
        setState(() {
          _shopProducts = fetched;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (MockData.enableMockData) {
            _shopProducts = MockData.products
                .where((p) =>
                    p.shopId == widget.shop.id ||
                    p.shopName.toLowerCase() == widget.shop.name.toLowerCase())
                .toList();
          }
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildShopBanner(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFFF0EBE0),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF101010)),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholder());
    } else if (imageUrl.isNotEmpty && File(imageUrl).existsSync()) {
      return Image.file(File(imageUrl), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholder());
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF0EBE0),
      child: const Center(
        child: Icon(Icons.storefront_outlined, size: 48, color: Color(0xFF939393)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProducts,
          color: const Color(0xFF101010),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // 1. Custom Top Bar (Back, Title, Favorite, Share)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Row(
                    children: [
                      // Back Button
                      NeoPressable(
                        onTap: () => Navigator.of(context).pop(),
                        width: 48,
                        height: 48,
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
                        child: const Center(
                          child: VyomArrow.back(size: 20, color: Color(0xFF101010)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          shop.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101010),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Favorite Button
                      NeoPressable(
                        onTap: () => setState(() => _isFavorite = !_isFavorite),
                        width: 48,
                        height: 48,
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
                        child: Center(
                          child: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: _isFavorite ? Colors.red : const Color(0xFF101010),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Shop Hero Image Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF101010), width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF101010),
                          offset: Offset(2.5, 3.0),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildShopBanner(shop.imageUrl),
                          // Category badge on top left
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF101010), width: 1.5),
                              ),
                              child: Text(
                                shop.category.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF101010),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          // Rating badge on top right
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD400),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF101010), width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/rateing_icon.svg',
                                    width: 12,
                                    height: 12,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFF101010),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${shop.rating}',
                                    style: const TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF101010),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // 3. Shop Info Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status badge + reviews
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: shop.isOpen ? const Color(0xFFEDF4E9) : const Color(0xFFFFECEB),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: shop.isOpen ? const Color(0xFF376035) : const Color(0xFFEF4444),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/open-now_icon.svg',
                                    width: 12,
                                    height: 12,
                                    colorFilter: ColorFilter.mode(
                                      shop.isOpen ? const Color(0xFF376035) : const Color(0xFFEF4444),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    shop.isOpen
                                        ? 'OPEN NOW • UNTIL ${shop.closingTime ?? "9:30 PM"}'
                                        : 'CLOSED • OPENS AT ${shop.openTime ?? "10:00 AM"}',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: shop.isOpen ? const Color(0xFF376035) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${shop.reviewsCount} reviews',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF939393),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Shop Name
                        Text(
                          shop.name,
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Color(0xFF101010),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Address Row with distance
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/images/dstns_icon.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF101010),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${shop.address} (${shop.distanceKm} km away)',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B6B65),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Action Buttons: Call & Directions
                        Row(
                          children: [
                            // Call Button
                            Expanded(
                              child: NeoPressable(
                                onTap: () {},
                                height: 46,
                                pressDepth: 2.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF101010), width: 1.6),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF101010),
                                      offset: Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.phone_outlined, size: 16, color: Color(0xFF101010)),
                                    SizedBox(width: 6),
                                    Text(
                                      'CALL BOUTIQUE',
                                      style: TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF101010),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Directions Button (Signature Golden Yellow)
                            Expanded(
                              child: NeoPressable(
                                onTap: () {},
                                height: 46,
                                pressDepth: 2.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD400),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF101010), width: 1.6),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF101010),
                                      offset: Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/direction.svg',
                                      width: 16,
                                      height: 16,
                                      colorFilter: const ColorFilter.mode(
                                        Color(0xFF101010),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'DIRECTIONS',
                                      style: TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF101010),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 22)),

              // 4. Products Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Products from this Store',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101010),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD400),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF101010), width: 1.2),
                        ),
                        child: Text(
                          '${_shopProducts.length} items',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF101010),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // 5. Products Grid
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF101010)),
                    ),
                  ),
                )
              else if (_shopProducts.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF101010), width: 1.8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF101010),
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 36, color: Color(0xFF939393)),
                          const SizedBox(height: 10),
                          const Text(
                            'No Products Listed Yet',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF101010),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'New collections from this store will appear here once uploaded.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              color: Color(0xFF939393),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.62,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ProductCardWidget(product: _shopProducts[index]);
                      },
                      childCount: _shopProducts.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 36)),
            ],
          ),
        ),
      ),
    );
  }
}
