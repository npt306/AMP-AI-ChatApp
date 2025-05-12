import 'dart:convert';
import '../config/api_config.dart';
import '../models/message_response.dart';
import '../models/conversation_response.dart';
import 'api_client.dart';

class AiChatService {
  static final ApiClient _apiClient = ApiClient();

  static Future<MessageResponse> chatWithBot({
    required List<Map<String, dynamic>> messages,
    required String modelId,
    required String modelName,
    String? conversationId,
  }) async {
    const endpoint = '/api/v1/ai-chat/messages';

    final body = jsonEncode({
      'content': messages.last['content'],
      'files': [],
      'metadata': {
        'conversation': {
          'id': conversationId,
          'messages': messages
              .map((msg) => {
                    'role': msg['role'],
                    'content': msg['content'],
                    'files': msg['files'] ?? [],
                    'assistant': {
                      'model': 'knowledge-base',
                      'name': modelName,
                      'id': modelId,
                    },
                  })
              .toList(),
        },
      },
      'assistant': {
        'model': 'knowledge-base',
        'name': modelName,
        'id': modelId,
      },
    });

    print("Request body: $body"); // Debug log

    try {
      final response = await _apiClient.post(
        '${ApiConfig.jarvisBaseUrl}$endpoint',
        body: body,
      );

      print("Response status: ${response.statusCode}"); // Debug log
      print("Response body: ${response.body}"); // Debug log

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return MessageResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to chat with bot: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in chatWithBot: $e'); // Debug log
      rethrow;
    }
  }

  static Future<MessageResponse> sendMessage({
    required String content,
    required String modelId,
    required String modelName,
    String? conversationId,
  }) async {
    const endpoint = '/api/v1/ai-chat/messages';
    final headers = {
      'x-jarvis-guid': '',
    };

    final body = jsonEncode({
      'content': content,
      "files": [],
      "metadata": {
        "conversation": {"id": conversationId, "messages": []}
      },
      "assistant": {"id": modelId, "model": "dify", "name": modelName}
    });

    // print("Body: $body");

    try {
      final response = await _apiClient.post(
        '${ApiConfig.jarvisBaseUrl}$endpoint',
        headers: headers,
        body: body,
      );

      // print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return MessageResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to send message: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<ConversationResponse> getConversations({
    String? cursor,
    int limit = 20,
    String? assistantId,
  }) async {
    final endpoint = '/api/v1/ai-chat/conversations';
    final queryParams = {
      if (cursor != null) 'cursor': cursor,
      // Wrap limit in a list to match expected format
      if (assistantId != null)
        'assistantId': assistantId
      else
        'assistantId': 'gpt-4o-mini',
      'assistantModel': 'dify',
    };

    try {
      final response = await _apiClient.get(
        '${ApiConfig.jarvisBaseUrl}$endpoint',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return ConversationResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to get conversations: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<ConversationResponse> getConversationHistory({
    required String conversationId,
    String? cursor,
    int limit = 100,
    String? assistantId,
  }) async {
    final endpoint = '/api/v1/ai-chat/conversations/$conversationId/messages';
    final queryParams = {
      if (cursor != null) 'cursor': cursor,
      // 'limit': limit,
      if (assistantId != null) 'assistantId': assistantId,
      'assistantModel': 'dify',
    };

    try {
      final response = await _apiClient.get(
        '${ApiConfig.jarvisBaseUrl}$endpoint',
        queryParameters: queryParams,
      );

      print(
          "getConversationHistory Response status: ${response.statusCode}"); // Debug log
      print(
          "getConversationHistory Response body: ${response.body}"); // Debug log

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return ConversationResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to get conversation history: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
