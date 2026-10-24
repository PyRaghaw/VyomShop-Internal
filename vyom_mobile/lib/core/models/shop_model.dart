import '../services/shop_service.dart';

class ShopModel {
  final String id;
  final String name;
  final String category;
  final String tag;
  final double rating;
  final int reviewsCount;
  final double distanceKm;
  final String address;
  final String neighborhood;
  final double latitude;
  final double longitude;
  final bool isOpen;
  final String imageUrl;
  final String phone;
  final String? closingTime;
  final String? openTime;
  final String? ownerName;
  final String? email;
  final String? description;

  const ShopModel({
    required this.id,
    required this.name,
    required this.category,
    required this.tag,
    required this.rating,
    required this.reviewsCount,
    required this.distanceKm,
    required this.address,
    required this.neighborhood,
    required this.latitude,
    required this.longitude,
    required this.isOpen,
    required this.imageUrl,
    required this.phone,
    this.closingTime,
    this.openTime,
    this.ownerName,
    this.email,
    this.description,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    String derivedCategory = (json['category'] ?? '').toString();
    if (derivedCategory.isEmpty && json['featuredProducts'] is List && (json['featuredProducts'] as List).isNotEmpty) {
      derivedCategory = (json['featuredProducts'][0]['category'] ?? '').toString();
    }
    if (derivedCategory.isEmpty) {
      derivedCategory = 'Retail';
    }

    final neighborhoodVal = (json['neighborhood'] ?? json['area'] ?? json['city'] ?? 'Kolkata').toString();
    final imgUrl = (json['image_url'] ?? json['imageUrl'] ?? json['shopImage'] ?? json['bannerImage'] ?? json['image'] ?? '').toString();
    final timeStr = json['closingTime']?.toString() ?? json['closing_time']?.toString() ?? json['timings']?.toString();

    return ShopModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: derivedCategory,
      tag: (json['tag'] ?? 'LOCAL STORE').toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: (json['reviews_count'] ?? json['reviewsCount'] as num?)?.toInt() ?? 0,
      distanceKm: (json['distance_km'] ?? json['distanceKm'] as num?)?.toDouble() ?? 0.1,
      address: (json['address'] ?? '').toString(),
      neighborhood: neighborhoodVal,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 22.5726,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 88.3639,
      isOpen: json['is_open'] ?? json['isOpen'] ?? true,
      imageUrl: imgUrl,
      phone: (json['phone'] ?? '+919876543210').toString(),
      closingTime: timeStr,
      openTime: json['openTime']?.toString() ?? json['open_time']?.toString(),
      ownerName: json['ownerName']?.toString() ?? json['owner_name']?.toString(),
      email: json['email']?.toString(),
      description: json['description']?.toString(),
    );
  }

  factory ShopModel.empty() {
    return const ShopModel(
      id: 'shop_default',
      name: 'Local Boutique',
      category: 'Fashion & Lifestyle',
      tag: 'LOCAL GEM',
      rating: 4.8,
      reviewsCount: 12,
      distanceKm: 1.0,
      address: 'Salt Lake Sector V, Kolkata',
      neighborhood: 'Salt Lake',
      latitude: 22.5867,
      longitude: 88.4178,
      isOpen: true,
      imageUrl: '',
      phone: '+919876543210',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'tag': tag,
      'rating': rating,
      'reviews_count': reviewsCount,
      'distance_km': distanceKm,
      'address': address,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
      'is_open': isOpen,
      'image_url': imageUrl,
      'phone': phone,
      'closingTime': closingTime,
      'openTime': openTime,
      'ownerName': ownerName,
      'email': email,
      'description': description,
    };
  }
}

/// Dynamic shops accessor connected to the ShopService cache
List<ShopModel> get demoShops => ShopService().cachedShops;
