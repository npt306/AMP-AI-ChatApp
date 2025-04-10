import 'prompt.dart';

class PromptResponse {
  final bool hasNext;
  final int offset;
  final int limit;
  final int total;
  final List<Prompt> items;

  PromptResponse({
    required this.hasNext,
    required this.offset,
    required this.limit,
    required this.total,
    required this.items,
  });

  factory PromptResponse.fromJson(Map<String, dynamic> json) {
    return PromptResponse(
      hasNext: json['hasNext'],
      offset: json['offset'],
      limit: json['limit'],
      total: json['total'],
      items: (json['items'] as List)
          .map((item) => Prompt.fromJson(item))
          .toList(),
    );
  }
} 