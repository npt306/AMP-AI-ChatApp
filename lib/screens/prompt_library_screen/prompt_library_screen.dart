import 'package:flutter/material.dart';
import 'prompt.dart';
import 'prompt_card.dart';
import 'create_prompt_dialog.dart';

class PromptLibraryScreen extends StatefulWidget {
  const PromptLibraryScreen({super.key});

  @override
  State<PromptLibraryScreen> createState() => _PromptLibraryScreenState();
}

class _PromptLibraryScreenState extends State<PromptLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isPublicTab = true;
  String _selectedCategory = 'All';
  List<Prompt> _filteredPrompts = [];
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _filterPrompts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterPrompts();
  }

  void _filterPrompts() {
    setState(() {
      _filteredPrompts = samplePrompts.where((prompt) {
        // Filter by public/private
        if (_isPublicTab && !prompt.isPublic) return false;
        if (!_isPublicTab && prompt.isPublic) return false;

        // Filter by category
        if (_selectedCategory != 'All' &&
            !prompt.categories.contains(_selectedCategory)) {
          return false;
        }

        // Filter by search text
        if (_searchController.text.isNotEmpty) {
          final searchLower = _searchController.text.toLowerCase();
          return prompt.title.toLowerCase().contains(searchLower) ||
              prompt.description.toLowerCase().contains(searchLower);
        }

        return true;
      }).toList();
    });
  }

  void _toggleFavorite(String promptId) {
    setState(() {
      final promptIndex = samplePrompts.indexWhere((p) => p.id == promptId);
      if (promptIndex != -1) {
        samplePrompts[promptIndex].isFavorite =
            !samplePrompts[promptIndex].isFavorite;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = getAllCategories();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title, add button, and close button
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Prompt Library',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2540),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF4285F4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          height: 30,
                          width: 30,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.add,
                                color: Colors.white, size: 20),
                            onPressed: () => {
                              showDialog(
                                context: context,
                                builder: (context) => CreatePromptDialog(
                                  onSave: (name, promptText) {
                                    // Here you would typically add the new prompt to your list

                                    // Refresh the list
                                    _filterPrompts();
                                  },
                                ),
                              )
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.close, size: 28),
                          onPressed: () {
                            // Close screen functionality
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tab buttons for Public/My Prompts
              Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      'Public Prompts',
                      _isPublicTab,
                      () => setState(() {
                        _isPublicTab = true;
                        _filterPrompts();
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTabButton(
                      'My Prompts',
                      !_isPublicTab,
                      () => setState(() {
                        _isPublicTab = false;
                        _filterPrompts();
                      }),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(color: Color(0xFF8C9AAD)),
                          prefixIcon:
                              Icon(Icons.search, color: Color(0xFF8C9AAD)),
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.star_border,
                          color: Color(0xFF8C9AAD)),
                      onPressed: () {
                        // Show favorites functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Show favorites')),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category chips
              if (_isPublicTab)
                SizedBox(
                  height: _isExpanded ? 108 : 36,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: categories.map((category) {
                              final isSelected = _selectedCategory == category;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                    _filterPrompts();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF0078D4)
                                        : const Color(0xFFF2F4F7),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF4A5568),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Container(
                          height: 32,
                          width: 32,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: const Color(0xFF4A5568),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: _isPublicTab ? 8 : 0),

              // Prompt list
              Expanded(
                child: _filteredPrompts.isEmpty
                    ? const Center(
                        child: Text(
                          'No prompts found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8C9AAD),
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filteredPrompts.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final prompt = _filteredPrompts[index];
                          return PromptCard(
                            prompt: prompt,
                            isPublicPrompt: _isPublicTab,
                            onToggleFavorite: () => _toggleFavorite(prompt.id),
                            onTap: () {},
                            onEdit: _isPublicTab ? null : () {
                              showDialog(
                                context: context,
                                builder: (context) => CreatePromptDialog(
                                  isUpdateMode: true,
                                  initialName: prompt.title,
                                  initialPrompt: prompt.content,
                                  onSave: (name, promptText) {
                                    setState(() {
                                      final promptIndex = samplePrompts.indexWhere((p) => p.id == prompt.id);
                                      if (promptIndex != -1) {
                                        samplePrompts[promptIndex] = Prompt(
                                          id: prompt.id,
                                          title: name,
                                          description: prompt.description,
                                          categories: prompt.categories,
                                          isPublic: prompt.isPublic,
                                          content: promptText,
                                          usageCount: prompt.usageCount,
                                          isFavorite: prompt.isFavorite,
                                        );
                                      }
                                    });
                                    _filterPrompts();
                                  },
                                ),
                              );
                            },
                            onDelete: _isPublicTab ? null : () {},
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0078D4) : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4A5568),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
