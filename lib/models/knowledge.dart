class Knowledge {
  final String id;
  final String knowledgeName;
  final String description;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  Knowledge({
    required this.id,
    required this.knowledgeName,
    required this.description,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory Knowledge.fromJson(Map<String, dynamic> json) {
    print('Parsing Knowledge from JSON: $json'); // Debug log
    return Knowledge(
      id: json['id'] as String,
      knowledgeName: json['knowledgeName'] as String,
      description: json['description'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'knowledgeName': knowledgeName,
      'description': description,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }
}
