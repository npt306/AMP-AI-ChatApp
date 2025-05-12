class MessageResponse {
  final String conversationId;
  final String message;
  final int remainingUsage;

  MessageResponse({
    required this.conversationId,
    required this.message,
    required this.remainingUsage,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      conversationId: json['conversationId'] ?? '',
      message: json['message'] ?? '',
      remainingUsage: json['remainingUsage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'message': message,
      'remainingUsage': remainingUsage,
    };
  }

  @override
  String toString() {
    return 'MessageResponse(conversationId: $conversationId, message: $message, remainingUsage: $remainingUsage)';
  }
}
