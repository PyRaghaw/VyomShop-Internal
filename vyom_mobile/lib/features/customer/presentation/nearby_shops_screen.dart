import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/shop_model.dart';
import '../../../core/services/shop_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../core/widgets/neo_pill.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/shop_card_widget.dart';

class NearbyShopsScreen extends StatefulWidget {
  const NearbyShopsScreen({super.key});

  @override
  State<NearbyShopsScreen> createState() => _NearbyShopsScreenState();
}

class _NearbyShopsScreenState extends State<NearbyShopsScreen> {
  String _selectedCategory = 'All';
  double _maxDistance = 5.0;
  final List<String> _categories = ['All', 'Fashion', 'Footwear', 'Accessories', 'Lifestyle'];
  final ShopService _shopService = ShopService();

  List<ShopModel> _shops = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _shops = _shopService.cachedShops;
    _loadShops();
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredShops = _shops.where((shop) {
      final matchesCategory = _selectedCategory == 'All' ||
          shop.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchesDistance = shop.distanceKm <= _maxDistance;
      return matchesCategory && matchesDistance;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nearby Boutiques'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.foreground),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadShops,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Header Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: NeoCard(
                  backgroundColor: AppColors.softGreen,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const NeoPill(
                        text: 'YOUR NEIGHBOURHOOD, DISCOVERED',
                        tone: NeoPillTone.green,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Keep it close.\nKeep it local.',
                        style: AppTheme.headingStyle.copyWith(fontSize: 26, height: 1.1),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_shops.length} featured independent shops · within ${_maxDistance.toInt()} km',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Categories horizontal scroll
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.foreground : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.foreground, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? Colors.white : AppColors.foreground,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Shops List
            if (filteredShops.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: AppColors.primary)
                        : const Text(
                            'No boutiques found in this filter.',
                            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.mutedForeground),
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
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppColors.foreground, width: 2.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FILTER SHOPS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  const Text('Maximum Distance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Slider(
                    value: _maxDistance,
                    min: 1.0,
                    max: 15.0,
                    divisions: 14,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                    label: '${_maxDistance.toInt()} km',
                    onChanged: (val) {
                      setModalState(() => _maxDistance = val);
                      setState(() => _maxDistance = val);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('1 km', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      Text('${_maxDistance.toInt()} km', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      const Text('15 km', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  NeoButton(
                    text: 'Apply Filters',
                    variant: NeoButtonVariant.primary,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _loadShops();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
