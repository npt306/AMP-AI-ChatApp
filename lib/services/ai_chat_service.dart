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
  }) async {
    const endpoint = '/api/v1/ai-chat/messages';

    final body = jsonEncode({
      'content': messages.last['content'],
      'files': [],
      'metadata': {
        'conversation': {
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
    required String modelId, // ex: 'value': 'claude-3-haiku-20240307',
    required String modelName, // ex: 'label': 'Claude 3 Haiku',
  }) async {
    const endpoint = '/api/v1/ai-chat/messages';
    final headers = {
      'x-jarvis-guid': '',
    };

    final body = jsonEncode({
      'content': content,
      "files": [],
      "metadata": {
        "conversation": {"messages": []}
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

  static Future<ConversationResponse> getConversations(
      {String? cursor, int limit = 20}) async {
    // final endpoint = '/api/v1/ai-chat/conversations'
    //     '?cursor=${cursor ?? ''}&limit=$limit';

    // final headers = {
    //   'x-jarvis-guid': '', // nhớ điền giá trị nếu cần
    // };

    // try {
    //   final response = await _apiClient.get(
    //     '${ApiConfig.jarvisBaseUrl}$endpoint',
    //     headers: headers,
    //   );

    //   if (response.statusCode == 200) {
    //     final jsonResponse = jsonDecode(response.body);
    //     return ConversationResponse.fromJson(jsonResponse);
    //   } else {
    //     throw Exception(
    //         'Failed to get conversations: ${response.statusCode} ${response.reasonPhrase}');
    //   }
    // } catch (e) {
    //   // Bạn có thể log lỗi ra để dễ debug hơn
    //   print('Error getting conversations: $e');
    //   rethrow;
    // }

    try {
      // Đây là mock data
      final Map<String, dynamic> mockResponse = {
        "cursor": "f32a6751-9200-4357-9281-d22e5785434c",
        "has_more": false,
        "limit": 20,
        "items": [
          {
            "title": "hi 1",
            "id": "f32a6751-9200-4357-9281-347589347",
            "createdAt": 1730480205
          },
          {
            "title": "hi 2",
            "id": "f32a6751-9200-4357-9281-d22e5785434c",
            "createdAt": 1830480205
          },
          {
            "title": "hi 3",
            "id": "f32a6751-9200-4357-9281-d2asd34c",
            "createdAt": 1930480205
          },
        ]
      };

      return ConversationResponse.fromJson(mockResponse);
    } catch (e) {
      print('Error parsing mock data: $e');
      rethrow;
    }
  }
}
