class ConversationResponse {
  final String cursor;
  final bool hasMore;
  final int limit;
  final List<ConversationItem> items;

  ConversationResponse({
    required this.cursor,
    required this.hasMore,
    required this.limit,
    required this.items,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      cursor: json['cursor']?.toString() ?? '',
      hasMore: json['has_more'] ?? false,
      limit: json['limit'] ?? 20,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) =>
                  ConversationItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ConversationItem {
  final String id;
  final String title;
  final String createdAt;
  final String? role;
  final String? content;
  final String? modelId;
  final String? answer;
  final String? query;

  ConversationItem({
    required this.id,
    required this.title,
    required this.createdAt,
    this.role,
    this.content,
    this.modelId,
    this.answer,
    this.query,
  });

  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    return ConversationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      role: json['role']?.toString(),
      content: json['content']?.toString(),
      modelId: json['modelId']?.toString(),
      answer: json['answer']?.toString(),
      query: json['query']?.toString(),
    );
  }
}
