import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/shop_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/product_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_pill.dart';
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

  @override
  void initState() {
    super.initState();
    _shopProducts = _productService.cachedProducts
        .where((p) =>
            p.shopId == widget.shop.id ||
            p.shopName.toLowerCase() == widget.shop.name.toLowerCase())
        .toList();
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildShopBanner(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    } else if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          color: const Color(0xFFEEEEEE),
          child: const Center(
            child: Icon(Icons.storefront, size: 40, color: Color(0xFF939393)),
          ),
        ),
      );
    } else {
      return Container(
        color: const Color(0xFFEEEEEE),
        child: const Center(
          child: Icon(Icons.storefront, size: 40, color: Color(0xFF939393)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const VyomArrow.back(size: 20, color: AppColors.foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(shop.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.foreground),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop Interior Hero Banner
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius * 1.5),
                  border: Border.all(color: AppColors.foreground, width: AppTheme.borderWidth),
                  boxShadow: AppTheme.neoShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius * 1.5 - 2),
                  child: AspectRatio(
                    aspectRatio: 1.6,
                    child: _buildShopBanner(shop.imageUrl),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  NeoPill(label: shop.tag, tone: NeoPillTone.orange),
                  NeoPill(
                    label: shop.isOpen ? 'OPEN NOW • UNTIL 9 PM' : 'CLOSED',
                    tone: shop.isOpen ? NeoPillTone.green : NeoPillTone.muted,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Shop Name
              Text(
                shop.name,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 4),
              // Category & Rating
              Row(
                children: [
                  Text(
                    shop.category,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.mutedText),
                  ),
                  const SizedBox(width: 10),
                  const Text('•', style: TextStyle(color: AppColors.mutedText)),
                  const SizedBox(width: 10),
                  const Icon(Icons.star, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${shop.rating} (${shop.reviewsCount} reviews)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Address & Distance
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.foreground, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${shop.address} (${shop.distanceKm} km from you)',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      text: 'Call Shop 📞',
                      variant: NeoButtonVariant.secondary,
                      height: 46,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      text: 'Directions 📍',
                      variant: NeoButtonVariant.primary,
                      height: 46,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Shop Catalog Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Curated Finds in this Boutique',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.foreground,
                    ),
                  ),
                  Text(
                    '${_shopProducts.length} items',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mutedText),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_shopProducts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : const Text('More items arriving soon from this store.'),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.67,
                  ),
                  itemCount: _shopProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCardWidget(product: _shopProducts[index]);
                  },
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
