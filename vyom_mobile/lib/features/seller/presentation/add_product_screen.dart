import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/seller_service.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../core/widgets/neo_pill.dart';
import '../../../core/widgets/neo_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _sizesController = TextEditingController(text: 'S, M, L, XL');
  final _colorsController = TextEditingController(text: 'Black, White');

  String _selectedCategory = 'Clothing';
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _categories = [
    'Clothing',
    'Footwear',
    'Accessories',
    'Jewellery',
    'Bags',
    'Sportswear',
    'Innerwear',
    'Kidswear',
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (_) {}
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Product Photo',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF101010)),
                  title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF101010)),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handlePublish() async {
    final title = _titleController.text.trim();
    final priceStr = _priceController.text.trim();
    if (title.isEmpty || priceStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a product title and price')),
      );
      return;
    }

    final price = double.tryParse(priceStr) ?? 0.0;
    final mrp = double.tryParse(_mrpController.text.trim());

    setState(() => _isLoading = true);

    try {
      final res = await SellerService().createProduct({
        'name': title,
        'price': price,
        'mrp': mrp ?? (price * 1.3),
        'category': _selectedCategory,
        'sizes': _sizesController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'colors': _colorsController.text
            .split(',')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .toList(),
        'description': 'Curated boutique collection',
        'imageUrl': _selectedImage?.path ?? '',
        'images': (_selectedImage?.path != null && _selectedImage!.path.isNotEmpty)
            ? [_selectedImage!.path]
            : <String>[],
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product published! Live in neighbourhood search.'),
            backgroundColor: AppColors.foreground,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to publish product. Please check your connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _mrpController.dispose();
    _sizesController.dispose();
    _colorsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add Product', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GIVE A GOOD FIND A SPOTLIGHT',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            Text(
              'Add New Listing',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 26),
            ),
            const SizedBox(height: 6),
            const Text(
              'Upload clear photos and key details so local customers can discover your store inventory.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            // Image Upload Card
            NeoCard(
              backgroundColor: Colors.white,
              onTap: _showImagePickerSheet,
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(
                            _selectedImage!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.foreground, width: 1.5),
                              ),
                              child: const Text('Change photo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 2),
                              ),
                              child: const Icon(Icons.add_a_photo, size: 28, color: AppColors.primary),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Upload Product Photo',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap to pick from Camera or Gallery',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedText),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            // Form Fields
            NeoTextField(
              label: 'Product Title',
              hintText: 'e.g. Vintage Oversized Denim Jacket',
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            const Text(
              'CATEGORY',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.mutedText),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _categories.map((c) {
                final isSelected = c == _selectedCategory;
                return NeoPill(
                  label: c,
                  isSelected: isSelected,
                  tone: isSelected ? NeoPillTone.orange : NeoPillTone.white,
                  onTap: () => setState(() => _selectedCategory = c),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: NeoTextField(
                    label: 'Selling Price (₹)',
                    hintText: '1499',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: NeoTextField(
                    label: 'MRP / Original (₹)',
                    hintText: '1999',
                    controller: _mrpController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            NeoTextField(
              label: 'Available Sizes (comma separated)',
              hintText: 'S, M, L, XL or UK 7, 8, 9',
              controller: _sizesController,
            ),
            const SizedBox(height: 16),
            NeoTextField(
              label: 'Available Colors (comma separated)',
              hintText: 'Black, Olive Green, Stone',
              controller: _colorsController,
            ),
            const SizedBox(height: 24),
            // AI Listing Review Callout Card (from Screen 22 of Figma)
            NeoCard(
              backgroundColor: AppColors.tintGreen,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Color(0xFF16A34A), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'AI Listing Review Ready',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.foreground),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Our AI pipeline will automatically extract visual attributes (material, collar, silhouette) and generate vector embeddings for instant local customer matching.',
                    style: TextStyle(fontSize: 12, height: 1.45, fontWeight: FontWeight.w600, color: Color(0xFF2E5E2A)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Publish CTA
            NeoButton(
              text: 'Publish Listing (Deducts 1 Credit) →',
              variant: NeoButtonVariant.primary,
              width: double.infinity,
              height: 54,
              isLoading: _isLoading,
              onPressed: _handlePublish,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
