import '../constants/api_endpoints.dart';
import '../data/mock_data.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import 'api_service.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal() {
    _cachedProducts = List.from(MockData.products);
  }

  final ApiService _api = ApiService();
  
  List<ProductModel> _cachedProducts = [];

  List<ProductModel> get cachedProducts => _cachedProducts;

  /// Fetches products from backend with optional filters, falling back to MockData
  Future<List<ProductModel>> getProducts({
    String? category,
    String? shopId,
    String? search,
    double? maxDistance,
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParams = <String, dynamic>{};
    if (category != null && category.isNotEmpty && category != 'All' && category != 'All finds') {
      queryParams['category'] = category;
    }
    if (shopId != null && shopId.isNotEmpty) {
      queryParams['shopId'] = shopId;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (maxDistance != null) {
      queryParams['maxDistance'] = maxDistance;
    }
    if (minPrice != null) {
      queryParams['minPrice'] = minPrice;
    }
    if (maxPrice != null) {
      queryParams['maxPrice'] = maxPrice;
    }

    try {
      final response = await _api.get(
        ApiEndpoints.products,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response != null && response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final rawList = data is List
            ? data
            : (data is Map
                ? (data['products'] ?? data['data'] ?? data['results'])
                : null);
        if (rawList is List && rawList.isNotEmpty) {
          final list = rawList
              .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          _cachedProducts = list;
          return list;
        }
      }
    } catch (_) {}

    // Fallback to rich mock data
    List<ProductModel> fallback = List.from(MockData.products);
    if (category != null && category.isNotEmpty && category != 'All' && category != 'All finds') {
      fallback = fallback
          .where((p) => p.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
    if (shopId != null && shopId.isNotEmpty) {
      fallback = fallback.where((p) => p.shopId == shopId).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      fallback = fallback
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.shopName.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q))
          .toList();
    }
    if (maxDistance != null) {
      fallback = fallback.where((p) => p.distanceKm <= maxDistance).toList();
    }
    if (minPrice != null) {
      fallback = fallback.where((p) => p.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      fallback = fallback.where((p) => p.price <= maxPrice).toList();
    }

    _cachedProducts = fallback;
    return fallback;
  }

  /// Fetches single product details
  Future<ProductModel?> getProductById(String id) async {
    try {
      final response = await _api.get(ApiEndpoints.productDetails(id));
      if (response != null && response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['product'] is Map) {
          return ProductModel.fromJson(Map<String, dynamic>.from(data['product']));
        }
      }
    } catch (_) {}

    return _cachedProducts.cast<ProductModel?>().firstWhere(
          (p) => p?.id == id,
          orElse: () => MockData.products.cast<ProductModel?>().firstWhere(
            (p) => p?.id == id,
            orElse: () => null,
          ),
        );
  }

  /// Unified search for products and shops
  Future<Map<String, dynamic>> search({
    required String query,
    String? category,
    double? maxDistance,
  }) async {
    final queryParams = <String, dynamic>{'q': query};
    if (category != null && category.isNotEmpty && category != 'All') {
      queryParams['category'] = category;
    }
    if (maxDistance != null) {
      queryParams['maxDistance'] = maxDistance;
    }

    try {
      final response = await _api.get(
        ApiEndpoints.search,
        queryParameters: queryParams,
      );

      if (response != null && response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final products = (data['products'] as List? ?? [])
            .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        final shops = (data['shops'] as List? ?? [])
            .map((item) => ShopModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        if (products.isNotEmpty || shops.isNotEmpty) {
          return {
            'products': products,
            'shops': shops,
          };
        }
      }
    } catch (_) {}

    // Fallback search over MockData
    final q = query.toLowerCase().trim();
    final matchedProducts = MockData.products.where((p) {
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.shopName.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      final matchesCategory = category == null ||
          category.isEmpty ||
          category == 'All' ||
          p.category.toLowerCase() == category.toLowerCase();
      final matchesDist = maxDistance == null || p.distanceKm <= maxDistance;
      return matchesQuery && matchesCategory && matchesDist;
    }).toList();

    final matchedShops = MockData.shops.where((s) {
      final matchesQuery = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q) ||
          s.address.toLowerCase().contains(q) ||
          (s.description?.toLowerCase().contains(q) ?? false);
      final matchesCategory = category == null ||
          category.isEmpty ||
          category == 'All' ||
          s.category.toLowerCase() == category.toLowerCase();
      final matchesDist = maxDistance == null || s.distanceKm <= maxDistance;
      return matchesQuery && matchesCategory && matchesDist;
    }).toList();

    return {
      'products': matchedProducts,
      'shops': matchedShops,
    };
  }

  /// Visual / Image search
  Future<List<ProductModel>> visualSearch(String imageUrl) async {
    final response = await _api.post(
      ApiEndpoints.visualSearch,
      data: {'imageUrl': imageUrl},
    );

    if (response != null && response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data['matches'] is List) {
        return (data['matches'] as List)
            .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }

    return <ProductModel>[];
  }

  /// Create product
  Future<ProductModel?> createProduct(Map<String, dynamic> productData) async {
    final response = await _api.post(
      ApiEndpoints.products,
      data: productData,
    );

    if (response != null && response.statusCode == 201 && response.data != null) {
      final data = response.data;
      if (data['product'] is Map) {
        final newProd = ProductModel.fromJson(Map<String, dynamic>.from(data['product']));
        _cachedProducts.insert(0, newProd);
        return newProd;
      }
    }
    return null;
  }
}
