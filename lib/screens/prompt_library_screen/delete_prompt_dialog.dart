import 'package:flutter/material.dart';
import '../../services/prompt_service.dart';

class DeletePromptDialog extends StatefulWidget {
  final Function onDelete;
  final String promptId;
  final String promptName;

  const DeletePromptDialog({
    super.key,
    required this.onDelete,
    required this.promptId,
    required this.promptName,
  });

  @override
  State<DeletePromptDialog> createState() => _DeletePromptDialogState();
}

class _DeletePromptDialogState extends State<DeletePromptDialog> {
  bool _isLoading = false;

  Future<void> _deletePrompt() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await PromptService.deletePrompt(widget.promptId);
      if (mounted) {
        Navigator.of(context).pop();
        widget.onDelete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prompt deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting prompt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Prompt'),
      content: Text('Are you sure you want to delete "${widget.promptName}"?'),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _deletePrompt,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
        ),
      ],
    );
  }
}
