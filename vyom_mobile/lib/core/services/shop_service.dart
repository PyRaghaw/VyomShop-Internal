import '../constants/api_endpoints.dart';
import '../data/mock_data.dart';
import '../models/shop_model.dart';
import 'api_service.dart';

class ShopService {
  static final ShopService _instance = ShopService._internal();
  factory ShopService() => _instance;
  ShopService._internal() {
    _cachedShops = List.from(MockData.shops);
  }

  final ApiService _api = ApiService();
  
  List<ShopModel> _cachedShops = [];

  List<ShopModel> get cachedShops => _cachedShops;

  /// Fetch all shops or filter by category / search, falling back to MockData
  Future<List<ShopModel>> getShops({
    String? category,
    String? search,
    double? maxDistance,
  }) async {
    final queryParams = <String, dynamic>{};
    if (category != null && category.isNotEmpty && category != 'All') {
      queryParams['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (maxDistance != null) {
      queryParams['maxDistance'] = maxDistance;
    }

    try {
      final response = await _api.get(
        ApiEndpoints.shops,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response != null && response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final rawList = data is List
            ? data
            : (data is Map ? (data['shops'] ?? data['data']) : null);
        if (rawList is List && rawList.isNotEmpty) {
          final list = rawList
              .map((item) => ShopModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          _cachedShops = list;
          return list;
        }
      }
    } catch (_) {}

    // Fallback to rich mock shops
    List<ShopModel> fallback = List.from(MockData.shops);
    if (category != null && category.isNotEmpty && category != 'All') {
      fallback = fallback
          .where((s) => s.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      fallback = fallback
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.category.toLowerCase().contains(q) ||
              s.neighborhood.toLowerCase().contains(q))
          .toList();
    }
    if (maxDistance != null) {
      fallback = fallback.where((s) => s.distanceKm <= maxDistance).toList();
    }

    _cachedShops = fallback;
    return fallback;
  }

  /// Fetch nearby shops, falling back to MockData
  Future<List<ShopModel>> getNearbyShops({
    double? maxDistance,
    double? lat,
    double? lng,
  }) async {
    final queryParams = <String, dynamic>{};
    if (maxDistance != null) queryParams['maxDistance'] = maxDistance;
    if (lat != null) queryParams['lat'] = lat;
    if (lng != null) queryParams['lng'] = lng;

    try {
      final response = await _api.get(
        ApiEndpoints.nearbyShops,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response != null && response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final rawList = data is List
            ? data
            : (data is Map ? (data['shops'] ?? data['data']) : null);
        if (rawList is List && rawList.isNotEmpty) {
          final list = rawList
              .map((item) => ShopModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          _cachedShops = list;
          return list;
        }
      }
    } catch (_) {}

    // Fallback to rich mock shops
    List<ShopModel> fallback = List.from(MockData.shops);
    if (maxDistance != null) {
      fallback = fallback.where((s) => s.distanceKm <= maxDistance).toList();
    }

    _cachedShops = fallback;
    return fallback;
  }

  /// Get shop details by ID
  Future<ShopModel?> getShopById(String id) async {
    try {
      final response = await _api.get(ApiEndpoints.shopDetails(id));
      if (response != null && response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['shop'] is Map) {
          return ShopModel.fromJson(Map<String, dynamic>.from(data['shop']));
        }
      }
    } catch (_) {}

    return _cachedShops.cast<ShopModel?>().firstWhere(
          (s) => s?.id == id,
          orElse: () => MockData.shops.cast<ShopModel?>().firstWhere(
            (s) => s?.id == id,
            orElse: () => null,
          ),
        );
  }

  /// Create or register a new shop (Seller onboarding)
  Future<Map<String, dynamic>?> createShop(Map<String, dynamic> shopData) async {
    final response = await _api.post(
      ApiEndpoints.shops,
      data: shopData,
    );

    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      final data = response.data as Map<String, dynamic>?;
      if (data != null && data['shop'] is Map) {
        final newShop = ShopModel.fromJson(Map<String, dynamic>.from(data['shop']));
        _cachedShops.insert(0, newShop);
      }
      return data;
    }
    return null;
  }
}
