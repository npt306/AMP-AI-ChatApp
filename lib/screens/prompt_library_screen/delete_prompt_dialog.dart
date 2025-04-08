import 'package:flutter/material.dart';

class DeletePromptDialog extends StatelessWidget {
  final VoidCallback onDelete;

  const DeletePromptDialog({
    super.key,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delete Prompt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  iconSize: 24,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  constraints: const BoxConstraints(),
                )
              ],
            ),
            const SizedBox(height: 16),

            // Confirmation message
            const Text(
              'Are you sure you want to delete this prompt?',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    minimumSize: const Size(100, 40),
                    maximumSize: const Size(200, 50),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 32, 32, 32),
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Cancel',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 32, 32, 32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    minimumSize: const Size(100, 40),
                    maximumSize: const Size(200, 50),
                    backgroundColor: const Color.fromARGB(255, 199, 72, 72),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Delete',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Delete button
                // ElevatedButton(
                //   onPressed: () {

                //   },
                // style: ElevatedButton.styleFrom(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 24,
                //     vertical: 12,
                //   ),
                //   backgroundColor: const Color(0xFFFF4444),
                //   foregroundColor: Colors.white,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                // ),
                //   child: const Text(
                //     'Delete',
                //     style: TextStyle(
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
