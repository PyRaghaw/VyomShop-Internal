import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/shop_service.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../../core/widgets/vyom_arrow.dart';
import 'getting_approved_screen.dart';

class ShopSetupScreen extends StatefulWidget {
  final String? initialShopName;
  final String? ownerName;
  final String? email;
  final String? phone;

  const ShopSetupScreen({
    super.key,
    this.initialShopName,
    this.ownerName,
    this.email,
    this.phone,
  });

  @override
  State<ShopSetupScreen> createState() => _ShopSetupScreenState();
}

class _ShopSetupScreenState extends State<ShopSetupScreen> {
  late final TextEditingController _shopNameController;
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Kolkata');
  final _pinCodeController = TextEditingController(text: '700064');
  final _descriptionController = TextEditingController();

  File? _shopPhoto;
  final ImagePicker _imagePicker = ImagePicker();

  String _selectedCategory = 'Clothing';
  TimeOfDay _openTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 22, minute: 0);
  bool _isSubmitting = false;

  final List<String> _categories = const [
    'Clothing',
    'Footwear',
    'Accessories',
    'Jewellery',
    'Bags',
    'Sportswear',
    'Innerwear',
    'Kidswear',
    'Electronics',
    'Home & Living',
  ];

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController(text: widget.initialShopName ?? '');
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 88,
      );
      if (picked != null) {
        setState(() {
          _shopPhoto = File(picked.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Storefront photo loaded successfully!',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF101010),
                ),
              ),
              backgroundColor: const Color(0xFFFFD400),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFF101010), width: 1.5),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not load photo: $e',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF101010),
              ),
            ),
            backgroundColor: const Color(0xFFFFD400),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFF101010), width: 1.5),
            ),
          ),
        );
      }
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F3E8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: Color(0xFF101010), width: 2.0),
              left: BorderSide(color: Color(0xFF101010), width: 2.0),
              right: BorderSide(color: Color(0xFF101010), width: 2.0),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF101010),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ADD SHOP PHOTO',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF101010),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose how you want to add your storefront photo',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 20),
              NeoPressable(
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.camera);
                },
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF101010), width: 1.4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF101010),
                      offset: Offset(2.0, 2.5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Icon(Icons.camera_alt_outlined, color: Color(0xFF101010), size: 22),
                    SizedBox(width: 14),
                    Text(
                      'Take photo with Camera',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF101010),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              NeoPressable(
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.gallery);
                },
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF101010), width: 1.4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF101010),
                      offset: Offset(2.0, 2.5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Icon(Icons.photo_library_outlined, color: Color(0xFF101010), size: 22),
                    SizedBox(width: 14),
                    Text(
                      'Choose from Gallery',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF101010),
                      ),
                    ),
                  ],
                ),
              ),
              if (_shopPhoto != null) ...[
                const SizedBox(height: 12),
                NeoPressable(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _shopPhoto = null);
                  },
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5E5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF101010), width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(2.0, 2.5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      Icon(Icons.delete_outline, color: Color(0xFFD32F2F), size: 22),
                      SizedBox(width: 14),
                      Text(
                        'Remove Photo',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectOpenTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _openTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF101010),
              onPrimary: Colors.white,
              surface: Color(0xFFF7F3E8),
              onSurface: Color(0xFF101010),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _openTime = picked);
    }
  }

  Future<void> _selectCloseTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _closeTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF101010),
              onPrimary: Colors.white,
              surface: Color(0xFFF7F3E8),
              onSurface: Color(0xFF101010),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _closeTime = picked);
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F3E8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: Color(0xFF101010), width: 2.0),
              left: BorderSide(color: Color(0xFF101010), width: 2.0),
              right: BorderSide(color: Color(0xFF101010), width: 2.0),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF101010),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'SHOP CATEGORY',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF101010),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select the primary category for your store',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == _selectedCategory;
                    return NeoPressable(
                      onTap: () {
                        setState(() => _selectedCategory = cat);
                        Navigator.pop(context);
                      },
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFD400) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF101010), width: 1.4),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF101010),
                            offset: Offset(2.0, 2.5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cat,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 14,
                                color: const Color(0xFF101010),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                size: 18,
                                color: Color(0xFF101010),
                              ),
                          ],
                        ),
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
  }

  void _onSubmit() async {
    final name = _shopNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your shop name'),
          backgroundColor: Color(0xFF101010),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    String? photoUrl;
    if (_shopPhoto != null) {
      photoUrl = _shopPhoto!.path;
    }

    final res = await ShopService().createShop({
      'name': name,
      'category': _selectedCategory,
      'address': _streetAddressController.text.trim(),
      'city': _cityController.text.trim(),
      'pinCode': _pinCodeController.text.trim(),
      'openTime': _formatTime(_openTime),
      'closeTime': _formatTime(_closeTime),
      'description': _descriptionController.text.trim(),
      'imageUrl': photoUrl ?? '',
      'ownerName': widget.ownerName ?? '',
      'email': widget.email ?? '',
      'phone': widget.phone ?? '',
    });

    final verificationId = res?['verificationId']?.toString() ??
        'VYOM-${100 + math.Random().nextInt(900)}';

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Navigate to Page 19 (Getting Approved / Verification Pending) with Dissolve 300ms
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GettingApprovedScreen(
              verificationId: verificationId,
              shopName: name,
              category: _selectedCategory,
              ownerName: widget.ownerName,
              email: widget.email,
              phone: widget.phone,
              streetAddress: _streetAddressController.text.trim(),
              city: _cityController.text.trim(),
              pinCode: _pinCodeController.text.trim(),
              openTime: _formatTime(_openTime),
              closeTime: _formatTime(_closeTime),
              description: _descriptionController.text.trim(),
              photoPath: _shopPhoto?.path,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Back Button on the Right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NeoPressable(
                    onTap: () => Navigator.of(context).pop(),
                    width: 44,
                    height: 44,
                    pressDepth: 2.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF101010), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF101010),
                          offset: Offset(2.0, 2.5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: VyomArrow.back(
                        size: 20,
                        color: Color(0xFF101010),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title: SET UP
              const Text(
                'SET UP',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 48,
                  height: 0.95,
                  letterSpacing: -0.5,
                  color: Color(0xFF101010),
                ),
              ),

              // Title: YOUR SHOP
              const Text(
                'YOUR SHOP',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 48,
                  height: 0.95,
                  letterSpacing: -0.5,
                  color: Color(0xFF101010),
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'The details that help your customer find you.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Color(0xFF323232),
                ),
              ),
              const SizedBox(height: 24),

              // Shop Photo Box (Dashed placeholder if null, actual loaded image if selected)
              _buildPhotoUploadBox(),
              const SizedBox(height: 20),

              // Shop name field
              _buildTextField(
                label: 'Shop name',
                hint: 'e.g. Urban Collective',
                controller: _shopNameController,
              ),
              const SizedBox(height: 18),

              // Shop category dropdown field
              _buildCategoryDropdown(),
              const SizedBox(height: 18),

              // Street address field
              _buildTextField(
                label: 'Street address',
                hint: 'e.g. Block B, Shop 24, Salt Lake',
                controller: _streetAddressController,
              ),
              const SizedBox(height: 18),

              // 2-Column Row 1: City & PIN code
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'City',
                      hint: 'Kolkata',
                      controller: _cityController,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField(
                      label: 'PIN code',
                      hint: '700064',
                      controller: _pinCodeController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2-Column Row 2: Open at & Closes at
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTimeField(
                      label: 'Open at',
                      timeText: _formatTime(_openTime),
                      onTap: _selectOpenTime,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTimeField(
                      label: 'Closes at',
                      timeText: _formatTime(_closeTime),
                      onTap: _selectCloseTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Shop description field
              _buildDescriptionField(),
              const SizedBox(height: 22),

              // Submit Button: SUBMIT FOR VERIFICATION →
              NeoPressable(
                onTap: _isSubmitting ? () {} : _onSubmit,
                height: 46,
                width: double.infinity,
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
                child: _isSubmitting
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF101010),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'SUBMIT FOR VERIFICATION',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              letterSpacing: 0.0,
                              color: Color(0xFF101010),
                            ),
                          ),
                          SizedBox(width: 6),
                          VyomArrow.forward(
                            size: 16,
                            color: Color(0xFF101010),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUploadBox() {
    if (_shopPhoto == null) {
      return NeoPressable(
        onTap: _showPhotoSourceSheet,
        width: double.infinity,
        height: 190,
        pressDepth: 1.5,
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: const Color(0xFF101010),
            strokeWidth: 1.12,
            radius: 8.0,
            dashWidth: 4.0,
            dashGap: 3.0,
          ),
          child: Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/dnd_icon.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Add a shop photo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 19.5 / 16,
                    letterSpacing: 0,
                    color: Color(0xFF101010),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'JPG or PNG • a clear storefront works best',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 13.5 / 14,
                    letterSpacing: 0,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Actually loaded photo preview with neo-brutalist styling
      return NeoPressable(
        onTap: _showPhotoSourceSheet,
        width: double.infinity,
        height: 190,
        pressDepth: 1.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF101010), width: 1.4),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF101010),
              offset: Offset(2.0, 2.5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                _shopPhoto!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 190,
              ),
              // Subtle gradient overlay with status
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Color(0xFFFFD400),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Storefront photo loaded • Tap to change',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Remove button at top right
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _shopPhoto = null);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF101010), width: 1.4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF101010),
                          offset: Offset(1.5, 1.5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF101010),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF323232),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF101010), width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF101010),
                offset: Offset(2.0, 2.5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF101010),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF939393),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shop category',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF323232),
          ),
        ),
        const SizedBox(height: 8),
        NeoPressable(
          onTap: _showCategoryPicker,
          height: 54,
          width: double.infinity,
          pressDepth: 1.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF101010), width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF101010),
                offset: Offset(2.0, 2.5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedCategory,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF101010),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: Color(0xFF101010),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required String timeText,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF323232),
          ),
        ),
        const SizedBox(height: 8),
        NeoPressable(
          onTap: onTap,
          height: 54,
          width: double.infinity,
          pressDepth: 1.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF101010), width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF101010),
                offset: Offset(2.0, 2.5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeText,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF101010),
                ),
              ),
              const Icon(
                Icons.access_time_outlined,
                size: 18,
                color: Color(0xFF101010),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shop description',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF323232),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 128,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF101010), width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF101010),
                offset: Offset(2.0, 2.5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _descriptionController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 1.43,
              color: Color(0xFF101010),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText:
                  'e.g. Curated lifestyle store. Quality collections, great people, right here in Salt Lake.',
              hintStyle: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.43,
                color: Color(0xFF939393),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashGap;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.12,
    this.radius = 8.0,
    this.dashWidth = 4.0,
    this.dashGap = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final halfStroke = strokeWidth / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        halfStroke,
        halfStroke,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final dashed = _dashPath(path, dashWidth, dashGap);
    canvas.drawPath(dashed, paint);
  }

  Path _dashPath(Path source, double dashWidth, double dashGap) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = math.min(dashWidth, metric.length - distance);
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        distance += dashWidth + dashGap;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}
