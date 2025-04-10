import 'dart:convert';
import '../config/api_config.dart';
import '../models/prompt.dart';
import '../models/prompt_response.dart';
import 'api_client.dart';

class PromptService {
  static const String _baseEndpoint = '/api/v1/prompts';
  static final ApiClient _apiClient = ApiClient();

  static Future<PromptResponse> getPrompts({
    String? query,
    int offset = 0,
    int limit = 20,
    bool? isPublic,
    Category? category,
    bool? isFavorite,
  }) async {
    final queryParams = {
      if (query != null) 'query': query,
      'offset': offset.toString(),
      'limit': limit.toString(),
      if (isPublic != null) 'isPublic': isPublic.toString(),
      if (category != null) 'category': category.toString().split('.').last,
      if (isFavorite != null) 'isFavorite': isFavorite.toString(),
    };

    try {
      final response = await _apiClient.get(
        '${ApiConfig.jarvisBaseUrl}$_baseEndpoint',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return PromptResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load prompts: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createPrompt({
    required String title,
    required String content,
    String? description,
    Category? category,
    bool isPublic = false,
    String language = 'English',
  }) async {
    final body = jsonEncode({
      'title': title,
      'content': content,
      if (description != null) 'description': description,
      if (category != null) 'category': category.toString().split('.').last,
      'isPublic': isPublic,
      'language': language,
    });

    final response = await _apiClient.post(
      '${ApiConfig.jarvisBaseUrl}$_baseEndpoint',
      body: body,
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create prompt: ${response.reasonPhrase}');
    }
  }

  static Future<void> updatePrompt({
    required String id,
    String? title,
    String? content,
    String? description,
    Category? category,
    bool? isPublic,
    String? language,
  }) async {
    final body = jsonEncode({
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (description != null) 'description': description,
      if (category != null) 'category': category.toString().split('.').last,
      if (isPublic != null) 'isPublic': isPublic,
      if (language != null) 'language': language,
    });

    final response = await _apiClient.patch(
      '${ApiConfig.jarvisBaseUrl}$_baseEndpoint/$id',
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update prompt: ${response.reasonPhrase}');
    }
  }

  static Future<void> deletePrompt(String id) async {
    final response = await _apiClient.delete(
      '${ApiConfig.jarvisBaseUrl}$_baseEndpoint/$id',
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete prompt: ${response.reasonPhrase}');
    }
  }

  /// Thêm prompt vào danh sách yêu thích
  ///
  /// Tham số:
  /// - `id`: ID của prompt cần thêm vào yêu thích
  ///
  /// Throws:
  /// - `Exception` nếu có lỗi xảy ra trong quá trình thêm
  static Future<void> addToFavorite(String id) async {
    final response = await _apiClient.post(
      '${ApiConfig.jarvisBaseUrl}$_baseEndpoint/$id/favorite',
    );

    if (response.statusCode != 201) {
      throw Exception(
          'Failed to add prompt to favorites: ${response.reasonPhrase}');
    }
  }

  /// Xóa prompt khỏi danh sách yêu thích
  ///
  /// Tham số:
  /// - `id`: ID của prompt cần xóa khỏi yêu thích
  ///
  /// Throws:
  /// - `Exception` nếu có lỗi xảy ra trong quá trình xóa
  static Future<void> removeFromFavorite(String id) async {
    final response = await _apiClient.delete(
      '${ApiConfig.jarvisBaseUrl}$_baseEndpoint/$id/favorite',
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to remove prompt from favorites: ${response.reasonPhrase}');
    }
  }

  /// Bật/tắt trạng thái yêu thích của một prompt
  ///
  /// Tham số:
  /// - `id`: ID của prompt
  /// - `isFavorite`: Trạng thái yêu thích muốn thiết lập (true để thêm, false để xóa)
  ///
  /// Throws:
  /// - `Exception` nếu có lỗi xảy ra
  static Future<void> toggleFavorite(String id, {bool? isFavorite}) async {
    if (isFavorite == null) {
      // Trong trường hợp không biết trạng thái hiện tại,
      // bạn có thể cần fetch prompt để kiểm tra, nhưng ở đây giả sử
      // UI đã biết trạng thái và truyền vào isFavorite
      throw Exception('Cannot toggle favorite without knowing current state');
    }

    if (isFavorite) {
      await addToFavorite(id);
    } else {
      await removeFromFavorite(id);
    }
  }
}
