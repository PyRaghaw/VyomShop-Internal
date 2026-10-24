import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/shop_model.dart';
import 'neo_pressable.dart';
import '../../features/customer/presentation/shop_detail_screen.dart';

class ShopCardWidget extends StatefulWidget {
  final ShopModel shop;
  final VoidCallback? onFavoriteTap;
  final bool? isFavorite;

  const ShopCardWidget({
    super.key,
    required this.shop,
    this.onFavoriteTap,
    this.isFavorite,
  });

  @override
  State<ShopCardWidget> createState() => _ShopCardWidgetState();
}

class _ShopCardWidgetState extends State<ShopCardWidget> {
  bool _internalFavorite = false;

  @override
  void initState() {
    super.initState();
    _internalFavorite = widget.isFavorite ?? false;
  }

  @override
  void didUpdateWidget(covariant ShopCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != null) {
      _internalFavorite = widget.isFavorite!;
    }
  }

  Widget _buildCoverImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: 151,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: double.infinity,
          height: 151,
          color: const Color(0xFFF0EBE0),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF101010)),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: double.infinity,
        height: 151,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _buildPlaceholder(),
      );
    } else if (imageUrl.isNotEmpty && File(imageUrl).existsSync()) {
      return Image.file(
        File(imageUrl),
        width: double.infinity,
        height: 151,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 151,
      color: const Color(0xFFF0EBE0),
      child: const Center(
        child: Icon(Icons.storefront_outlined, size: 48, color: Color(0xFF6E6E6E)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;
    final ratingStr = shop.rating.toStringAsFixed(1);
    final distanceStr = '${shop.distanceKm.toStringAsFixed(1)} km away';
    
    // Walking time calculated based on standard walking speed (approx 12-13 min/km)
    int walkMinutes = (shop.distanceKm * 12.5).round();
    if (walkMinutes < 3) walkMinutes = 3;
    final walkTime = '$walkMinutes min walk';

    final bool isOpen = shop.isOpen;
    final String timeSubtext = isOpen
        ? 'Closes at ${shop.closingTime ?? '10:00 PM'}'
        : 'Opens at ${shop.openTime ?? '10:00 AM'}';

    return NeoPressable(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ShopDetailScreen(shop: shop),
          ),
        );
      },
      pressDepth: 2.0,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Cover Photo (Exact Figma height: 151px)
            SizedBox(
              height: 151,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCoverImage(shop.imageUrl),

                  // Heart / Favorite Button (Top Right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: NeoPressable(
                      onTap: () {
                        if (widget.onFavoriteTap != null) {
                          widget.onFavoriteTap!();
                        } else {
                          setState(() {
                            _internalFavorite = !_internalFavorite;
                          });
                        }
                      },
                      width: 32,
                      height: 32,
                      pressDepth: 1.0,
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
                      child: Center(
                        child: Icon(
                          _internalFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: _internalFavorite ? const Color(0xFFFF4800) : const Color(0xFF101010),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider border between image and content
            Container(
              height: 1.4,
              color: const Color(0xFF101010),
            ),

            // Bottom Content Section
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Category & Shop Name on Left, Rating Badge on Right
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Tag (8px Manrope SemiBold Uppercase)
                            Text(
                              shop.category.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600,
                                fontSize: 8,
                                height: 1.1,
                                letterSpacing: 0.5,
                                color: Color(0xFF939393),
                              ),
                            ),
                            const SizedBox(height: 3),

                            // Shop Name (20px Manrope Bold)
                            Text(
                              shop.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                height: 1.2,
                                letterSpacing: -0.3,
                                color: Color(0xFF101010),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Rating Badge (Right)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD400),
                          borderRadius: BorderRadius.circular(6),
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
                            const Icon(Icons.star, size: 12, color: Color(0xFF101010)),
                            const SizedBox(width: 3.5),
                            Text(
                              ratingStr,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Color(0xFF101010),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 2: Distance/Walk on Left | Status/Timing on Right
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Location Icon + (Distance & Walk Time)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/images/dstns_icon.svg',
                              width: 26,
                              height: 26,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  distanceStr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Color(0xFF101010),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  walkTime,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    color: Color(0xFF6E6E6E),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Vertical Divider (Symmetrically in between both sections)
                        Container(
                          width: 1,
                          height: 26,
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                          color: const Color(0xFFE2E2E2),
                        ),

                        // Right: Clock Icon + (Open/Close Status & Timing)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/images/open-now_icon.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isOpen ? 'Open now' : 'Closed',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: isOpen ? const Color(0xFF00875A) : const Color(0xFFD32F2F),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  timeSubtext,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    color: Color(0xFF6E6E6E),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
