import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';
import '../services/customer_service.dart';
import 'neo_pressable.dart';
import '../../features/customer/presentation/product_detail_screen.dart';

class ProductCardWidget extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onFavoriteTap;
  final bool? isFavorite;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.onFavoriteTap,
    this.isFavorite,
  });

  @override
  State<ProductCardWidget> createState() => _ProductCardWidgetState();
}

class _ProductCardWidgetState extends State<ProductCardWidget> {
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = widget.isFavorite ?? CustomerService().isProductFavorite(widget.product.name);
  }

  @override
  void didUpdateWidget(covariant ProductCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != null) {
      _isFav = widget.isFavorite!;
    } else {
      _isFav = CustomerService().isProductFavorite(widget.product.name);
    }
  }

  Widget _buildSmartImage(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFFF7F3E8),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF101010)),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: const Color(0xFFF7F3E8),
          child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF888888)),
        ),
      );
    } else if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFF7F3E8),
          child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF888888)),
        ),
      );
    } else if (url.isNotEmpty && File(url).existsSync()) {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFF7F3E8),
          child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF888888)),
        ),
      );
    } else {
      return Container(
        color: const Color(0xFFF7F3E8),
        child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF888888)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cleanPrice = product.price.toInt();
    final cleanMrp = product.mrp?.toInt();
    final cleanRating = product.rating.toStringAsFixed(1);
    final cleanDistance = '${product.distanceKm.toStringAsFixed(1)} km';

    return NeoPressable(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      pressDepth: 2.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF101010), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF101010),
            offset: Offset(2.5, 3.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Star Badge, Match Badge, and Heart Button
            Expanded(
              flex: 60,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildSmartImage(product.imageUrl),
                  // Rating Badge (Top Left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD400),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF101010), width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF101010),
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 10, color: Color(0xFF101010)),
                          const SizedBox(width: 2.5),
                          Text(
                            cleanRating,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Color(0xFF101010),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Match % Badge (Bottom Left, if from AI search)
                  if (product.matchPercentage != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD400),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: const Color(0xFF101010), width: 1.2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF101010),
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 10, color: Color(0xFF101010)),
                            const SizedBox(width: 3.5),
                            Text(
                              '${product.matchPercentage}% match',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF101010),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Wishlist Heart (Top Right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: NeoPressable(
                      onTap: () {
                        if (widget.onFavoriteTap != null) {
                          widget.onFavoriteTap!();
                        } else {
                          CustomerService().toggleFavoriteProduct(product.name);
                          setState(() {
                            _isFav = !_isFav;
                          });
                        }
                      },
                      width: 28,
                      height: 28,
                      pressDepth: 1.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF101010), width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF101010),
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isFav ? Icons.favorite : Icons.favorite_border,
                          size: 14,
                          color: _isFav ? const Color(0xFFFF4800) : const Color(0xFF101010),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              flex: 40,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: Color(0xFF939393),
                          ),
                        ),
                        const SizedBox(height: 1.5),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: Color(0xFF101010),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '₹$cleanPrice',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101010),
                              ),
                            ),
                            if (cleanMrp != null) ...[
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  '₹$cleanMrp',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.lineThrough,
                                    color: Color(0xFF292929),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/images/dstns_icon.svg',
                                width: 13,
                                height: 13,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  product.shopName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6E6E6E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/images/direction.svg',
                              width: 11,
                              height: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              cleanDistance,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
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
            ),
          ],
        ),
      ),
    );
  }
}
