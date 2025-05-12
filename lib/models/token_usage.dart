class TokenUsage {
  final int availableTokens;
  final int totalTokens;
  final bool unlimited;
  final DateTime date;

  TokenUsage({
    required this.availableTokens,
    required this.totalTokens,
    required this.unlimited,
    required this.date,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      availableTokens: json['availableTokens'] ?? 0,
      totalTokens: json['totalTokens'] ?? 0,
      unlimited: json['unlimited'] ?? false,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availableTokens': availableTokens,
      'totalTokens': totalTokens,
      'unlimited': unlimited,
      'date': date.toIso8601String(),
    };
  }
}
