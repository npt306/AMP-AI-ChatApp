import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:synchronized/synchronized.dart'; 
import '../config/api_config.dart';
import 'secure_storage_service.dart';
import 'auth_service.dart';

class ApiClient {
  final http.Client _client;
  static final Lock _refreshLock = Lock(); // Khóa đồng bộ khi refresh token

  ApiClient([http.Client? client]) : _client = client ?? http.Client();

  // Thêm Authorization header nếu có token
  Future<Map<String, String>> _getHeaders({
    Map<String, String>? additionalHeaders,
    bool requiresAuth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    if (requiresAuth) {
      final authData = await SecureStorageService.getAuthData();
      final accessToken = authData['access_token'];

      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    return headers;
  }

  // Xử lý việc refresh token và thử lại request
  Future<http.Response> _handleTokenRefresh(
    Function() retryRequest,
    http.Response response,
  ) async {
    if (response.statusCode == 401) {
      // Sử dụng lock để đảm bảo chỉ có một request thực hiện refresh token
      return await _refreshLock.synchronized(() async {
        // Kiểm tra token một lần nữa trong trường hợp một request khác đã refresh
        final currentAuthData = await SecureStorageService.getAuthData();
        final currentToken = currentAuthData['access_token'];

        if (currentToken != null &&
            response.request?.headers['Authorization'] ==
                'Bearer $currentToken') {
          // Token vẫn hết hạn, cần refresh
          final refreshToken = currentAuthData['refresh_token'];

          if (refreshToken != null) {
            try {
              // Thực hiện refresh token
              final newAccessToken =
                  await AuthService.refreshToken(refreshToken);

              // Lưu token mới
              await SecureStorageService.saveAuthData(
                accessToken: newAccessToken,
                refreshToken: refreshToken,
                userId: currentAuthData['user_id'] ?? '',
                email: currentAuthData['email'] ?? '',
              );

              // Thử lại request với token mới
              return await retryRequest();
            } catch (e) {
              // Nếu refresh thất bại, xóa dữ liệu xác thực và trả về lỗi ban đầu
              await SecureStorageService.clearAuthData();
              throw Exception('Token expired and refresh failed: $e');
            }
          }
        } else if (currentToken != null) {
          // Token đã được refresh bởi request khác, thử lại với token hiện tại
          return await retryRequest();
        }

        // Không có refresh token, trả về lỗi ban đầu
        throw Exception('Unauthorized and no refresh token available');
      });
    }

    return response;
  }

  // GET request với xử lý refresh token
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse(url).replace(
      queryParameters: queryParameters,
    );

    Future<http.Response> performRequest() async {
      final requestHeaders = await _getHeaders(
        additionalHeaders: headers,
        requiresAuth: requiresAuth,
      );
      return await _client.get(uri, headers: requestHeaders);
    }

    final response = await performRequest();
    return await _handleTokenRefresh(performRequest, response);
  }

  // POST request với xử lý refresh token
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = true,
  }) async {
    Future<http.Response> performRequest() async {
      final requestHeaders = await _getHeaders(
        additionalHeaders: headers,
        requiresAuth: requiresAuth,
      );
      return await _client.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: body,
      );
    }

    final response = await performRequest();
    return await _handleTokenRefresh(performRequest, response);
  }

  // PATCH request với xử lý refresh token
  Future<http.Response> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = true,
  }) async {
    Future<http.Response> performRequest() async {
      final requestHeaders = await _getHeaders(
        additionalHeaders: headers,
        requiresAuth: requiresAuth,
      );
      return await _client.patch(
        Uri.parse(url),
        headers: requestHeaders,
        body: body,
      );
    }

    final response = await performRequest();
    return await _handleTokenRefresh(performRequest, response);
  }

  // DELETE request với xử lý refresh token
  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = true,
  }) async {
    Future<http.Response> performRequest() async {
      final requestHeaders = await _getHeaders(
        additionalHeaders: headers,
        requiresAuth: requiresAuth,
      );
      return await _client.delete(
        Uri.parse(url),
        headers: requestHeaders,
        body: body,
      );
    }

    final response = await performRequest();
    return await _handleTokenRefresh(performRequest, response);
  }

  void close() {
    _client.close();
  }
}
