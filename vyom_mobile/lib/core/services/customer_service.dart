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

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'GS';
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
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('customer_name');
      await prefs.remove('customer_phone');
      await prefs.remove('customer_email');
      await prefs.remove('customer_neighborhood');
      await prefs.remove('customer_categories');
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
    } catch (_) {}
  }
}
