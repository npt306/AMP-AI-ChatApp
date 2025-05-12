import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/secure_storage_service.dart';
import 'api_client.dart';

class AuthService {
  static const String _signUpEndpoint = '/api/v1/auth/password/sign-up';
  static const String _signInEndpoint = '/api/v1/auth/password/sign-in';
  static const String _refreshTokenEndpoint =
      '/api/v1/auth/sessions/current/refresh';
  static const String _logoutEndpoint = '/api/v1/auth/sessions/current';

  static final ApiClient _apiClient = ApiClient();

  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'X-Stack-Access-Type': 'client',
    'X-Stack-Project-Id': 'a914f06b-5e46-4966-8693-80e4b9f4f409',
    'X-Stack-Publishable-Client-Key':
        'pck_tqsy29b64a585km2g4wnpc57ypjprzzdch8xzpq0xhayr',
  };

  static const String _defaultVerificationCallbackUrl =
      'https://auth.dev.jarvis.cx/handler/email-verification?after_auth_return_to=%2Fauth%2Fsignin%3Fclient_id%3Djarvis_chat%26redirect%3Dhttps%253A%252F%252Fchat.dev.jarvis.cx%252Fauth%252Foauth%252Fsuccess';

  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    String? verificationCallbackUrl,
  }) async {
    final request = http.Request(
      'POST',
      Uri.parse('${ApiConfig.authBaseUrl}$_signUpEndpoint'),
    );

    request.headers.addAll(_defaultHeaders);
    request.body = jsonEncode({
      'email': email,
      'password': password,
      'verification_callback_url':
          verificationCallbackUrl ?? _defaultVerificationCallbackUrl,
    });

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ??
            'Failed to sign up: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final request = http.Request(
      'POST',
      Uri.parse('${ApiConfig.authBaseUrl}$_signInEndpoint'),
    );

    request.headers.addAll(_defaultHeaders);
    request.body = jsonEncode({
      'email': email,
      'password': password,
    });

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await SecureStorageService.saveAuthData(
          accessToken: responseData['access_token'],
          refreshToken: responseData['refresh_token'],
          userId: responseData['user_id'],
          email: email,
        );
        return responseData;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ??
            'Failed to sign in: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  static Future<String> refreshToken(String refreshToken) async {
    try {
      final client = http.Client();
      final uri = Uri.parse('${ApiConfig.authBaseUrl}$_refreshTokenEndpoint');

      final headers = {
        'X-Stack-Access-Type': 'client',
        'X-Stack-Project-Id': 'a914f06b-5e46-4966-8693-80e4b9f4f409',
        'X-Stack-Publishable-Client-Key':
            'pck_tqsy29b64a585km2g4wnpc57ypjprzzdch8xzpq0xhayr',
        'X-Stack-Refresh-Token': refreshToken,
      };

      final body = jsonEncode({});

      final response = await client.post(
        uri,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['access_token'];

        if (newAccessToken == null) {
          throw Exception('Access token not found in response');
        }

        // Lấy thông tin hiện tại
        final authData = await SecureStorageService.getAuthData();

        // Cập nhật lưu trữ với token mới
        await SecureStorageService.saveAuthData(
          accessToken: newAccessToken,
          refreshToken: refreshToken,
          userId: authData['user_id'] ?? '',
          email: authData['email'] ?? '',
        );

        return newAccessToken;
      } else {
        final errorMessage = response.body.isNotEmpty
            ? jsonDecode(response.body)['message'] ?? 'Unknown error'
            : 'Unknown error: ${response.reasonPhrase}';
        throw Exception('Failed to refresh token: $errorMessage');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    final authData = await SecureStorageService.getAuthData();
    final accessToken = authData['access_token'];
    final refreshToken = authData['refresh_token'];

    if (accessToken == null || refreshToken == null) {
      throw Exception('Access token or refresh token not found');
    }

    try {
      final headers = Map<String, String>.from(_defaultHeaders);
      headers['X-Stack-Refresh-Token'] = refreshToken;

      final response = await _apiClient.delete(
        '${ApiConfig.authBaseUrl}$_logoutEndpoint',
        headers: headers,
        body: jsonEncode({}),
      );

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ??
            'Failed to logout: ${response.reasonPhrase}');
      }

      await SecureStorageService.clearAuthData();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
}
