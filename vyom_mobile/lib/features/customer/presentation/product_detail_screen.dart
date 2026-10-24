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
                    child: ProductCardWidget(product: moreP),
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
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All 24 reviews loaded')),
              );
            },
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
