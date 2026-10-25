import 'package:shared_preferences/shared_preferences.dart';

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;
  CustomerService._internal();

  String name = 'Alex Kumar';
  String phone = '+91 98765 43210';
  String email = 'alex@example.com';
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
    return 'AK';
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

  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      name = prefs.getString('customer_name') ?? name;
      phone = prefs.getString('customer_phone') ?? phone;
      email = prefs.getString('customer_email') ?? email;
      neighborhood = prefs.getString('customer_neighborhood') ?? neighborhood;
      favoriteCategories = prefs.getStringList('customer_categories') ?? favoriteCategories;
      isRegistered = prefs.getBool('customer_is_registered') ?? false;
    } catch (_) {}
  }
}
