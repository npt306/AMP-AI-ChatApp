import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/ai_chat_service.dart';
import '../models/conversation_response.dart';
import 'chat_available_bot_screen.dart';
import '../services/token_manager.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ConversationItem> _historyItems = [];
  List<ConversationItem> _filteredItems = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _nextCursor;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AiChatService.getConversations();

      setState(() {
        _historyItems = response.items;
        _filteredItems = List.from(_historyItems);
        _nextCursor = response.cursor;
        _hasMore = response.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore || _isSearching) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await AiChatService.getConversations(cursor: _nextCursor);

      setState(() {
        _historyItems.addAll(response.items);
        _filteredItems = List.from(_historyItems);
        _nextCursor = response.cursor;
        _hasMore = response.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading more data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  void _navigateToChatScreen(ConversationItem item) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8A70FF)),
          ),
        ),
      );

      // Fetch conversation history
      final history = await AiChatService.getConversationHistory(
        conversationId: item.id,
        limit: 100,
      );

      // Close loading indicator
      if (!mounted) return;
      Navigator.pop(context);

      // Process and format conversation history
      final formattedHistory = <Map<String, dynamic>>[];

      // Process conversation history
      for (var historyItem in history.items) {
        // Handle user message (could be in query or content)
        String? userMessage = historyItem.query ?? historyItem.content;
        if (userMessage != null && userMessage.trim().isNotEmpty) {
          formattedHistory.add({
            'sender': 'user',
            'message': userMessage,
            'timestamp': historyItem.createdAt,
          });
        }

        // Handle AI response
        if (historyItem.answer != null &&
            historyItem.answer!.trim().isNotEmpty) {
          formattedHistory.add({
            'sender': 'ai',
            'message': historyItem.answer!,
            'timestamp': historyItem.createdAt,
          });
        }
      }

      print('Formatted history: $formattedHistory'); // Debug log

      // Navigate to chat screen with history
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatAvailableBotScreen(
            initialMessage: '',
            selectedModelIndex: 0,
            remainingTokens: TokenManager.instance.remainingTokens,
            conversationHistory: formattedHistory,
            modelId:
                history.items.isNotEmpty ? history.items.first.modelId : null,
            conversationId: item.id,
          ),
        ),
      );
    } catch (e) {
      print('Error getting conversation history: $e');
      // Close loading indicator if there's an error
      if (mounted) {
        Navigator.pop(context);
        // Show error message with retry option
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load conversation: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToChatScreen(item);
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Color(0xFF8A70FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _filteredItems = _historyItems
            .where((item) => item.title.toLowerCase().contains(query))
            .toList();
      } else {
        _filteredItems = List.from(_historyItems);
      }
    });
  }

  String _formatTimestamp(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM d, y').format(date);
      }
    } catch (e) {
      print('Error formatting date: $e');
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = _isSearching ? _filteredItems : _historyItems;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All History',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by title',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8A70FF),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // History list
          Expanded(
            child: _isLoading && displayItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : displayItems.isEmpty
                    ? Center(
                        child: Text(
                          _isSearching
                              ? 'No results found'
                              : 'No history found',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: displayItems.length +
                            (_hasMore && !_isSearching ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == displayItems.length) {
                            return _isLoading
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox();
                          }

                          final item = displayItems[index];
                          return _buildHistoryItem(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ConversationItem item) {
    final formattedDate = _formatTimestamp(item.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A70FF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () => _navigateToChatScreen(item),
          ),
        ),
        Divider(color: Colors.grey[200], height: 1),
      ],
    );
  }
}
