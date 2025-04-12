import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/ai_chat_service.dart';
import '../models/conversation_response.dart';
import 'chat_available_bot_screen.dart';

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

  void _navigateToChatScreen(ConversationItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatAvailableBotScreen(
          initialMessage: "Tiếp tục cuộc trò chuyện: ${item.title}",
          selectedModelIndex: 0, // Sử dụng model mặc định
          remainingTokens: 100, // Giá trị mặc định
        ),
      ),
    );
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

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
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
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            title: Text(
              item.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Row(children: [
                  Expanded(
                    child: Text(
                      "ID: ${item.id}",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
                const SizedBox(height: 2),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFF8A70FF),
                      child: const Icon(
                        Icons.smart_toy,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Assistant',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () => {_navigateToChatScreen(item)},
          ),
        ),
        Divider(color: Colors.grey[200]),
      ],
    );
  }
}
