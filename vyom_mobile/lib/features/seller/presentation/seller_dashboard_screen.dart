import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/seller_service.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../core/widgets/neo_pill.dart';
import '../../../core/widgets/neo_button.dart';
import '../../auth/presentation/choose_role_screen.dart';
import 'add_product_screen.dart';
import 'credits_packages_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final SellerService _sellerService = SellerService();
  List<ProductModel> _myProducts = [];
  String _shopName = 'My Shop';
  int _credits = 10;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final dash = await _sellerService.getDashboard();
    final products = await _sellerService.getSellerProducts();

    if (mounted) {
      setState(() {
        if (dash != null) {
          if (dash['shop'] is Map) {
            _shopName = dash['shop']['name']?.toString() ?? _shopName;
          }
          if (dash['stats'] is Map && dash['stats']['creditsAvailable'] != null) {
            _credits = (dash['stats']['creditsAvailable'] as num).toInt();
          }
        }
        _myProducts = products;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SELLER DASHBOARD',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: AppColors.primary,
              ),
            ),
            Text(
              _shopName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.foreground,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: AppColors.foreground),
            tooltip: 'Switch to Customer',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ChooseRoleScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Credits & Wallet Banner
            NeoCard(
              backgroundColor: AppColors.tintCream,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NeoPill(
                          label: 'ACTIVE LISTING WALLET',
                          tone: NeoPillTone.orange,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_credits Credits Available',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '₹10 per product listing • Packages save up to 35%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  NeoButton(
                    text: 'Top Up +',
                    variant: NeoButtonVariant.primary,
                    height: 42,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CreditsPackagesScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Primary Action: Add Product
            NeoButton(
              text: '+ Add New Product with AI Review',
              variant: NeoButtonVariant.dark,
              width: double.infinity,
              height: 52,
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
                _loadDashboard();
              },
            ),
            const SizedBox(height: 24),
            // Metrics Overview
            const Text(
              'Your Local Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: NeoCard(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('VIEWS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.mutedText)),
                        SizedBox(height: 6),
                        Text('2,840', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.foreground)),
                        SizedBox(height: 4),
                        Text('↑ 18.4% this month', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: NeoCard(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DIRECTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.mutedText)),
                        SizedBox(height: 6),
                        Text('312', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.foreground)),
                        SizedBox(height: 4),
                        Text('Store visits routed', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.mutedText)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // My Active Products Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Active Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.foreground,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddProductScreen()),
                    );
                    _loadDashboard();
                  },
                  child: const Text('+ Add more', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_myProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No active products yet. Add your first item above!',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              )
            else
              ..._myProducts.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: NeoCard(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: p.cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.foreground, width: 1.5),
                          ),
                          child: const Icon(Icons.checkroom, color: AppColors.foreground),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('₹${p.price.toInt()} • ${p.category}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.mutedText)),
                            ],
                          ),
                        ),
                        const NeoPill(label: 'IN STOCK', tone: NeoPillTone.green),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
