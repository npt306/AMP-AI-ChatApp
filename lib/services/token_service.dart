import 'dart:convert';
import '../config/api_config.dart';
import '../models/token_usage.dart';
import 'api_client.dart';

class TokenService {
  static final ApiClient _apiClient = ApiClient();

  static Future<TokenUsage> getTokenUsage() async {
    const endpoint = '/api/v1/tokens/usage';

    try {
      final response = await _apiClient.get(
        '${ApiConfig.jarvisBaseUrl}$endpoint',
      );

      print(response);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return TokenUsage.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to get usage: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
