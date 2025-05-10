import 'dart:convert';
import '../config/api_config.dart';
import '../models/knowledge.dart';
import 'api_client.dart';

class KnowledgeService {
  static final ApiClient _apiClient = ApiClient();

  // Create new knowledge
  static Future<Knowledge> createKnowledge({
    required String knowledgeName,
    required String description,
  }) async {
    const endpoint = '/kb-core/v1/knowledge';

    try {
      final response = await _apiClient.post(
        '${ApiConfig.knowledgeBaseUrl}$endpoint',
        body: jsonEncode({
          'knowledgeName': knowledgeName,
          'description': description,
        }),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return Knowledge.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to create knowledge: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get all knowledges
  static Future<List<Knowledge>> getKnowledges() async {
    const endpoint =
        '/kb-core/v1/knowledge?q&order=DESC&order_field=createdAt&offset&limit=20';

    try {
      final response = await _apiClient.get(
        '${ApiConfig.knowledgeBaseUrl}$endpoint',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> knowledgeList =
            jsonResponse['data'] as List<dynamic>;
        return knowledgeList.map((json) => Knowledge.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get knowledges: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update knowledge
  static Future<Knowledge> updateKnowledge({
    required String id,
    String? knowledgeName,
    String? description,
  }) async {
    final endpoint = '/api/v1/knowledge/$id';

    try {
      final Map<String, dynamic> updateData = {};
      if (knowledgeName != null) updateData['knowledgeName'] = knowledgeName;
      if (description != null) updateData['description'] = description;

      final response = await _apiClient.patch(
        '${ApiConfig.knowledgeBaseUrl}$endpoint',
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Knowledge.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to update knowledge: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete knowledge
  static Future<bool> deleteKnowledge(String id) async {
    try {
      final endpoint = '/kb-core/v1/knowledge/$id';
      final response = await _apiClient.delete(
        '${ApiConfig.knowledgeBaseUrl}$endpoint',
      );

      // API trả về 200 hoặc 204 khi xóa thành công
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      throw Exception('Failed to delete knowledge: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
