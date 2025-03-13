import 'package:flutter/material.dart';
import 'prompt.dart';

class PromptCard extends StatelessWidget {
  final Prompt prompt;
  final bool isPublicPrompt;
  final VoidCallback? onToggleFavorite;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PromptCard({
    super.key,
    required this.prompt,
    required this.isPublicPrompt,
    required this.onTap,
    this.onToggleFavorite,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          crossAxisAlignment: isPublicPrompt ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title luôn hiển thị
                  Text(
                    prompt.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2540),
                    ),
                  ),
                  // Description chỉ hiển thị cho public prompt
                  if (isPublicPrompt) ...[
                    const SizedBox(height: 4),
                    Text(
                      prompt.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Action buttons dựa theo trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ..._buildActions(),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.blue),
                  onPressed: onTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    if (isPublicPrompt) {
      return [
        if (onToggleFavorite != null)
          IconButton(
            icon: Icon(
              prompt.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: prompt.isFavorite ? Colors.amber : Colors.grey,
            ),
            onPressed: onToggleFavorite,
          ),
      ];
    } else {
      return [
        if (onEdit != null)
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF64748B),
            ),
            onPressed: onEdit,
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(
              Icons.delete_forever,
              color: Color(0xFF64748B),
            ),
            onPressed: onDelete,
          ),
      ];
    }
    
  }
}

