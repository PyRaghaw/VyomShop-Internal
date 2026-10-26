import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/shop_model.dart';
import '../../../core/services/shop_service.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../../core/widgets/product_card_widget.dart';
import '../../../core/widgets/shop_card_widget.dart';
import 'shop_detail_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  late String _selectedSize;
  late String _selectedColor;
  late ShopModel _shop;
  List<ProductModel> _moreProducts = [];
  bool _isWishlisted = false;

  late final List<String> _sizesList;
  late final List<String> _colorsList;

  @override
  void initState() {
    super.initState();
    // Default size and color options based on product or standard clothing specs
    if (widget.product.sizes.isNotEmpty) {
      _sizesList = widget.product.sizes;
    } else {
      _sizesList = const ['S', 'M', 'L', 'XL', 'XLL'];
    }
    _selectedSize = _sizesList.contains('L') ? 'L' : _sizesList.first;

    if (widget.product.colors.isNotEmpty) {
      _colorsList = widget.product.colors;
    } else {
      _colorsList = const ['Off-White', 'Black', 'Olive'];
    }
    _selectedColor = _colorsList.contains('Olive') ? 'Olive' : _colorsList.first;

    _shop = ShopService().cachedShops.firstWhere(
      (s) => s.id == widget.product.shopId || s.name.toLowerCase() == widget.product.shopName.toLowerCase(),
      orElse: () => ShopService().cachedShops.isNotEmpty ? ShopService().cachedShops.first : (MockData.shops.isNotEmpty ? MockData.shops.first : ShopModel.empty()),
    );

    _initMoreProducts();
    _loadShop();
  }

  void _initMoreProducts() {
    final sameShop = MockData.products.where((p) =>
      p.id != widget.product.id &&
      (p.shopId == widget.product.shopId || p.shopName.toLowerCase() == widget.product.shopName.toLowerCase())
    ).toList();

    if (sameShop.length >= 2) {
      _moreProducts = sameShop.take(2).toList();
    } else {
      final others = MockData.products.where((p) => p.id != widget.product.id).toList();
      _moreProducts = [...sameShop, ...others].take(2).toList();
    }
  }

  Future<void> _loadShop() async {
    try {
      final fetched = await ShopService().getShopById(widget.product.shopId);
      if (fetched != null && mounted) {
        setState(() => _shop = fetched);
      }
    } catch (_) {}
  }

  List<String> get _galleryImages {
    final img = widget.product.imageUrl;
    return [img, img, img, img, img];
  }

  Widget _buildSmartImage(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          color: const Color(0xFFF0EBE0),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF101010)),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(width: width, height: height),
      );
    } else if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stack) => _buildPlaceholder(width: width, height: height),
      );
    } else if (url.isNotEmpty && File(url).existsSync()) {
      return Image.file(
        File(url),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stack) => _buildPlaceholder(width: width, height: height),
      );
    }
    return _buildPlaceholder(width: width, height: height);
  }

  Widget _buildPlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF0EBE0),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 36, color: Color(0xFF939393)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final shop = _shop;
    final images = _galleryImages;
    final currentImage = images.isNotEmpty ? images[_selectedImageIndex] : p.imageUrl;
    final originalPrice = p.mrp != null ? p.mrp!.toInt() : (p.price * 1.38).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Neo Back Button
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
                    child: Icon(Icons.arrow_back, size: 20, color: Color(0xFF101010)),
                  ),
                ),

                // Center Title: VYOM SHOPS
                const Text(
                  'VYOM SHOPS',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 0.5,
                    color: Color(0xFF101010),
                  ),
                ),

                // Neo Heart / Wishlist Button
                NeoPressable(
                  onTap: () {
                    setState(() {
                      _isWishlisted = !_isWishlisted;
                    });
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isWishlisted
                              ? 'Saved "${p.name}" to wishlist!'
                              : 'Removed from wishlist',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
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
                  child: Center(
                    child: Icon(
                      _isWishlisted ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: _isWishlisted ? const Color(0xFFFF4800) : const Color(0xFF101010),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Image Container with IN STOCK badge and 1/5 counter
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF101010), width: 1.4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF101010),
                    offset: Offset(2.5, 3.0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.5),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildSmartImage(currentImage, fit: BoxFit.cover),

                    // IN STOCK Badge (Top Left)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF166534), // Forest green
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'IN STOCK',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w800,
                            fontSize: 10.5,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Page count pill: e.g. 1/5 (Bottom Right)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF101010).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_selectedImageIndex + 1}/${images.length}',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. Thumbnails Row (5 items)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(images.length, (index) {
                final isSelected = index == _selectedImageIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedImageIndex = index),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF101010),
                        width: isSelected ? 2.0 : 1.4,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0xFF101010),
                                offset: Offset(1.5, 1.5),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.5),
                      child: _buildSmartImage(images[index], fit: BoxFit.cover),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),

            // 3. Category Tag & Rating Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Yellow Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD400),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF101010), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  child: Text(
                    p.category.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: Color(0xFF101010),
                    ),
                  ),
                ),

                // Star Rating & Review Count
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: Color(0xFFFFD400)),
                    const SizedBox(width: 4),
                    Text(
                      p.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF101010),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '(24 review)',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Color(0xFF6E6E6E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 4. Product Name
            Text(
              p.name,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w800,
                fontSize: 24,
                height: 1.2,
                color: Color(0xFF101010),
              ),
            ),
            const SizedBox(height: 6),

            // 5. Price Row (Discounted + Strikethrough MRP)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '₹${p.price.toInt()}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    color: Color(0xFF101010),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹$originalPrice',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Color(0xFF6E6E6E),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 6. Select Size
            const Text(
              'Select Size',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF101010),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sizesList.map((size) {
                final isSelected = size == _selectedSize;
                return NeoPressable(
                  onTap: () => setState(() => _selectedSize = size),
                  pressDepth: 1.5,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFD400) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF101010), width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(1.5, 1.5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      size,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                        color: const Color(0xFF101010),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 7. Select Color
            const Text(
              'Select Color',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF101010),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorsList.map((color) {
                final isSelected = color == _selectedColor;
                return NeoPressable(
                  onTap: () => setState(() => _selectedColor = color),
                  pressDepth: 1.5,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFD400) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF101010), width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(1.5, 1.5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      color,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                        color: const Color(0xFF101010),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // 8. ABOUT THIS PRODUCT
            const Text(
              'ABOUT THIS PRODUCT',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.3,
                color: Color(0xFF101010),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              p.description.isNotEmpty
                  ? p.description
                  : 'A comfortable 100% cotton oversized tee featuring a relaxed fit and bold back print, perfect for everyday wear and street-style looks.',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
                fontSize: 13.5,
                height: 1.5,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 14),

            // Specs table
            Container(height: 1, color: const Color(0xFFE2E2E2)),
            const SizedBox(height: 12),
            _buildSpecRow('Material', '100% Cotton'),
            const SizedBox(height: 8),
            _buildSpecRow('Pattern', 'Graphic Print'),
            const SizedBox(height: 8),
            _buildSpecRow('Fit', 'Oversized'),
            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0xFFE2E2E2)),
            const SizedBox(height: 28),

            // 9. AVAILABLE NEARBY
            const Text(
              'AVAILABLE NEARBY',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.3,
                color: Color(0xFF101010),
              ),
            ),
            const SizedBox(height: 12),
            // The unified redesigned ShopCardWidget
            ShopCardWidget(shop: shop),
            const SizedBox(height: 28),

            // 10. RATINGS & REVIEWS
            const Text(
              'RATINGS & REVIEWS',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.3,
                color: Color(0xFF101010),
              ),
            ),
            const SizedBox(height: 12),
            _buildReviewsCard(context),
            const SizedBox(height: 28),

            // 11. MORE FROM THIS SHOP
            const Text(
              'MORE FROM THIS SHOP',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.3,
                color: Color(0xFF101010),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _moreProducts.map((moreP) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: moreP == _moreProducts.first ? 10 : 0,
                      left: moreP == _moreProducts.last ? 10 : 0,
                    ),
                    child: SizedBox(
                      height: 260,
                      child: ProductCardWidget(product: moreP),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 100), // Space for bottom fixed action bar
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFF101010), width: 1.4),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF101010).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // In-store price
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IN STORE PRICE',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF939393),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '₹${p.price.toInt()}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF101010),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),

              // Yellow VISIT STORE → Button
              Expanded(
                child: NeoPressable(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ShopDetailScreen(shop: shop),
                      ),
                    );
                  },
                  height: 50,
                  pressDepth: 2.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD400),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF101010), width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(2.0, 2.5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'VISIT STORE',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 0.5,
                            color: Color(0xFF101010),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 16, color: Color(0xFF101010)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6E6E6E),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF101010),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF101010), width: 1.4),
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
          // Top Summary Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Rating number + stars + review count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '4.5',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w900,
                      fontSize: 36,
                      height: 1.1,
                      color: Color(0xFF101010),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (i) => const Icon(Icons.star, size: 14, color: Color(0xFFFFD400)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '24 review',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      fontSize: 11.5,
                      color: Color(0xFF6E6E6E),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Vertical subtle separator
              Container(
                width: 1,
                height: 70,
                color: const Color(0xFFE5E5E5),
              ),

              const SizedBox(width: 16),

              // Right: Rating progress bars (5 down to 1)
              Expanded(
                child: Column(
                  children: [
                    _buildStarProgressRow('5', 0.80),
                    const SizedBox(height: 3.5),
                    _buildStarProgressRow('4', 0.70),
                    const SizedBox(height: 3.5),
                    _buildStarProgressRow('3', 0.20),
                    const SizedBox(height: 3.5),
                    _buildStarProgressRow('2', 0.15),
                    const SizedBox(height: 3.5),
                    _buildStarProgressRow('1', 0.35),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFE5E5E5)),
          const SizedBox(height: 14),

          // User Review Sample
          Row(
            children: [
              // Avatar
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD400),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF101010), width: 1.0),
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF101010),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Name & verification
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aarav Sharma',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF101010),
                      ),
                    ),
                    Text(
                      'Verified purchase (2 days ago)',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        fontSize: 10.5,
                        color: Color(0xFF939393),
                      ),
                    ),
                  ],
                ),
              ),

              // 5 Stars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => const Icon(Icons.star, size: 12, color: Color(0xFFFFD400)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Review Comment Text
          const Text(
            '"Really good quality and a relaxed fit. The print looks great in person and the fabric feels soft."',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              height: 1.45,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 14),

          // View all 24 reviews Button
          NeoPressable(
            onTap: () => _showAllReviewsModal(context),
            height: 38,
            pressDepth: 1.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFEA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF101010), width: 1.4),
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View all 24 reviews',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF101010),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 14, color: Color(0xFF101010)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllReviewsModal(BuildContext context) {
    final List<Map<String, dynamic>> allReviews = [
      {
        'name': 'Priya Sengupta',
        'initials': 'PS',
        'rating': 5,
        'time': '2 days ago',
        'comment': 'The fabric is exceptionally breathable and premium. Color looks exactly like the photo in person.',
      },
      {
        'name': 'Rahul Banerjee',
        'initials': 'RB',
        'rating': 5,
        'time': '3 days ago',
        'comment': 'Bought this from the local shop after seeing it on Vyom. Fit is perfect and stitching is rock solid.',
      },
      {
        'name': 'Ananya Roy',
        'initials': 'AR',
        'rating': 4,
        'time': '5 days ago',
        'comment': 'Very nice quality and relaxed fit. Store owner was very courteous when I visited for sizing.',
      },
      {
        'name': 'Vikram Malhotra',
        'initials': 'VM',
        'rating': 5,
        'time': '1 week ago',
        'comment': 'Super comfortable everyday wear. Definitely recommended for anyone looking for authentic local craftsmanship.',
      },
      {
        'name': 'Sneha Das',
        'initials': 'SD',
        'rating': 5,
        'time': '1 week ago',
        'comment': 'Loved the pattern and texture! Tried it in-store before picking it up. Fast and convenient.',
      },
      {
        'name': 'Amitav Ghosh',
        'initials': 'AG',
        'rating': 4,
        'time': '1 week ago',
        'comment': 'Solid build and comfortable feel. Good value for money compared to mall stores.',
      },
      {
        'name': 'Rhea Kapoor',
        'initials': 'RK',
        'rating': 5,
        'time': '2 weeks ago',
        'comment': 'In-store trial was great. It fits true to size and looks even better in natural light.',
      },
      {
        'name': 'Debashis Paul',
        'initials': 'DP',
        'rating': 5,
        'time': '2 weeks ago',
        'comment': 'Authentic fabric and very clean stitching. Friendly shop staff and quick billing.',
      },
      {
        'name': 'Tanvi Sen',
        'initials': 'TS',
        'rating': 4,
        'time': '2 weeks ago',
        'comment': 'Looks very classy. Great packaging and instant pickup option was super convenient.',
      },
      {
        'name': 'Rohan Mehta',
        'initials': 'RM',
        'rating': 5,
        'time': '3 weeks ago',
        'comment': 'Got it on discount through Vyom. Quality exceeds expectations!',
      },
      {
        'name': 'Ipsita Chatterjee',
        'initials': 'IC',
        'rating': 5,
        'time': '3 weeks ago',
        'comment': 'Material is lightweight and breathable. Perfect for daily summer wear.',
      },
      {
        'name': 'Subhashree Nandi',
        'initials': 'SN',
        'rating': 4,
        'time': '3 weeks ago',
        'comment': 'Good color retention after washing. Will buy more from this store.',
      },
      {
        'name': 'Arjun Varma',
        'initials': 'AV',
        'rating': 5,
        'time': '1 month ago',
        'comment': 'Excellent quality and comfortable cushioning. Premium overall finish.',
      },
      {
        'name': 'Meera Joshi',
        'initials': 'MJ',
        'rating': 5,
        'time': '1 month ago',
        'comment': 'The aesthetic matches the photo 100%. Highly satisfied with the purchase.',
      },
      {
        'name': 'Siddharth Roy',
        'initials': 'SR',
        'rating': 4,
        'time': '1 month ago',
        'comment': 'Very responsive shop owner. Handled replacement sizing within 10 minutes.',
      },
      {
        'name': 'Pooja Bose',
        'initials': 'PB',
        'rating': 5,
        'time': '1 month ago',
        'comment': 'Love the stitching details! Supporting local shops made super easy with this app.',
      },
      {
        'name': 'Kunal Mukherjee',
        'initials': 'KM',
        'rating': 5,
        'time': '1 month ago',
        'comment': 'Five stars! The best fit I have found in this neighborhood.',
      },
      {
        'name': 'Ritika Sharma',
        'initials': 'RS',
        'rating': 4,
        'time': '2 months ago',
        'comment': 'Nice cotton blend. Very comfortable even during hot and humid days.',
      },
      {
        'name': 'Naveen Chawla',
        'initials': 'NC',
        'rating': 5,
        'time': '2 months ago',
        'comment': 'Found it using the AI visual search scanner, worked like magic in seconds.',
      },
      {
        'name': 'Soma Bhattacharya',
        'initials': 'SB',
        'rating': 5,
        'time': '2 months ago',
        'comment': 'Very happy with the prompt reservation and trial in the shop.',
      },
      {
        'name': 'Deepak Singhania',
        'initials': 'DS',
        'rating': 4,
        'time': '2 months ago',
        'comment': 'Great design and modern silhouette. Worth every rupee.',
      },
      {
        'name': 'Trisha Guha',
        'initials': 'TG',
        'rating': 5,
        'time': '2 months ago',
        'comment': 'Top tier fabric. Definitely a repeat customer now.',
      },
      {
        'name': 'Alok Verma',
        'initials': 'AV',
        'rating': 5,
        'time': '3 months ago',
        'comment': 'Very happy to support local neighborhood stores through Vyom.',
      },
      {
        'name': 'Sunita Ganguly',
        'initials': 'SG',
        'rating': 5,
        'time': '3 months ago',
        'comment': 'Smooth checkout and very polite store owner. Highly recommend!',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF7F3E8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: Color(0xFF101010), width: 2.5),
                ),
              ),
              child: Column(
                children: [
                  // Drag Handle & Top Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                    child: Column(
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
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'VERIFIED BUYER FEEDBACK',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF939393),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'All 24 Customer Reviews',
                                  style: const TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF101010),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(ctx).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(5),
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
                        const SizedBox(height: 12),
                        // Overall Rating Summary Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF101010), width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF101010),
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD400),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF101010), width: 1.4),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.star, size: 14, color: Color(0xFF101010)),
                                    SizedBox(width: 4),
                                    Text(
                                      '4.8',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF101010),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  '96% of buyers recommend this product based on in-store trial and fit.',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(height: 1.4, color: const Color(0xFF101010)),

                  // Scrollable Reviews List
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      itemCount: allReviews.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                      itemBuilder: (ctx, index) {
                        final rev = allReviews[index];
                        final int stars = rev['rating'] as int;

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF101010), width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF101010),
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // User Avatar with Initials
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD400),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF101010), width: 1.3),
                                    ),
                                    child: Center(
                                      child: Text(
                                        rev['initials'] as String,
                                        style: const TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF101010),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              rev['name'] as String,
                                              style: const TextStyle(
                                                fontFamily: 'Manrope',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF101010),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEDF4E9),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: const Color(0xFF376035), width: 1.0),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.check_circle, size: 9, color: Color(0xFF376035)),
                                                  SizedBox(width: 2.5),
                                                  Text(
                                                    'VERIFIED',
                                                    style: TextStyle(
                                                      fontFamily: 'Manrope',
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.w800,
                                                      color: Color(0xFF376035),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Row(
                                              children: List.generate(
                                                5,
                                                (s) => Icon(
                                                  Icons.star,
                                                  size: 11,
                                                  color: s < stars ? const Color(0xFFFFD400) : const Color(0xFFD6D6D6),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              rev['time'] as String,
                                              style: const TextStyle(
                                                fontFamily: 'Manrope',
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF939393),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '"${rev['comment']}"',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                  color: Color(0xFF2B2B2B),
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

  Widget _buildStarProgressRow(String starNumber, double progress) {
    return Row(
      children: [
        Text(
          starNumber,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: Color(0xFF101010),
          ),
        ),
        const SizedBox(width: 1),
        const Icon(Icons.star, size: 10, color: Color(0xFFFFD400)),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5.5,
              backgroundColor: const Color(0xFFEBEBEB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD400)),
            ),
          ),
        ),
      ],
    );
  }
}
