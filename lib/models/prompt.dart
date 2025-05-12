class Prompt {
  final String id;
  final String createdAt;
  final String updatedAt;
  final Category? category;
  final String content;
  final String? description;
  final bool isPublic;
  final String? language;
  final String title;
  final String userId;
  final String userName;
  final bool isFavorite;
  final double? limit;
  final double? offset;
  final String? query;

  Prompt({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    required this.content,
    this.description,
    required this.isPublic,
    this.language,
    required this.title,
    required this.userId,
    required this.userName,
    required this.isFavorite,
    this.limit,
    this.offset,
    this.query,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      id: json['_id'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      category: json['category'] != null ? Category.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == json['category'].toString().toLowerCase(),
        orElse: () => Category.other,
      ) : null,
      content: json['content'] ?? '',
      description: json['description'],
      isPublic: json['isPublic'] ?? false,
      language: json['language'],
      title: json['title'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      limit: json['limit']?.toDouble(),
      offset: json['offset']?.toDouble(),
      query: json['query'],
    );
  }
}

enum Category {
  business,
  career,
  chatbot,
  coding,
  education,
  fun,
  marketing,
  other,
  productivity,
  seo,
  writing
} 