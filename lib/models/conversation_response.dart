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
      cursor: json['cursor'] ?? '',
      hasMore: json['has_more'] ?? false,
      limit: json['limit'] ?? 20,
      items: (json['items'] as List<dynamic>)
          .map((item) => ConversationItem.fromJson(item))
          .toList(),
    );
  }
}

class ConversationItem {
  final String id;
  final String title;
  final int createdAt;

  ConversationItem({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    return ConversationItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      createdAt: json['createdAt'] ?? 0,
    );
  }
}
