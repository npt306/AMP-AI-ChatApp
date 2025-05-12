import 'token_service.dart';

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
      _remainingTokens = tokenUsage.availableTokens;
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
