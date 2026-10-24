import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_text_field.dart';
import '../../../core/services/seller_service.dart';

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hoursController = TextEditingController();
  final SellerService _sellerService = SellerService();

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  Future<void> _loadShop() async {
    final s = await _sellerService.getSellerShop();
    if (mounted && s != null) {
      setState(() {
        _nameController.text = s.name;
        _categoryController.text = s.category;
        _addressController.text = s.address;
        _phoneController.text = s.phone.replaceAll('+91', '');
        _hoursController.text = s.closingTime ?? '9:00 AM – 10:00 PM';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Boutique Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Storefront Banner
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.foreground, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.foreground, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.camera_alt, size: 14),
                        SizedBox(width: 6),
                        Text('Change Photo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Profile Form
            NeoCard(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SHOP DETAILS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 14),

                  NeoTextField(
                    label: 'Shop Name',
                    controller: _nameController,
                    hint: 'e.g. The Urban Edit',
                  ),
                  const SizedBox(height: 14),

                  NeoTextField(
                    label: 'Primary Category',
                    controller: _categoryController,
                    hint: 'e.g. Fashion • Streetwear',
                  ),
                  const SizedBox(height: 14),

                  NeoTextField(
                    label: 'Address & Locality',
                    controller: _addressController,
                    hint: 'e.g. 12th Main Road, Indiranagar',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 14),

                  NeoTextField(
                    label: 'Customer Contact Phone',
                    controller: _phoneController,
                    hint: '10-digit number',
                    keyboardType: TextInputType.phone,
                    isPhonePrefix: true,
                  ),
                  const SizedBox(height: 14),

                  NeoTextField(
                    label: 'Opening Hours',
                    controller: _hoursController,
                    hint: 'e.g. 10:30 AM – 9:00 PM',
                  ),
                  const SizedBox(height: 24),

                  NeoButton(
                    text: 'Save Boutique Profile',
                    variant: NeoButtonVariant.primary,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Shop profile updated successfully!'),
                          backgroundColor: AppColors.foreground,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
