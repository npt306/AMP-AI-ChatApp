import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  
  // Keys for storing data
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'email';

  // Save authentication data
  static Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _emailKey, value: email);
  }

  // Get authentication data
  static Future<Map<String, String?>> getAuthData() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final userId = await _storage.read(key: _userIdKey);
    final email = await _storage.read(key: _emailKey);

    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user_id': userId,
      'email': email,
    };
  }

  // Clear all authentication data
  static Future<void> clearAuthData() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _emailKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    return accessToken != null;
  }
} 