import 'package:shared_preferences/shared_preferences.dart';

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;
  CustomerService._internal();

  String name = '';
  String phone = '';
  String email = '';
  String neighborhood = 'Salt Lake, Kolkata';
  List<String> favoriteCategories = ['Clothing', 'Footwear'];
  bool isRegistered = false;
  int visualScansCount = 3;
  Set<String> likedProductNames = {'Everyday Canvas Shoes', 'Retro Street Sneakers'};

  List<Map<String, dynamic>> notifications = [
    {
      'id': 'notif_1',
      'title': '20% OFF AT ZARA STUDIO',
      'message': 'Exclusive neighborhood discount valid until Sunday on all fresh arrivals.',
      'time': '10m ago',
      'isRead': false,
      'type': 'discount',
    },
    {
      'id': 'notif_2',
      'title': 'VISUAL MATCH FOUND',
      'message': '3 local shops just stocked items matching your scanned footwear!',
      'time': '2h ago',
      'isRead': false,
      'type': 'match',
    },
    {
      'id': 'notif_3',
      'title': 'IN-STORE HOLD CONFIRMED',
      'message': 'Your piece is reserved at Urban Threads for the next 24 hours.',
      'time': 'Yesterday',
      'isRead': false,
      'type': 'order',
    },
    {
      'id': 'notif_4',
      'title': 'NEW SHOP IN YOUR AREA',
      'message': 'Heritage Loom & Craft is now live with 45 authentic handloom pieces.',
      'time': '2 days ago',
      'isRead': true,
      'type': 'shop',
    },
  ];

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'GS';
  }

  Future<void> incrementVisualScans() async {
    visualScansCount++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('customer_visual_scans', visualScansCount);
    } catch (_) {}
  }

  bool isProductFavorite(String productName) {
    return likedProductNames.contains(productName);
  }

  Future<void> toggleFavoriteProduct(String productName) async {
    if (likedProductNames.contains(productName)) {
      likedProductNames.remove(productName);
    } else {
      likedProductNames.add(productName);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('customer_liked_products', likedProductNames.toList());
    } catch (_) {}
  }

  Future<void> removeLikedProduct(String productName) async {
    likedProductNames.remove(productName);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('customer_liked_products', likedProductNames.toList());
    } catch (_) {}
  }

  void markAllNotificationsRead() {
    for (var n in notifications) {
      n['isRead'] = true;
    }
  }

  Future<void> saveProfile({
    required String name,
    required String phone,
    String? email,
    required String neighborhood,
    List<String>? favoriteCategories,
  }) async {
    this.name = name.trim().isNotEmpty ? name.trim() : this.name;
    this.phone = phone.trim().isNotEmpty ? phone.trim() : this.phone;
    if (email != null) {
      this.email = email.trim();
    }
    this.neighborhood = neighborhood.trim().isNotEmpty ? neighborhood.trim() : this.neighborhood;
    if (favoriteCategories != null) {
      this.favoriteCategories = favoriteCategories;
    }
    isRegistered = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('customer_name', this.name);
      await prefs.setString('customer_phone', this.phone);
      await prefs.setString('customer_email', this.email);
      await prefs.setString('customer_neighborhood', this.neighborhood);
      await prefs.setStringList('customer_categories', this.favoriteCategories);
      await prefs.setBool('customer_is_registered', true);
    } catch (_) {}
  }

  Future<void> skipRegistration() async {
    isRegistered = false;
    name = '';
    phone = '';
    email = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('customer_is_registered', false);
      await prefs.remove('customer_name');
      await prefs.remove('customer_phone');
      await prefs.remove('customer_email');
    } catch (_) {}
  }

  Future<void> resetProfile() async {
    isRegistered = false;
    name = '';
    phone = '';
    email = '';
    neighborhood = 'Salt Lake, Kolkata';
    favoriteCategories = ['Clothing', 'Footwear'];
    visualScansCount = 0;
    likedProductNames.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('customer_name');
      await prefs.remove('customer_phone');
      await prefs.remove('customer_email');
      await prefs.remove('customer_neighborhood');
      await prefs.remove('customer_categories');
      await prefs.remove('customer_visual_scans');
      await prefs.remove('customer_liked_products');
      await prefs.setBool('customer_is_registered', false);
    } catch (_) {}
  }

  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('customer_is_registered')) {
        isRegistered = prefs.getBool('customer_is_registered') ?? false;
      }
      if (prefs.containsKey('customer_name')) {
        name = prefs.getString('customer_name') ?? '';
      }
      if (prefs.containsKey('customer_phone')) {
        phone = prefs.getString('customer_phone') ?? '';
      }
      if (prefs.containsKey('customer_email')) {
        email = prefs.getString('customer_email') ?? '';
      }
      if (prefs.containsKey('customer_neighborhood')) {
        neighborhood = prefs.getString('customer_neighborhood') ?? neighborhood;
      }
      if (prefs.containsKey('customer_categories')) {
        favoriteCategories = prefs.getStringList('customer_categories') ?? favoriteCategories;
      }
      if (prefs.containsKey('customer_visual_scans')) {
        visualScansCount = prefs.getInt('customer_visual_scans') ?? visualScansCount;
      }
      if (prefs.containsKey('customer_liked_products')) {
        final list = prefs.getStringList('customer_liked_products');
        if (list != null) {
          likedProductNames = list.toSet();
        }
      }
    } catch (_) {}
  }
}
