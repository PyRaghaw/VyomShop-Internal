import '../constants/api_endpoints.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import 'api_service.dart';
import 'product_service.dart';
import 'shop_service.dart';

class SellerService {
  static final SellerService _instance = SellerService._internal();
  factory SellerService() => _instance;
  SellerService._internal();

  final ApiService _api = ApiService();

  List<ProductModel> get cachedProducts => ProductService().cachedProducts;
  ShopModel? get cachedShop => ShopService().cachedShops.isNotEmpty ? ShopService().cachedShops.first : null;

  /// Get seller dashboard data
  Future<Map<String, dynamic>?> getDashboard() async {
    final response = await _api.get(ApiEndpoints.sellerDashboard);
    if (response != null && response.statusCode == 200 && response.data != null) {
      return Map<String, dynamic>.from(response.data);
    }
    return null;
  }

  /// Get seller shop details
  Future<ShopModel?> getSellerShop() async {
    final response = await _api.get(ApiEndpoints.sellerShop);
    if (response != null && response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data['shop'] is Map) {
        return ShopModel.fromJson(Map<String, dynamic>.from(data['shop']));
      }
    }
    return cachedShop;
  }

  /// Get seller products
  Future<List<ProductModel>> getSellerProducts() async {
    final response = await _api.get(ApiEndpoints.sellerProducts);
    if (response != null && response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data['products'] is List) {
        return (data['products'] as List)
            .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }
    return cachedProducts;
  }

  /// Add / Create new product
  Future<ProductModel?> createProduct(Map<String, dynamic> productData) async {
    final response = await _api.post(
      ApiEndpoints.sellerProducts,
      data: productData,
    );
    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      final data = response.data;
      if (data['product'] is Map) {
        return ProductModel.fromJson(Map<String, dynamic>.from(data['product']));
      }
    }
    return null;
  }

  /// Get available listing packages
  Future<List<Map<String, dynamic>>?> getPackages() async {
    final response = await _api.get(ApiEndpoints.sellerPackages);
    if (response != null && response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data['packages'] is List) {
        return (data['packages'] as List)
            .map((p) => Map<String, dynamic>.from(p))
            .toList();
      }
    }
    return null;
  }

  /// Get seller wallet summary
  Future<Map<String, dynamic>?> getWallet() async {
    final response = await _api.get(ApiEndpoints.sellerWallet);
    if (response != null && response.statusCode == 200 && response.data != null) {
      return Map<String, dynamic>.from(response.data);
    }
    return null;
  }

  /// Get seller analytics
  Future<Map<String, dynamic>?> getAnalytics() async {
    final response = await _api.get(ApiEndpoints.sellerAnalytics);
    if (response != null && response.statusCode == 200 && response.data != null) {
      return Map<String, dynamic>.from(response.data);
    }
    return null;
  }
}
