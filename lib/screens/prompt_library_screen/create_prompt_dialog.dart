import 'package:flutter/material.dart';
import '../../services/prompt_service.dart';
import '../../models/prompt.dart';

class CreatePromptDialog extends StatefulWidget {
  final Function(String name, String promptText) onSave;
  final bool isUpdateMode;
  final String? initialName;
  final String? initialPrompt;
  final String? initialDescription;
  final String? promptId;
  final Category? category;
  final bool? isPublic;

  const CreatePromptDialog({
    super.key,
    required this.onSave,
    this.isUpdateMode = false,
    this.initialName,
    this.initialPrompt,
    this.initialDescription,
    this.promptId,
    this.category,
    this.isPublic,
  });

  @override
  State<CreatePromptDialog> createState() => _CreatePromptDialogState();
}

class _CreatePromptDialogState extends State<CreatePromptDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Category? _selectedCategory;
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdateMode) {
      _nameController.text = widget.initialName ?? '';
      _promptController.text = widget.initialPrompt ?? '';
      _descriptionController.text = widget.initialDescription ?? '';
      _selectedCategory = widget.category;
      _isPublic = widget.isPublic ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _savePrompt() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isUpdateMode && widget.promptId != null) {
        await PromptService.updatePrompt(
          id: widget.promptId!,
          title: _nameController.text,
          content: _promptController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          category: _selectedCategory,
          isPublic: _isPublic,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prompt updated successfully')),
          );
        }
      } else {
        await PromptService.createPrompt(
          title: _nameController.text,
          content: _promptController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          category: _selectedCategory,
          isPublic: _isPublic,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prompt created successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSave(_nameController.text, _promptController.text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isUpdateMode
                ? 'Error updating prompt: $e'
                : 'Error creating prompt: $e'),
            backgroundColor: Colors.red[700],
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
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Form(
        key: _formKey,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với tiêu đề và nút đóng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isUpdateMode ? 'Update Prompt' : 'New Prompt',
                      style: const TextStyle(
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
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Name field
                Row(
                  children: [
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '*',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  style: const TextStyle(fontSize: 14),
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Name of the prompt',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF2F4F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Description field
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  style: const TextStyle(fontSize: 14),
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Description of the prompt',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF2F4F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  maxLines: 2,
                  minLines: 1,
                ),
                const SizedBox(height: 10),

                // Category field
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<Category>(
                        value: _selectedCategory,
                        isExpanded: true,
                        hint: const Text(
                          'Select a category',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF8C9AAD)),
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.only(right: 12),
                        onChanged: (Category? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        dropdownColor: Colors.white,
                        items: Category.values.map((Category category) {
                          final name = category.toString().split('.').last;
                          final displayName = name[0].toUpperCase() +
                              name.substring(1).toLowerCase();
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(displayName),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Visibility toggle
                Row(
                  children: [
                    const Text(
                      'Make public',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Transform.scale(
                      scale: 0.8, // Thu nhỏ switch một chút để cân đối hơn
                      child: Switch(
                        value: _isPublic,
                        onChanged: (value) {
                          setState(() {
                            _isPublic = value;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: const Color(0xFF4285F4),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFFCFD8DC),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Prompt field
                Row(
                  children: [
                    const Text(
                      'Prompt',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '*',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Use square brackets [ ] to specify user input.',
                          style: TextStyle(
                            color: Color(0xFF0D47A1),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Prompt text field
                TextFormField(
                  style: const TextStyle(fontSize: 14),
                  controller: _promptController,
                  decoration: InputDecoration(
                    hintText:
                        'e.g: Write an article about [TOPIC], make sure to include these keywords: [KEYWORDS]',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF2F4F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  maxLines: 5,
                  minLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a prompt';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        minimumSize: const Size(100, 40),
                        maximumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _savePrompt,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        minimumSize: const Size(100, 40),
                        maximumSize: const Size(200, 50),
                        backgroundColor: const Color(0xFF4285F4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xFF4285F4),
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.isUpdateMode ? 'Update' : 'Create',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
