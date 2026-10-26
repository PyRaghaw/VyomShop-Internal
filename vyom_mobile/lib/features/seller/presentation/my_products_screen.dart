import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/shop_model.dart';
import '../../../core/services/seller_service.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../core/widgets/neo_pill.dart';
import '../../../core/widgets/neo_button.dart';
import 'add_product_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'In Stock', 'Low Stock', 'Drafts'];
  final SellerService _sellerService = SellerService();

  List<ProductModel> _products = [];
  ShopModel? _shop;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _products = _sellerService.cachedProducts;
    _shop = _sellerService.cachedShop;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _sellerService.getSellerProducts(),
        _sellerService.getSellerShop(),
      ]);
      if (mounted) {
        setState(() {
          _products = results[0] as List<ProductModel>;
          _shop = results[1] as ShopModel?;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildProductThumbnail(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          width: 72,
          height: 72,
          color: AppColors.softYellow,
          child: const Icon(Icons.image, color: AppColors.mutedForeground),
        ),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          width: 72,
          height: 72,
          color: AppColors.softYellow,
          child: const Icon(Icons.image, color: AppColors.mutedForeground),
        ),
      );
    } else {
      return Container(
        width: 72,
        height: 72,
        color: AppColors.softYellow,
        child: const Icon(Icons.image, color: AppColors.mutedForeground),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _products.where((p) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'In Stock') return p.isAvailable;
      if (_selectedFilter == 'Low Stock') return p.isAvailable;
      if (_selectedFilter == 'Drafts') return !p.isAvailable;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
            onPressed: () async {
              final added = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );
              if (added == true) _loadData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: Column(
          children: [
            // Header info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: NeoCard(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _shop?.name ?? 'My Shop',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_products.length} live products · ₹10/listing default',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    NeoButton(
                      text: '+ Add New',
                      variant: NeoButtonVariant.primary,
                      onPressed: () async {
                        final added = await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddProductScreen()),
                        );
                        if (added == true) _loadData();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (context, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.foreground : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.foreground, width: 1.8),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : AppColors.foreground,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Inventory List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: AppColors.primary)
                          : Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.mutedForeground),
                                  SizedBox(height: 12),
                                  Text(
                                    'No products in your catalog yet.',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.foreground),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Add your first item using "+ Add New" to start showcasing in local searches!',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.mutedForeground),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: filtered.length,
                      separatorBuilder: (context, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return NeoCard(
                          padding: const EdgeInsets.all(12),
                          backgroundColor: Colors.white,
                          child: Row(
                            children: [
                              // Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _buildProductThumbnail(product.imageUrl),
                              ),
                              const SizedBox(width: 14),
                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        NeoPill(
                                          text: product.isAvailable ? 'Active' : 'Draft',
                                          tone: product.isAvailable ? NeoPillTone.green : NeoPillTone.gray,
                                        ),
                                        Text(
                                          '₹${product.price.toInt()}',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product.category} · In stock',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Menu
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: AppColors.mutedForeground),
                                onSelected: (val) {
                                  if (val == 'delete') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Listing "${product.title}" archived.')),
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Edit Price & Sizes')),
                                  const PopupMenuItem(value: 'out_of_stock', child: Text('Mark Out of Stock')),
                                  const PopupMenuItem(value: 'delete', child: Text('Archive Listing')),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
