import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/product_service.dart';

class ProductModel {
  final String id;
  final String shopId;
  final String shopName;
  final String name;
  final String category;
  final double price;
  final double? mrp;
  final double rating;
  final double distanceKm;
  final bool inStock;
  final String imageUrl;
  final String description;
  final Color cardColor;
  final int? matchPercentage;
  final List<String> sizes;
  final List<String> colors;

  String get title => name;
  bool get isAvailable => inStock;

  const ProductModel({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.name,
    required this.category,
    required this.price,
    this.mrp,
    this.rating = 4.8,
    required this.distanceKm,
    this.inStock = true,
    required this.imageUrl,
    required this.description,
    this.cardColor = AppColors.tintCream,
    this.matchPercentage,
    this.sizes = const ['UK 7', 'UK 8', 'UK 9', 'UK 10'],
    this.colors = const ['Black', 'Off-White', 'Olive'],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String img = '';
    if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      img = json['image_url'].toString();
    } else if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
      img = json['imageUrl'].toString();
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      img = json['image'].toString();
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      img = (json['images'] as List).first.toString();
    }

    List<String> parsedSizes = const ['UK 7', 'UK 8', 'UK 9', 'UK 10'];
    if (json['sizes'] is List) {
      parsedSizes = (json['sizes'] as List).map((e) => e.toString().trim()).toList();
    } else if (json['sizes'] is String && (json['sizes'] as String).isNotEmpty) {
      parsedSizes = (json['sizes'] as String).split(',').map((s) => s.trim()).toList();
    }

    List<String> parsedColors = const ['Black', 'Off-White', 'Olive'];
    if (json['colors'] is List) {
      parsedColors = (json['colors'] as List).map((e) => e.toString().trim()).toList();
    } else if (json['colors'] is String && (json['colors'] as String).isNotEmpty) {
      parsedColors = (json['colors'] as String).split(',').map((c) => c.trim()).toList();
    }

    final sId = json['shop_id'] ?? json['shopId'] ?? (json['shop'] is Map ? json['shop']['id'] : null) ?? '';
    final sName = json['shop_name'] ?? json['shopName'] ?? (json['shop'] is Map ? json['shop']['name'] : null) ?? '';

    final stockVal = json['stockStatus'];
    final isInStock = stockVal != null
        ? (stockVal == 'IN_STOCK' || stockVal == 'LIMITED')
        : (json['in_stock'] ?? json['inStock'] ?? true);

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      shopId: sId.toString(),
      shopName: sName.toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      mrp: (json['mrp'] ?? json['original_price'] ?? json['originalPrice'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      distanceKm: (json['distance_km'] ?? json['distanceKm'] as num?)?.toDouble() ?? 1.0,
      inStock: isInStock,
      imageUrl: img,
      description: (json['description'] ?? '').toString(),
      matchPercentage: (json['match_percentage'] ?? json['matchPercentage'] as num?)?.toInt(),
      sizes: parsedSizes,
      colors: parsedColors,
    );
  }

  ProductModel copyWith({
    String? id,
    String? shopId,
    String? shopName,
    String? name,
    String? category,
    double? price,
    double? mrp,
    double? rating,
    double? distanceKm,
    bool? inStock,
    String? imageUrl,
    String? description,
    Color? cardColor,
    int? matchPercentage,
    List<String>? sizes,
    List<String>? colors,
  }) {
    return ProductModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      rating: rating ?? this.rating,
      distanceKm: distanceKm ?? this.distanceKm,
      inStock: inStock ?? this.inStock,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      cardColor: cardColor ?? this.cardColor,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'shop_name': shopName,
      'name': name,
      'category': category,
      'price': price,
      'mrp': mrp,
      'rating': rating,
      'distance_km': distanceKm,
      'in_stock': inStock,
      'image_url': imageUrl,
      'description': description,
      'match_percentage': matchPercentage,
      'sizes': sizes,
      'colors': colors,
    };
  }
}

/// Dynamic products accessor connected to the ProductService cache
List<ProductModel> get demoProducts => ProductService().cachedProducts;
