class ApiEndpoints {
  ApiEndpoints._();

  // Configurable base URL:
  // Can be configured in code or passed via:
  // flutter run --dart-define=API_URL=http://localhost:3000/api
  static const String _envBaseUrl = String.fromEnvironment('API_URL', defaultValue: '');
  static const bool _envUseNextJs = bool.fromEnvironment('USE_NEXTJS', defaultValue: true);

  static String? _overrideBaseUrl;

  /// Set to true if targeting the Next.js backend (/api/customer/... and /api/seller/...)
  static bool useNextJsRoutes = _envUseNextJs;

  static void setBaseUrl(String url, {bool isNextJs = true}) {
    _overrideBaseUrl = url;
    useNextJsRoutes = isNextJs;
  }

  static String get baseUrl {
    if (_overrideBaseUrl != null && _overrideBaseUrl!.isNotEmpty) {
      return _overrideBaseUrl!;
    }
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    // Default to Next.js backend (port 3000) in VyomShop-Internal/backend
    return useNextJsRoutes
        ? 'http://localhost:3000/api'
        : 'http://localhost:5000/api/v1';
  }

  // Health
  static String get health => '$baseUrl/health';

  // Auth Routes
  static String get sendOtp => '$baseUrl/auth/send-otp';
  static String get verifyOtp => '$baseUrl/auth/verify-otp';
  static String get verifyToken => '$baseUrl/auth/verify-token';
  static String get authMe => '$baseUrl/auth/me';
  static String get selectRole =>
      useNextJsRoutes ? '$baseUrl/auth/selectRole' : '$baseUrl/auth/select-role';

  // Customer & Catalog Routes
  static String get shops =>
      useNextJsRoutes ? '$baseUrl/customer/shops/nearby' : '$baseUrl/shops';
  static String get nearbyShops =>
      useNextJsRoutes ? '$baseUrl/customer/shops/nearby' : '$baseUrl/shops/nearby';
  static String shopDetails(String id) =>
      useNextJsRoutes ? '$baseUrl/customer/shops/$id' : '$baseUrl/shops/$id';

  static String get products =>
      useNextJsRoutes ? '$baseUrl/customer/products/search' : '$baseUrl/products';
  static String productDetails(String id) =>
      useNextJsRoutes ? '$baseUrl/customer/products/$id' : '$baseUrl/products/$id';

  // Search Routes
  static String get search =>
      useNextJsRoutes ? '$baseUrl/customer/products/search' : '$baseUrl/search';
  static String get visualSearch => '$baseUrl/search/visual';

  // Seller Routes
  static String get sellerShop => '$baseUrl/seller/shop';
  static String get sellerProducts => '$baseUrl/seller/products';
  static String get sellerWallet => '$baseUrl/seller/wallet';
  static String get sellerAnalytics => '$baseUrl/seller/analytics';
  static String get sellerPackages => '$baseUrl/seller/packages';
  static String get sellerDashboard => '$baseUrl/seller/dashboard';
}
