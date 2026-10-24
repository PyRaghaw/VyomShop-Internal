import '../constants/api_endpoints.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  Map<String, dynamic>? _currentUser;

  Map<String, dynamic>? get currentUser => _currentUser;

  /// Send OTP to phone number
  Future<Map<String, dynamic>?> sendOtp(String phone) async {
    final response = await _api.post(
      ApiEndpoints.sendOtp,
      data: {'phone': phone},
    );
    if (response != null && response.statusCode == 200 && response.data != null) {
      return Map<String, dynamic>.from(response.data);
    }
    return null;
  }

  /// Verify OTP
  Future<Map<String, dynamic>?> verifyOtp(String phone, String otp) async {
    final response = await _api.post(
      ApiEndpoints.verifyOtp,
      data: {'phone': phone, 'otp': otp},
    );
    if (response != null && response.statusCode == 200 && response.data != null) {
      final data = Map<String, dynamic>.from(response.data);
      if (data['token'] != null) {
        _api.setAuthToken(data['token']);
      }
      if (data['user'] != null) {
        _currentUser = Map<String, dynamic>.from(data['user']);
      }
      return data;
    }
    return null;
  }

  /// Verify Firebase ID token with backend
  Future<Map<String, dynamic>?> verifyFirebaseToken(String idToken) async {
    final response = await _api.post(
      ApiEndpoints.verifyToken,
      data: {'idToken': idToken},
    );
    if (response != null && response.statusCode == 200 && response.data != null) {
      final data = Map<String, dynamic>.from(response.data);
      if (data['token'] != null) {
        _api.setAuthToken(data['token']);
      }
      if (data['user'] != null) {
        _currentUser = Map<String, dynamic>.from(data['user']);
      }
      return data;
    }
    return null;
  }

  /// Select Role (customer or seller)
  Future<bool> selectRole(String role, {String? userId}) async {
    final data = <String, dynamic>{'role': role};
    if (userId != null) data['userId'] = userId;
    final response = await _api.post(
      ApiEndpoints.selectRole,
      data: data,
    );
    if (response != null && response.statusCode == 200) {
      if (_currentUser != null) {
        _currentUser!['role'] = role;
      }
      return true;
    }
    return false;
  }

  /// Fetch profile of current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final response = await _api.get(ApiEndpoints.authMe);
    if (response != null && response.statusCode == 200 && response.data != null) {
      final data = Map<String, dynamic>.from(response.data);
      _currentUser = data['user'] != null ? Map<String, dynamic>.from(data['user']) : null;
      return _currentUser;
    }
    return _currentUser;
  }

  void logout() {
    _api.clearAuthToken();
    _currentUser = null;
  }
}
