class Bot {
  final String id;
  final String assistantName;
  final String? instructions;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedAt;
  final String userId;
  final bool isDefault;
  final bool isFavorite;
  final List<String> permissions;
  final Map<String, dynamic> config;

  Bot({
    required this.id,
    required this.assistantName,
    this.instructions,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedAt,
    required this.userId,
    required this.isDefault,
    required this.isFavorite,
    required this.permissions,
    required this.config,
  });

  factory Bot.fromJson(Map<String, dynamic> json) {
    print('Parsing Bot from JSON: $json'); // Debug log
    return Bot(
      id: json['id']?.toString() ?? '',
      assistantName: json['assistantName']?.toString() ?? '',
      instructions: json['instructions']?.toString(),
      description: json['description']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      deletedAt: json['deletedAt']?.toString(),
      userId: json['userId']?.toString() ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      config: json['config'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assistantName': assistantName,
      'instructions': instructions,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'deletedAt': deletedAt,
      'userId': userId,
      'isDefault': isDefault,
      'isFavorite': isFavorite,
      'permissions': permissions,
      'config': config,
    };
  }
}
