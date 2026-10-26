import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/services/customer_service.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../../core/widgets/product_card_widget.dart';
import '../../../core/widgets/vyom_arrow.dart';
import '../../auth/presentation/choose_role_screen.dart';
import '../../auth/presentation/phone_login_screen.dart';
import '../../seller/presentation/seller_dashboard_screen.dart';
import 'ai_search_scan_screen.dart';
import 'customer_registration_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  bool _neighborhoodAlerts = true;
  bool _cameraPermission = false;
  bool _locationPermission = false;
  bool _storagePermission = false;

  final List<String> _searchHistory = [
    'Floral Kurtis',
    'Embroidered Lehenga',
    'Leather Mojaris',
    'Silk Saree',
    'Denim Jacket',
  ];

  @override
  void initState() {
    super.initState();
    CustomerService().loadProfile().then((_) {
      if (mounted) setState(() {});
    });
    _syncPermissions();
  }

  Future<void> _syncPermissions() async {
    try {
      final cam = await Permission.camera.status;
      final loc = await Permission.location.status;
      final photos = await Permission.photos.status;
      if (mounted) {
        setState(() {
          _cameraPermission = cam.isGranted;
          _locationPermission = loc.isGranted;
          _storagePermission = photos.isGranted;
        });
      }
    } catch (_) {}
  }

  Future<void> _navigateToRegister() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CustomerRegistrationScreen(isFromProfile: true),
      ),
    );
    await CustomerService().loadProfile();
    if (mounted) setState(() {});
  }

  Future<void> _navigateToLogin() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PhoneLoginScreen(isFromProfile: true),
      ),
    );
    await CustomerService().loadProfile();
    if (mounted) setState(() {});
  }

  void _showNeoSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Color(0xFF101010),
          ),
        ),
        backgroundColor: const Color(0xFFFFD400),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF101010), width: 1.5),
        ),
      ),
    );
  }

  void _showSearchHistoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F3E8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: Color(0xFF101010), width: 2.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SEARCH HISTORY',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101010),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
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
                  const SizedBox(height: 4),
                  const Text(
                    'Recent shop queries and visual lookups',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B6B65),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_searchHistory.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: const Column(
                        children: [
                          Icon(Icons.history_toggle_off, size: 36, color: Color(0xFF939393)),
                          SizedBox(height: 8),
                          Text(
                            'No recent searches found',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B6B65),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _searchHistory.map((item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF101010), width: 1.4),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF101010),
                                offset: Offset(1.5, 1.5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search, size: 14, color: Color(0xFF101010)),
                              const SizedBox(width: 6),
                              Text(
                                item,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101010),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    _searchHistory.remove(item);
                                  });
                                  setState(() {});
                                },
                                child: const Icon(Icons.close, size: 14, color: Color(0xFF939393)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    NeoPressable(
                      onTap: () {
                        setModalState(() {
                          _searchHistory.clear();
                        });
                        setState(() {});
                        _showNeoSnackBar('Search history cleared!');
                      },
                      height: 46,
                      width: double.infinity,
                      pressDepth: 1.5,
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
                      child: const Center(
                        child: Text(
                          'CLEAR ALL HISTORY',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSavedProductsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final savedNames = CustomerService().likedProductNames;
            final allProducts = MockData.products;
            final savedProducts = allProducts.where((p) => savedNames.contains(p.name)).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F3E8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: Color(0xFF101010), width: 2.5),
                ),
              ),
              child: Column(
                children: [
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
                                  'YOUR WISHLIST & LIKES',
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
                                  'Saved Products (${savedProducts.length})',
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
                      ],
                    ),
                  ),
                  Container(height: 1.4, color: const Color(0xFF101010)),
                  Expanded(
                    child: savedProducts.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF101010), width: 1.8),
                                    ),
                                    child: const Icon(Icons.favorite_border, size: 36, color: Color(0xFF939393)),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'No Saved Products Yet',
                                    style: TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF101010),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Browse local shops and tap the heart icon on any piece to save it for quick lookup or in-store trial.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF6E6E6E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.71,
                            ),
                            itemCount: savedProducts.length,
                            itemBuilder: (context, index) {
                              final product = savedProducts[index];
                              return ProductCardWidget(
                                product: product,
                                isFavorite: true,
                                onFavoriteTap: () {
                                  CustomerService().removeLikedProduct(product.name);
                                  setModalState(() {});
                                  setState(() {});
                                  _showNeoSnackBar('${product.name} removed from saved finds');
                                },
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

  void _showVisualScansModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final count = CustomerService().visualScansCount;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F3E8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Color(0xFF101010), width: 2.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'VISUAL SCANS',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101010),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD400),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF101010), width: 1.2),
                        ),
                        child: Text(
                          '$count TOTAL',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF101010),
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
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
              const SizedBox(height: 6),
              const Text(
                'AI-driven local visual search activity',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B6B65),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF101010), width: 1.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF101010),
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Color(0xFF101010), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Visual AI Feature Matching',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF101010),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Every photo you capture matches directly with the live catalog of neighborhood shops in Salt Lake, Park Street, and surrounding hubs.',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF555555),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              NeoPressable(
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AiSearchScanScreen()),
                  );
                },
                height: 50,
                width: double.infinity,
                pressDepth: 2.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD400),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF101010), width: 1.8),
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
                      Icon(Icons.camera_alt, size: 18, color: Color(0xFF101010)),
                      SizedBox(width: 8),
                      Text(
                        'OPEN CAMERA SCANNER',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101010),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAppSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F3E8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: Color(0xFF101010), width: 2.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'APP SETTINGS',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101010),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
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
                  const SizedBox(height: 4),
                  const Text(
                    'Preferences, display theme, and application cache',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B6B65),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNeoSettingTile(
                    icon: Icons.palette_outlined,
                    title: 'Display Theme',
                    subtitle: 'Neo-Brutalist Light (Default High Contrast)',
                    trailing: const Icon(Icons.check_circle, color: Color(0xFF00875A), size: 20),
                  ),
                  const SizedBox(height: 10),
                  _buildNeoSettingTile(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Clear Image & Product Cache',
                    subtitle: 'Free local storage space',
                    onTap: () {
                      PaintingBinding.instance.imageCache.clear();
                      PaintingBinding.instance.imageCache.clearLiveImages();
                      _showNeoSnackBar('Image & temporary cache cleared!');
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildNeoSettingTile(
                    icon: Icons.info_outline,
                    title: 'App Version',
                    subtitle: 'Vyom Mobile v1.2.0 • Build 26 (Release)',
                  ),
                  const SizedBox(height: 10),
                  _buildNeoSettingTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy & Terms',
                    subtitle: 'Read our customer terms of service',
                    onTap: () {
                      _showNeoSnackBar('Viewing latest privacy terms');
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

  void _showPrivacyPermissionsModal() {
    _syncPermissions();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F3E8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: Color(0xFF101010), width: 2.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PRIVACY & PERMISSIONS',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101010),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
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
                  const SizedBox(height: 4),
                  const Text(
                    'Control device permissions used by Vyom',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B6B65),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionTile(
                    icon: Icons.camera_alt_outlined,
                    title: 'Camera Access',
                    subtitle: 'Visual Search & taking photos of outfits',
                    value: _cameraPermission,
                    onChanged: (val) async {
                      if (val) {
                        final res = await Permission.camera.request();
                        final granted = res.isGranted;
                        if (!granted && res.isPermanentlyDenied) {
                          await openAppSettings();
                        }
                        setModalState(() => _cameraPermission = granted);
                        setState(() => _cameraPermission = granted);
                      } else {
                        await openAppSettings();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildPermissionTile(
                    icon: Icons.location_on_outlined,
                    title: 'Location Services',
                    subtitle: 'Show nearby shops within your neighborhood',
                    value: _locationPermission,
                    onChanged: (val) async {
                      if (val) {
                        final res = await Permission.location.request();
                        final granted = res.isGranted;
                        if (!granted && res.isPermanentlyDenied) {
                          await openAppSettings();
                        }
                        setModalState(() => _locationPermission = granted);
                        setState(() => _locationPermission = granted);
                      } else {
                        await openAppSettings();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildPermissionTile(
                    icon: Icons.photo_library_outlined,
                    title: 'Storage & Gallery',
                    subtitle: 'Pick existing images for visual style matching',
                    value: _storagePermission,
                    onChanged: (val) async {
                      if (val) {
                        final res = await Permission.photos.request();
                        final granted = res.isGranted;
                        if (!granted && res.isPermanentlyDenied) {
                          await openAppSettings();
                        }
                        setModalState(() => _storagePermission = granted);
                        setState(() => _storagePermission = granted);
                      } else {
                        await openAppSettings();
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async => await openAppSettings(),
                      icon: const Icon(Icons.settings_outlined, size: 16, color: Color(0xFF101010)),
                      label: const Text(
                        'OPEN DEVICE APP SETTINGS',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101010),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  NeoPressable(
                    onTap: () {
                      Navigator.of(context).pop();
                      _showNeoSnackBar('Permission preferences updated!');
                    },
                    height: 46,
                    width: double.infinity,
                    pressDepth: 1.5,
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
                    child: const Center(
                      child: Text(
                        'SAVE SETTINGS',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: Color(0xFF101010),
                        ),
                      ),
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

  void _showHowVisualSearchWorksModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F3E8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Color(0xFF101010), width: 2.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'HOW VISUAL SEARCH WORKS',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101010),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
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
              const SizedBox(height: 4),
              const Text(
                'Find any outfit in local shops in 4 simple steps',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B6B65),
                ),
              ),
              const SizedBox(height: 16),
              _buildVisualSearchStep(
                stepNumber: '1',
                icon: Icons.camera_alt_outlined,
                title: 'Open Camera Scanner',
                subtitle: 'Tap the camera scanner icon in the search bar or shop page',
              ),
              const SizedBox(height: 10),
              _buildVisualSearchStep(
                stepNumber: '2',
                icon: Icons.camera_outlined,
                title: 'Snap or Upload Photo',
                subtitle: 'Take a picture of any outfit, dress, shoe, or reference style',
              ),
              const SizedBox(height: 10),
              _buildVisualSearchStep(
                stepNumber: '3',
                icon: Icons.crop_free_outlined,
                title: 'Select Item Focus',
                subtitle: 'Tap or box the specific item (footwear, clothing, or accessory)',
              ),
              const SizedBox(height: 10),
              _buildVisualSearchStep(
                stepNumber: '4',
                icon: Icons.search_rounded,
                title: 'Discover Local Matches',
                subtitle: 'Get instant matching products available in nearby shops!',
              ),
              const SizedBox(height: 20),
              NeoPressable(
                onTap: () => Navigator.of(context).pop(),
                height: 46,
                width: double.infinity,
                pressDepth: 1.5,
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
                child: const Center(
                  child: Text(
                    'GOT IT, LET’S SHOP',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Color(0xFF101010),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF101010), width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF101010),
            offset: Offset(1.5, 1.5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF101010), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101010),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B6B65),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFF101010),
            activeTrackColor: const Color(0xFFFFD400),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildVisualSearchStep({
    required String stepNumber,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF101010), width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF101010),
            offset: Offset(1.5, 1.5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD400),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF101010), width: 1.5),
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101010),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101010),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B6B65),
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 20, color: const Color(0xFF101010)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = CustomerService();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Custom Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PROFILE & SETTINGS',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF101010),
                    ),
                  ),
                  NeoPressable(
                    onTap: _showAppSettingsModal,
                    width: 44,
                    height: 44,
                    pressDepth: 1.5,
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
                    child: const Center(
                      child: Icon(Icons.settings_outlined, size: 20, color: Color(0xFF101010)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. User Info Neo-Card (Registered vs Guest)
              if (customer.isRegistered)
                _buildRegisteredCard(customer)
              else
                _buildGuestCard(),

              const SizedBox(height: 16),

              // 3. Switch to Seller Banner (Golden Yellow Neo-Card)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD400),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF101010), width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF101010),
                      offset: Offset(2.5, 3.0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF101010),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'OWN A SHOP?',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Showcase to local buyers',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101010),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'List inventory and reach customers around your shop.',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101010),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    NeoPressable(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SellerDashboardScreen(),
                          ),
                        );
                      },
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      pressDepth: 1.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF101010),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF101010), width: 1.5),
                      ),
                      child: const Center(
                        child: Text(
                          'Switch',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. Discovery Stats
              const Text(
                'MY DISCOVERY STATS',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF939393),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: NeoPressable(
                      onTap: _showSavedProductsModal,
                      padding: const EdgeInsets.all(16),
                      pressDepth: 1.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF101010), width: 1.6),
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
                          const Icon(Icons.favorite, color: Colors.red, size: 22),
                          const SizedBox(height: 8),
                          Text(
                            CustomerService().likedProductNames.length.toString(),
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101010),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Saved Finds',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B6B65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoPressable(
                      onTap: _showVisualScansModal,
                      padding: const EdgeInsets.all(16),
                      pressDepth: 1.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF101010), width: 1.6),
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
                          const Icon(Icons.camera_alt_outlined, color: Color(0xFF101010), size: 22),
                          const SizedBox(height: 8),
                          Text(
                            CustomerService().visualScansCount.toString(),
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101010),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Visual Scans',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B6B65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 5. Preferences & Settings
              const Text(
                'PREFERENCES & SUPPORT',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF939393),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 10),

              _buildNeoSettingTile(
                icon: Icons.notifications_none,
                title: 'Neighborhood Alerts',
                subtitle: 'New shop additions and local updates',
                trailing: Switch(
                  value: _neighborhoodAlerts,
                  activeThumbColor: const Color(0xFF101010),
                  activeTrackColor: const Color(0xFFFFD400),
                  onChanged: (val) {
                    setState(() => _neighborhoodAlerts = val);
                    _showNeoSnackBar(
                      val ? 'Neighborhood alerts enabled' : 'Neighborhood alerts disabled',
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              _buildNeoSettingTile(
                icon: Icons.history,
                title: 'Search History',
                subtitle: 'Clear recent searches and image scans',
                onTap: _showSearchHistoryModal,
              ),
              const SizedBox(height: 10),
              _buildNeoSettingTile(
                icon: Icons.shield_outlined,
                title: 'Privacy & Permissions',
                subtitle: 'Camera, location, and storage settings',
                onTap: _showPrivacyPermissionsModal,
              ),
              const SizedBox(height: 10),
              _buildNeoSettingTile(
                icon: Icons.help_outline,
                title: 'How Visual Search Works',
                subtitle: 'Learn about our local computer vision matching',
                onTap: _showHowVisualSearchWorksModal,
              ),

              const SizedBox(height: 24),

              // 6. Role Switch / Logout Button
              NeoPressable(
                onTap: () async {
                  final nav = Navigator.of(context);
                  if (customer.isRegistered) {
                    await CustomerService().resetProfile();
                  }
                  if (!mounted) return;
                  nav.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const ChooseRoleScreen()),
                    (route) => false,
                  );
                },
                height: 50,
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
                  child: Text(
                    customer.isRegistered ? 'LOGOUT / SWITCH ROLE' : 'SWITCH ROLE / CHOOSE ACCOUNT',
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF101010),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisteredCard(CustomerService customer) {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD400),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF101010), width: 2),
            ),
            child: Center(
              child: Text(
                customer.initials,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101010),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name.isNotEmpty ? customer.name : 'Shopper',
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101010),
                  ),
                ),
                const SizedBox(height: 2),
                if (customer.phone.isNotEmpty)
                  Text(
                    customer.phone,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B6B65),
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/lcn_icon.svg',
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF101010),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      customer.neighborhood,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101010),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          NeoPressable(
            onTap: _navigateToRegister,
            width: 36,
            height: 36,
            pressDepth: 1.5,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F3E8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF101010), width: 1.4),
            ),
            child: const Center(
              child: Icon(
                Icons.edit_outlined,
                size: 16,
                color: Color(0xFF101010),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCard() {
    return Container(
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
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3E8),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF101010), width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 28,
                    color: Color(0xFF101010),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'GUEST SHOPPER',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            color: Color(0xFF101010),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD400),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF101010), width: 1.0),
                          ),
                          child: const Text(
                            'GUEST',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Color(0xFF101010),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Exploring local shop catalog',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B6B65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F3E8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF101010), width: 1.2),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFF101010)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Create a profile or login to save favorites & get local shop drops',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF323232),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 2 Prominent Buttons: REGISTER & LOGIN
          Row(
            children: [
              // REGISTER BUTTON
              Expanded(
                child: NeoPressable(
                  onTap: _navigateToRegister,
                  height: 44,
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_alt_1_outlined, size: 16, color: Color(0xFF101010)),
                      SizedBox(width: 6),
                      Text(
                        'REGISTER',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          color: Color(0xFF101010),
                        ),
                      ),
                      SizedBox(width: 4),
                      VyomArrow.forward(
                        size: 13,
                        color: Color(0xFF101010),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // LOGIN BUTTON
              Expanded(
                child: NeoPressable(
                  onTap: _navigateToLogin,
                  height: 44,
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
                      Icon(Icons.login_rounded, size: 16, color: Color(0xFF101010)),
                      SizedBox(width: 6),
                      Text(
                        'LOGIN',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
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
    );
  }

  Widget _buildNeoSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF101010), width: 1.6),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF101010),
              offset: Offset(2.0, 2.0),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF101010), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101010),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B6B65),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing else const Icon(Icons.chevron_right, color: Color(0xFF101010)),
          ],
        ),
      ),
    );
  }
}
