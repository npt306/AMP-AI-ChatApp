import 'dart:convert';
import '../config/api_config.dart';
import 'api_client.dart';

class EmailService {
  static const String _baseEndpoint = '/api/v1/ai-email';
  static final ApiClient _apiClient = ApiClient();

  /// Generate email response using AI
  static Future<Map<String, dynamic>> generateEmailResponse({
    required String email,
    required String mainIdea,
    required String action,
    required Map<String, dynamic> metadata,
    String? assistantId,
    String model = 'dify',
  }) async {
    final body = jsonEncode({
      'email': email,
      'mainIdea': mainIdea,
      'action': action,
      'metadata': {
        'context': metadata['context'] ?? [],
        'subject': metadata['subject'] ?? '',
        'sender': metadata['sender'] ?? '',
        'receiver': metadata['receiver'] ?? '',
        'style': metadata['style'] ??
            {
              'length': 'medium',
              'formality': 'neutral',
              'tone': 'professional'
            },
        'language': metadata['language'] ?? 'english'
      },
      if (assistantId != null) 'assistant': {'id': assistantId, 'model': model}
    });

    final response = await _apiClient.post(
      '${ApiConfig.jarvisBaseUrl}$_baseEndpoint',
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to generate email response: ${response.reasonPhrase}');
    }
  }

  /// Get reply ideas suggestions from AI
  static Future<List<String>> getReplyIdeas({
    required String email,
    required String action,
    required Map<String, dynamic> metadata,
    String? assistantId,
    String model = 'dify',
  }) async {
    final body = jsonEncode({
      'email': email,
      'action': action,
      'metadata': {
        'context': metadata['context'] ?? [],
        'subject': metadata['subject'] ?? '',
        'sender': metadata['sender'] ?? '',
        'receiver': metadata['receiver'] ?? '',
        'language': metadata['language'] ?? 'english'
      },
      if (assistantId != null) 'assistant': {'id': assistantId, 'model': model}
    });

    final response = await _apiClient.post(
      '${ApiConfig.jarvisBaseUrl}$_baseEndpoint/reply-ideas',
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return List<String>.from(jsonResponse['ideas'] ?? []);
    } else {
      throw Exception('Failed to get reply ideas: ${response.reasonPhrase}');
    }
  }

  /// Generate a thank you email
  static Future<Map<String, dynamic>> generateThankYouEmail({
    required String email,
    required Map<String, dynamic> metadata,
    String? assistantId,
    String model = 'dify',
  }) async {
    return generateEmailResponse(
      email: email,
      mainIdea: 'Thank you for your email',
      action: 'Reply to this email',
      metadata: metadata,
      assistantId: assistantId,
      model: model,
    );
  }

  /// Generate an apology email
  static Future<Map<String, dynamic>> generateApologyEmail({
    required String email,
    required Map<String, dynamic> metadata,
    String? assistantId,
    String model = 'dify',
  }) async {
    return generateEmailResponse(
      email: email,
      mainIdea: 'I apologize for the inconvenience',
      action: 'Reply to this email',
      metadata: metadata,
      assistantId: assistantId,
      model: model,
    );
  }

  /// Generate a confirmation email (Yes)
  static Future<Map<String, dynamic>> generateConfirmationEmail({
    required String email,
    required Map<String, dynamic> metadata,
    String? assistantId,
    String model = 'dify',
  }) async {
    return generateEmailResponse(
      email: email,
      mainIdea: 'I confirm and agree to proceed',
      action: 'Reply to this email',
      metadata: metadata,
      assistantId: assistantId,
      model: model,
    );
  }

  /// Generate a rejection email (No)
  static Future<Map<String, dynamic>> generateRejectionEmail({
    required String email,
    required Map<String, dynamic> metadata,
    String? assistantId,
    String model = 'dify',
  }) async {
    return generateEmailResponse(
      email: email,
      mainIdea: 'I regret to inform you that I must decline',
      action: 'Reply to this email',
      metadata: metadata,
      assistantId: assistantId,
      model: model,
    );
  }

  /// Generate a follow-up email
  static Future<Map<String, dynamic>> generateFollowUpEmail({
    required String email,
    required Map<String, dynamic> metadata,
    String? assistantId,
    String model = 'dify',
  }) async {
    return generateEmailResponse(
      email: email,
      mainIdea: 'Following up on our previous conversation',
      action: 'Reply to this email',
      metadata: metadata,
      assistantId: assistantId,
      model: model,
    );
  }

  /// Generate a request for more information email
  static Future<Map<String, dynamic>> generateInfoRequestEmail({
    required String email,
    required Map<String, dynamic> metadata,
    String? assistantId,
    String model = 'dify',
  }) async {
    return generateEmailResponse(
      email: email,
      mainIdea: 'I would like to request more information about',
      action: 'Reply to this email',
      metadata: metadata,
      assistantId: assistantId,
      model: model,
    );
  }
}
