import 'dart:convert';
import '../config/api_config.dart';
import '../models/token_usage.dart';
import 'api_client.dart';

class TokenManager {
  static TokenManager? _instance;
  static TokenManager get instance {
    _instance ??= TokenManager();
    return _instance!;
  }

  int _remainingTokens = 0;
  int get remainingTokens => _remainingTokens;

  Future<void> updateTokens() async {
    try {
      final tokenUsage = await TokenService.getTokenUsage();
      _remainingTokens = tokenUsage.remainingTokens;
    } catch (e) {
      print('Error updating tokens: $e');
      // Keep the current token value if update fails
    }
  }

  void updateTokensAfterMessage(int usedTokens) {
    _remainingTokens =
        (_remainingTokens - usedTokens).clamp(0, _remainingTokens);
  }
}

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
