import 'dart:convert';
import '../config/api_config.dart';
import '../models/bot.dart';
import 'api_client.dart';

class BotService {
  static final ApiClient _apiClient = ApiClient();

  // Create new bot
  static Future<Bot> createBot({
    required String assistantName,
    String? instructions,
    String? description,
  }) async {
    const endpoint = '/kb-core/v1/ai-assistant';
    print('Creating bot with assistantName: $assistantName'); // Debug log

    try {
      final response = await _apiClient.post(
        '${ApiConfig.knowledgeBaseUrl}$endpoint',
        body: jsonEncode({
          'assistantName': assistantName,
          if (instructions != null) 'instructions': instructions,
          if (description != null) 'description': description,
        }),
      );

      print('Create bot response status: ${response.statusCode}'); // Debug log
      print('Create bot response body: ${response.body}'); // Debug log

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return Bot.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to create bot: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error creating bot: $e'); // Debug log
      rethrow;
    }
  }

  // Get all bots
  static Future<List<Bot>> getBots() async {
    const endpoint =
        '/kb-core/v1/ai-assistant?q&order=DESC&order_field=createdAt&offset&limit=20';
    print('Fetching all bots'); // Debug log

    try {
      final response = await _apiClient.get(
        '${ApiConfig.knowledgeBaseUrl}$endpoint',
      );

      print('Get bots response status: ${response.statusCode}'); // Debug log
      print('Get bots response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> botList = jsonResponse['data'] as List<dynamic>;
        return botList.map((json) => Bot.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get bots: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error getting bots: $e'); // Debug log
      rethrow;
    }
  }

  // Get single bot
  static Future<Bot> getBot(String id) async {
    final endpoint = '/kb-core/v1/ai-assistant/$id';
    print('Fetching bot with id: $id'); // Debug log

    try {
      final response = await _apiClient.get(
        '${ApiConfig.knowledgeBaseUrl}$endpoint',
      );

      print('Get bot response status: ${response.statusCode}'); // Debug log
      print('Get bot response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Bot.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to get bot: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error getting bot: $e'); // Debug log
      rethrow;
    }
  }

  // Update bot
  static Future<Bot> updateBot({
    required String id,
    String? assistantName,
    String? instructions,
    String? description,
  }) async {
    final endpoint = '/kb-core/v1/ai-assistant/$id';
    print('Updating bot with id: $id'); // Debug log
    print(
        'Update data - assistantName: $assistantName, instructions: $instructions, description: $description'); // Debug log

    try {
      final Map<String, dynamic> updateData = {};
      if (assistantName != null) updateData['assistantName'] = assistantName;
      if (instructions != null) updateData['instructions'] = instructions;
      if (description != null) updateData['description'] = description;

      final response = await _apiClient.patch(
        '${ApiConfig.knowledgeBaseUrl}$endpoint',
        body: jsonEncode(updateData),
      );

      print('Update bot response status: ${response.statusCode}'); // Debug log
      print('Update bot response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Bot.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to update bot: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating bot: $e'); // Debug log
      rethrow;
    }
  }

  // Delete bot
  static Future<bool> deleteBot(String id) async {
    final endpoint = '/kb-core/v1/ai-assistant/$id';
    print('Deleting bot with id: $id'); // Debug log

    try {
      final response = await _apiClient.delete(
        '${ApiConfig.knowledgeBaseUrl}$endpoint',
      );

      print('Delete bot response status: ${response.statusCode}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      throw Exception('Failed to delete bot: ${response.statusCode}');
    } catch (e) {
      print('Error deleting bot: $e'); // Debug log
      rethrow;
    }
  }

  static Future<bool> importKnowledgeToAssistant({
    required String assistantId,
    required String knowledgeId,
  }) async {
    final endpoint =
        '/kb-core/v1/ai-assistant/$assistantId/knowledges/$knowledgeId';
    print(
        'Importing knowledge $knowledgeId to assistant $assistantId'); // Debug log

    try {
      final response = await _apiClient.post(
        '${ApiConfig.knowledgeBaseUrl}$endpoint',
      );

      print(
          'Import knowledge response status: ${response.statusCode}'); // Debug log
      print('Import knowledge response body: ${response.body}'); // Debug log

      if (response.statusCode == 204) {
        // Thành công, không có body
        return true;
      } else if (response.statusCode == 200 && response.body.isNotEmpty) {
        // Một số API có thể trả về true dạng JSON
        final result = jsonDecode(response.body);
        return result == true;
      } else if (response.body.isNotEmpty) {
        // Parse lỗi chi tiết nếu có body
        final jsonResponse = jsonDecode(response.body);
        String errorMsg = jsonResponse['message'] ?? 'Unknown error';
        if (jsonResponse['details'] != null &&
            jsonResponse['details'] is List &&
            jsonResponse['details'].isNotEmpty &&
            jsonResponse['details'][0]['issue'] != null) {
          errorMsg = jsonResponse['details'][0]['issue'];
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Failed to import knowledge: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error importing knowledge: $e'); // Debug log
      rethrow;
    }
  }
}
