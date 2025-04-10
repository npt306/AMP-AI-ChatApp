import 'package:flutter/material.dart';
import '../../models/prompt.dart';
import 'prompt_card.dart';
import 'create_prompt_dialog.dart';
import 'delete_prompt_dialog.dart';
import '../../services/prompt_service.dart';
import '../../models/prompt_response.dart';

class PromptLibraryScreen extends StatefulWidget {
  const PromptLibraryScreen({
    super.key,
  });

  @override
  State<PromptLibraryScreen> createState() => _PromptLibraryScreenState();
}

class _PromptLibraryScreenState extends State<PromptLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isPublicTab = true;
  Category? _selectedCategory;
  List<Prompt> _prompts = [];
  bool _isExpanded = false;
  bool _isLoading = false;
  bool _hasNext = false;
  int _offset = 0;
  final int _limit = 20;
  bool _isFavoriteSelected = false;

  @override
  void initState() {
    super.initState();
    _loadPrompts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Cập nhật phương thức _loadPrompts
  Future<void> _loadPrompts({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _offset = 0;
      });
    }

    try {
      final response = await PromptService.getPrompts(
        query: _searchController.text.isEmpty ? null : _searchController.text,
        offset: _offset,
        limit: _limit,
        isPublic: false,
        category: _selectedCategory,
        isFavorite: _isFavoriteSelected ? true : false, // Thêm bộ lọc yêu thích
      );

      setState(() {
        if (loadMore) {
          _prompts.addAll(response.items);
        } else {
          _prompts = response.items;
        }
        _hasNext = response.hasNext;
        _offset += response.items.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading prompts: $e')),
        );
      }
    }
  }

  void _onSearchChanged() {
    _loadPrompts();
  }

  // Cập nhật phương thức toggleFavorite

  void _toggleFavorite(String promptId) async {
    try {
      // Tìm prompt trong danh sách
      final promptIndex = _prompts.indexWhere((p) => p.id == promptId);
      if (promptIndex == -1) return;

      // Lấy trạng thái hiện tại và đảo ngược nó
      final currentPrompt = _prompts[promptIndex];
      final newIsFavorite = !currentPrompt.isFavorite;

      // Cập nhật UI trước để phản hồi ngay lập tức
      setState(() {
        _prompts[promptIndex] = Prompt(
          id: currentPrompt.id,
          createdAt: currentPrompt.createdAt,
          updatedAt: currentPrompt.updatedAt,
          category: currentPrompt.category,
          content: currentPrompt.content,
          description: currentPrompt.description,
          isPublic: currentPrompt.isPublic,
          language: currentPrompt.language,
          title: currentPrompt.title,
          userId: currentPrompt.userId,
          userName: currentPrompt.userName,
          isFavorite: newIsFavorite,
        );
      });

      // Gọi API thích hợp dựa trên trạng thái mới
      if (newIsFavorite) {
        await PromptService.addToFavorite(promptId);
      } else {
        await PromptService.removeFromFavorite(promptId);
      }

      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newIsFavorite
                ? 'Added to favorites'
                : 'Removed from favorites'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Nếu API thất bại, khôi phục trạng thái
      setState(() {
        final promptIndex = _prompts.indexWhere((p) => p.id == promptId);
        if (promptIndex != -1) {
          final currentPrompt = _prompts[promptIndex];
          _prompts[promptIndex] = Prompt(
            id: currentPrompt.id,
            createdAt: currentPrompt.createdAt,
            updatedAt: currentPrompt.updatedAt,
            category: currentPrompt.category,
            content: currentPrompt.content,
            description: currentPrompt.description,
            isPublic: currentPrompt.isPublic,
            language: currentPrompt.language,
            title: currentPrompt.title,
            userId: currentPrompt.userId,
            userName: currentPrompt.userName,
            isFavorite: !currentPrompt.isFavorite, // Đảo ngược lại
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Category.values;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Prompt Library',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4),
              borderRadius: BorderRadius.circular(12),
            ),
            height: 30,
            width: 30,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              onPressed: () => {
                showDialog(
                  context: context,
                  builder: (context) => CreatePromptDialog(
                    onSave: (name, promptText) {
                      _loadPrompts();
                      // Hiển thị thông báo thành công
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Prompt created successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                )
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Tab buttons for Public/My Prompts
                Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        'Public Prompts',
                        _isPublicTab,
                        () => setState(() {
                          _isPublicTab = true;
                          _loadPrompts();
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
                          _loadPrompts();
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
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
                        color: _isFavoriteSelected
                            ? const Color(
                                0xFFFFF8E1) // Màu nền vàng nhạt khi được chọn
                            : const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isFavoriteSelected ? Icons.star : Icons.star_border,
                          color: _isFavoriteSelected
                              ? const Color(
                                  0xFFFFB300) // Màu vàng đậm cho icon khi được chọn
                              : const Color(0xFF8C9AAD),
                          size: 26,
                        ),
                        onPressed: () {
                          setState(() {
                            _isFavoriteSelected = !_isFavoriteSelected;
                            _loadPrompts();
                          });
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
                              children: [
                                // All category chip
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = null;
                                      _loadPrompts();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _selectedCategory == null
                                          ? const Color(0xFF0078D4)
                                          : const Color(0xFFF2F4F7),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'All',
                                      style: TextStyle(
                                        color: _selectedCategory == null
                                            ? Colors.white
                                            : const Color(0xFF4A5568),
                                        fontWeight: _selectedCategory == null
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                // Other category chips
                                ...categories.map((category) {
                                  final isSelected =
                                      _selectedCategory == category;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = category;
                                        _loadPrompts();
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
                                        category
                                                .toString()
                                                .split('.')
                                                .last[0]
                                                .toUpperCase() +
                                            category
                                                .toString()
                                                .split('.')
                                                .last
                                                .substring(1)
                                                .toLowerCase(),
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
                              ],
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
                  child: _isLoading && _prompts.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _prompts.isEmpty
                          ? const Center(
                              child: Text(
                                'No prompts found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF8C9AAD),
                                ),
                              ),
                            )
                          : NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (!_isLoading &&
                                    _hasNext &&
                                    scrollInfo.metrics.pixels ==
                                        scrollInfo.metrics.maxScrollExtent) {
                                  _loadPrompts(loadMore: true);
                                }
                                return true;
                              },
                              child: ListView.separated(
                                itemCount: _prompts.length + (_hasNext ? 1 : 0),
                                separatorBuilder: (context, index) =>
                                    const Divider(),
                                itemBuilder: (context, index) {
                                  if (index == _prompts.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  final prompt = _prompts[index];
                                  return PromptCard(
                                    prompt: prompt,
                                    isPublicPrompt: _isPublicTab,
                                    onToggleFavorite: () =>
                                        _toggleFavorite(prompt.id),
                                    onTap: () {},
                                    onEdit: _isPublicTab
                                        ? null
                                        : () {
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  CreatePromptDialog(
                                                isUpdateMode: true,
                                                initialName: prompt.title,
                                                initialPrompt: prompt.content,
                                                initialDescription:
                                                    prompt.description,
                                                promptId: prompt.id,
                                                category: prompt.category,
                                                isPublic: prompt.isPublic,
                                                onSave: (name, promptText) {
                                                  _loadPrompts();
                                                  // Hiển thị thông báo thành công
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Prompt updated successfully!'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                    onDelete: _isPublicTab
                                        ? null
                                        : () {
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  DeletePromptDialog(
                                                promptId: prompt.id,
                                                promptName: prompt.title,
                                                onDelete: () {
                                                  _loadPrompts();
                                                },
                                              ),
                                            );
                                          },
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
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
