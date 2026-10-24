import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import '../../features/customer/presentation/product_detail_screen.dart';

class ProductCardWidget extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          Container(
            decoration: BoxDecoration(
              color: product.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(
                color: AppColors.foreground,
                width: AppTheme.borderWidth,
              ),
              boxShadow: AppTheme.neoShadowSmall,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius - 2),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.14,
                    child: product.imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: product.cardColor,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: product.cardColor,
                              child: const Icon(Icons.image_not_supported, color: AppColors.mutedText),
                            ),
                          )
                        : (product.imageUrl.startsWith('assets/')
                            ? Image.asset(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) => Container(
                                  color: product.cardColor,
                                  child: const Icon(Icons.image_not_supported, color: AppColors.mutedText),
                                ),
                              )
                            : (product.imageUrl.isNotEmpty && File(product.imageUrl).existsSync()
                                ? Image.file(
                                    File(product.imageUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => Container(
                                      color: product.cardColor,
                                      child: const Icon(Icons.image_not_supported, color: AppColors.mutedText),
                                    ),
                                  )
                                : Container(
                                    color: product.cardColor,
                                    child: const Icon(Icons.image_not_supported, color: AppColors.mutedText),
                                  ))),
                  ),
                  // Favorite Heart Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.foreground, width: 1.5),
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFavorite ? AppColors.primary : AppColors.foreground,
                        ),
                      ),
                    ),
                  ),
                  // Match % Badge (if from AI visual search)
                  if (product.matchPercentage != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppColors.foreground, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 11, color: AppColors.foreground),
                            const SizedBox(width: 4),
                            Text(
                              '${product.matchPercentage}% match',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Category & Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.mutedText,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 12, color: AppColors.primary),
                  const SizedBox(width: 3),
                  Text(
                    product.rating.toString(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          // Product Name
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 3),
          // Price & Shop
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${product.price.toInt()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.foreground,
                ),
              ),
              if (product.mrp != null)
                Text(
                  '₹${product.mrp!.toInt()}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.lineThrough,
                    color: Color(0xFF292929),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
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
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        product.shopName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6E6E6E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/images/direction.svg',
                    width: 12,
                    height: 12,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${product.distanceKm.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 11,
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
    );
  }
}
