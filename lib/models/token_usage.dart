class TokenUsage {
  final int totalTokens;
  final int usedTokens;
  final int remainingTokens;

  TokenUsage({
    required this.totalTokens,
    required this.usedTokens,
    required this.remainingTokens,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      totalTokens: json['total_tokens'] ?? 0,
      usedTokens: json['used_tokens'] ?? 0,
      remainingTokens: json['remaining_tokens'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTokens': totalTokens,
      'usedTokens': usedTokens,
      'remainingTokens': remainingTokens,
    };
  }
}
