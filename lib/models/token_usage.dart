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
      availableTokens: json['availableTokens'],
      totalTokens: json['totalTokens'],
      unlimited: json['unlimited'],
      date: DateTime.parse(json['date']),
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
