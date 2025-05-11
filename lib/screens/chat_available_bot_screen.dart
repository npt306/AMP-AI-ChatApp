import 'package:flutter/material.dart';
import './history_screen.dart';
import 'prompt_library_screen/prompt.dart';
import './homepage_screen/prompt_bottom_sheet.dart';
import '../services/ai_chat_service.dart';
import '../services/prompt_service.dart';
import '../models/prompt.dart' as prompt;
import '../services/bot_service.dart';
import '../models/bot.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatAvailableBotScreen extends StatefulWidget {
  final String initialMessage;
  final int selectedModelIndex;
  final int remainingTokens;
  final bool isCustomBot;
  final String? customBotId;
  final String? customBotName;
  final String? modelId;
  final List<Map<String, dynamic>>? conversationHistory;

  const ChatAvailableBotScreen({
    Key? key,
    required this.initialMessage,
    required this.selectedModelIndex,
    required this.remainingTokens,
    this.isCustomBot = false,
    this.customBotId,
    this.customBotName,
    this.modelId,
    this.conversationHistory,
  }) : super(key: key);

  @override
  State<ChatAvailableBotScreen> createState() => _ChatAvailableBotScreenState();
}

class _ChatAvailableBotScreenState extends State<ChatAvailableBotScreen> {
  bool _showMediaIcons = false;
  bool _isWaitingForResponse = false;
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  int _selectedModelIndex = 0;
  int _remainingTokens = 0;
  List<Map<String, dynamic>> _chatMessages = [];
  String _selectedModelLabel = '';
  String _selectedModelId = '';
  String _selectedModelImage = '';
  String _selectedModelDescription = '';
  String _selectedModelCompany = '';
  bool _isCustomBot = false;
  String? _selectedCustomBotId;
  String? _selectedCustomBotName;
  List<Bot> _customBots = [];
  bool _isLoadingBots = false;

  // Add these properties to track overlay state
  bool _isOverlayShowing = false;
  OverlayEntry? _currentOverlayEntry;
  String _currentQuery = '';
  List<prompt.Prompt> _dialogPrompts = [];
  bool _isLoadingDialogPrompts = false;

  final List<Map<String, dynamic>> aiModes = const [
    {
      'image': 'assets/images/claude.png',
      'label': 'Claude 3 Haiku',
      'value': 'claude-3-haiku-20240307',
      'company': 'Anthropic',
    },
    {
      'image': 'assets/images/claude.png',
      'label': 'Claude 3.5 Sonnet',
      'value': 'claude-3-5-sonnet-20240620',
      'company': 'Anthropic',
    },
    {
      'image': 'assets/images/gemini.png',
      'label': 'Gemini 1.5 Flash',
      'value': 'gemini-1.5-flash-latest',
      'company': 'Google DeepMind',
    },
    {
      'image': 'assets/images/gemini.png',
      'label': 'Gemini 1.5 Pro',
      'value': 'gemini-1.5-pro-latest',
      'company': 'Google DeepMind',
    },
    {
      'image': 'assets/images/gpt.webp',
      'label': 'GPT-4o',
      'value': 'gpt-4o',
      'company': 'OpenAI',
    },
    {
      'image': 'assets/images/gpt.webp',
      'label': 'GPT-4o Mini',
      'value': 'gpt-4o-mini',
      'company': 'OpenAI',
    },
  ];

  @override
  void initState() {
    super.initState();
    print('ChatAvailableBotScreen initState called');
    _selectedModelIndex = widget.selectedModelIndex;
    _remainingTokens = widget.remainingTokens;
    _isCustomBot = widget.isCustomBot;
    _selectedCustomBotId = widget.customBotId;
    _selectedCustomBotName = widget.customBotName;

    // Initialize chat messages with conversation history if available
    if (widget.conversationHistory != null) {
      _chatMessages = List.from(widget.conversationHistory!);
    }

    if (widget.isCustomBot) {
      _selectedModelLabel = widget.customBotName ?? 'Custom Bot';
      _selectedModelId = widget.customBotId ?? '';
      _selectedModelImage = ''; // Remove image path since we'll use icon
      _selectedModelDescription = 'Custom AI Assistant';
      _selectedModelCompany = 'Custom';
    } else {
      _selectedModelLabel = aiModes[_selectedModelIndex]['label'];
      _selectedModelImage = aiModes[_selectedModelIndex]['image'];
      _selectedModelId =
          widget.modelId ?? aiModes[_selectedModelIndex]['value'];
      _selectedModelDescription = _getModelDescription(_selectedModelLabel);
      _selectedModelCompany = aiModes[_selectedModelIndex]['company'];
    }

    _messageController.addListener(() {
      final text = _messageController.text;
      if (text == '/' && _messageFocusNode.hasFocus && !_isOverlayShowing) {
        _showPromptsDialog(context);
      }
    });

    // Call appropriate API when the page loads
    if (widget.initialMessage.isNotEmpty) {
      _chatMessages.add({
        'sender': 'user',
        'message': widget.initialMessage,
      });

      if (widget.isCustomBot) {
        AiChatService.chatWithBot(
          messages: [
            {
              'role': 'user',
              'content': widget.initialMessage,
              'files': [],
              'assistant': {
                'id': widget.customBotId,
                'model': 'dify',
                'name': widget.customBotName ?? 'Custom Bot',
              },
            }
          ],
          modelId: widget.customBotId ?? '',
          modelName: widget.customBotName ?? 'Custom Bot',
        ).then((response) {
          setState(() {
            _chatMessages.add({
              'sender': 'ai',
              'message': response.message,
            });
            _remainingTokens = response.remainingUsage;
          });
        }).catchError((error) {
          print('Error chatting with bot: $error');
        });
      } else {
        AiChatService.sendMessage(
          content: widget.initialMessage,
          modelId: _selectedModelId,
          modelName: _selectedModelLabel,
        ).then((response) {
          setState(() {
            _chatMessages.add({
              'sender': 'ai',
              'message': response.message,
            });
            _remainingTokens = response.remainingUsage;
          });
        }).catchError((error) {
          print('Error sending message: $error');
        });
      }

      _fetchPrompts();
    }

    // Fetch custom bots
    _fetchCustomBots();
  }

  // Add this property to store fetched prompts
  List<prompt.Prompt> _prompts = [];
  bool _isLoadingPrompts = true;
  // Add this method to fetch prompts from API
  Future<void> _fetchPrompts() async {
    setState(() {
      _isLoadingPrompts = true;
    });

    try {
      final promptResponse = await PromptService.getPrompts(
        limit: 10,
        offset: 0,
        isPublic: true,
      );

      setState(() {
        _prompts = promptResponse.items;
        _isLoadingPrompts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPrompts = false;
      });
      // You might want to add error handling here
      print('Error fetching prompts: $e');
    }
  }

  // Add this method to fetch prompts with query for dialog
  Future<void> _fetchDialogPrompts(String query) async {
    _isLoadingDialogPrompts = true;
    if (_currentOverlayEntry != null) {
      _currentOverlayEntry!.markNeedsBuild();
    }

    try {
      final promptResponse = await PromptService.getPrompts(
        query: query,
        limit: 10,
        offset: 0,
        isPublic: true,
      );

      _dialogPrompts = promptResponse.items;
    } catch (e) {
      print('Error fetching dialog prompts: $e');
    } finally {
      _isLoadingDialogPrompts = false;
      if (_currentOverlayEntry != null) {
        _currentOverlayEntry!.markNeedsBuild();
      }
    }
  }

  Map<String, dynamic> formatMessage({
    required String sender,
    required String message,
    required String modelId,
    required String modelName,
  }) {
    return {
      'role': sender == 'user' ? 'user' : 'model',
      'content': message,
      'files': [],
      'assistant': {
        'id': modelId,
        'model': 'dify',
        'name': modelName,
      },
    };
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isWaitingForResponse = true;
      _chatMessages.add({
        'sender': 'user',
        'message': message,
      });
      _messageController.clear();
    });

    try {
      if (widget.isCustomBot) {
        final response = await AiChatService.chatWithBot(
          messages: [
            {
              'role': 'user',
              'content': message,
              'files': [],
              'assistant': {
                'id': widget.customBotId,
                'model': 'dify',
                'name': widget.customBotName ?? 'Custom Bot',
              },
            }
          ],
          modelId: widget.customBotId ?? '',
          modelName: widget.customBotName ?? 'Custom Bot',
        );

        setState(() {
          _chatMessages.add({
            'sender': 'ai',
            'message': response.message,
          });
          _remainingTokens = response.remainingUsage;
        });
      } else {
        final response = await AiChatService.sendMessage(
          content: message,
          modelId: _selectedModelId,
          modelName: _selectedModelLabel,
        );

        setState(() {
          _chatMessages.add({
            'sender': 'ai',
            'message': response.message,
          });
          _remainingTokens = response.remainingUsage;
        });
      }
    } catch (e) {
      print('Error sending message: $e');
      setState(() {
        _chatMessages.add({
          'sender': 'ai',
          'message':
              'Sorry, there was an error processing your message. Please try again.',
        });
      });
    } finally {
      setState(() {
        _isWaitingForResponse = false;
      });
    }
  }

  void _chatWithBot() {
    if (_messageController.text.trim().isNotEmpty) {
      final userMessage = _messageController.text.trim();

      setState(() {
        _chatMessages.add({
          'sender': 'user',
          'message': userMessage,
        });
        _isWaitingForResponse = true;
      });

      final formattedMessages = _chatMessages.map((msg) {
        return formatMessage(
          sender: msg['sender'],
          message: msg['message'],
          modelId: _selectedModelId,
          modelName: _selectedModelLabel,
        );
      }).toList();

      AiChatService.chatWithBot(
        messages: formattedMessages,
        modelId: _selectedModelId,
        modelName: _selectedModelLabel,
      ).then((response) {
        setState(() {
          _chatMessages.add({
            'sender': 'ai',
            'message': response.message,
          });
          _remainingTokens = response.remainingUsage;
          _isWaitingForResponse = false;
        });
      }).catchError((error) {
        setState(() {
          _isWaitingForResponse = false;
        });
        print('Error chatting with bot: $error');
      });

      _messageController.clear();
    }
  }

  String _getModelDescription(String modelName) {
    switch (modelName) {
      case 'Claude 3 Haiku':
        return 'Fast and efficient model for quick responses';
      case 'Claude 3.5 Sonnet':
        return 'Advanced model for complex tasks and analysis';
      case 'Gemini 1.5 Flash':
        return 'Quick and efficient model for everyday tasks';
      case 'Gemini 1.5 Pro':
        return 'Powerful model for professional use';
      case 'GPT-4o':
        return 'Most capable model for general tasks';
      case 'GPT-4o Mini':
        return 'Lightweight version for faster responses';
      default:
        return '';
    }
  }

  void _updateModelSelection(int index) {
    setState(() {
      _selectedModelIndex = index;
      _selectedModelLabel = aiModes[index]['label'];
      _selectedModelImage = aiModes[index]['image'];
      _selectedModelId = aiModes[index]['value'];
      _selectedModelDescription = _getModelDescription(_selectedModelLabel);
      _selectedModelCompany = aiModes[index]['company'];
      // Clear chat history
      _chatMessages.clear();
      // Reset custom bot state
      _isCustomBot = false;
      _selectedCustomBotId = null;
      _selectedCustomBotName = null;
    });
  }

  void _showAllModelsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Select AI Model',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Subtitle and description
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Choose the AI model that best suits your needs',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Default Models Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Default Models',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...aiModes.map((mode) {
                        final isSelected = !_isCustomBot &&
                            aiModes[_selectedModelIndex] == mode;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF8A70FF)
                                  : Colors.grey[200]!,
                              width: 1.5,
                            ),
                            color: isSelected
                                ? const Color(0xFFF5F3FF)
                                : Colors.white,
                          ),
                          child: InkWell(
                            onTap: () {
                              _updateModelSelection(aiModes.indexOf(mode));
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: Image.asset(
                                      mode['image'],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mode['label'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _getModelDescription(mode['label']),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF8A70FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                // Custom Bots Section
                if (_customBots.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Custom Bots',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._customBots.map((bot) {
                          final isSelected =
                              _isCustomBot && _selectedCustomBotId == bot.id;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF8A70FF)
                                    : Colors.grey[200]!,
                                width: 1.5,
                              ),
                              color: isSelected
                                  ? const Color(0xFFF5F3FF)
                                  : Colors.white,
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isCustomBot = true;
                                  _selectedCustomBotId = bot.id;
                                  _selectedCustomBotName = bot.assistantName;
                                  _selectedModelLabel =
                                      bot.assistantName ?? 'Custom Bot';
                                  _selectedModelId = bot.id;
                                  _selectedModelImage = '';
                                  _selectedModelDescription =
                                      'Custom AI Assistant';
                                  _selectedModelCompany = 'Custom';
                                  // Clear chat history when switching to custom bot
                                  _chatMessages.clear();
                                });
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(
                                        Icons.smart_toy,
                                        color: Color(0xFF8A70FF),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bot.assistantName ?? 'Custom Bot',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            bot.description ??
                                                'Custom AI Assistant',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF8A70FF),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],

                // Loading indicator for custom bots
                if (_isLoadingBots)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPromptsDialog(BuildContext context) {
    // Return early if an overlay is already showing
    if (_isOverlayShowing) return;

    _isOverlayShowing = true;
    _currentQuery = ''; // Reset query when opening dialog
    _dialogPrompts = []; // Reset dialog prompts

    // Get the render box of the text field to calculate position
    final RenderBox inputBox =
        _messageFocusNode.context!.findRenderObject() as RenderBox;
    final offset = inputBox.localToGlobal(Offset.zero);

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // Create a scroll controller to detect when we reach the bottom
    final ScrollController scrollController = ScrollController();

    // Track pagination state
    int currentOffset = 0;
    const int pageSize = 10;
    bool isLoadingMore = false;
    bool hasMoreData = true;

    // Pre-declare function variables to avoid circular references
    late void Function() textListener;
    late void Function() slashListener;

    // Function to close dialog and clear the "/" character
    void closeDialog() {
      if (_messageController.text.startsWith('/')) {
        _messageController.clear();
      }

      // Only remove if it hasn't been removed already
      if (_isOverlayShowing) {
        overlayEntry.remove();
        scrollController.dispose();
        _messageFocusNode.removeListener(textListener);
        _messageController.removeListener(slashListener);

        // Update tracking variable
        _isOverlayShowing = false;
        _currentOverlayEntry = null;
      }
    }

    // Define the listener functions after pre-declaration
    textListener = () {
      if (!_messageFocusNode.hasFocus) {
        if (_messageController.text.startsWith('/')) {
          _messageController.clear();
        }
        overlayEntry.remove();
        scrollController.dispose();
        _messageFocusNode.removeListener(textListener);
        _messageController.removeListener(slashListener);
        _isOverlayShowing = false;
        _currentOverlayEntry = null;
      }
    };

    slashListener = () {
      final text = _messageController.text;
      if (text.isEmpty || !text.startsWith('/')) {
        overlayEntry.remove();
        scrollController.dispose();
        _messageFocusNode.removeListener(textListener);
        _messageController.removeListener(slashListener);
        _isOverlayShowing = false;
        _currentOverlayEntry = null;
      } else {
        // Extract query from text after '/'
        final newQuery = text.substring(1).trim();
        if (newQuery != _currentQuery) {
          _currentQuery = newQuery;
          // Reset pagination state
          currentOffset = 0;
          hasMoreData = true;
          // Fetch prompts with new query (empty string for default prompts)
          _fetchDialogPrompts(_currentQuery);
        }
      }
    };

    // Function to load more prompts
    Future<void> loadMorePrompts() async {
      if (isLoadingMore || !hasMoreData) return;

      isLoadingMore = true;
      try {
        currentOffset += pageSize;
        final promptResponse = await PromptService.getPrompts(
          query: _currentQuery,
          limit: pageSize,
          offset: currentOffset,
          isPublic: true,
        );

        if (promptResponse.items.isEmpty) {
          hasMoreData = false;
        } else {
          _dialogPrompts.addAll(promptResponse.items);
        }

        // Force rebuild of overlay
        overlayEntry.markNeedsBuild();
      } catch (e) {
        print('Error loading more prompts: $e');
      } finally {
        isLoadingMore = false;
      }
    }

    // Add scroll listener
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent -
                  100 && // 100px before the end
          !isLoadingMore &&
          hasMoreData) {
        loadMorePrompts();
      }
    });

    // Initial fetch of prompts when dialog opens
    _fetchDialogPrompts('');

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible full-screen GestureDetector to handle outside taps
          Positioned.fill(
            child: GestureDetector(
              onTap: closeDialog,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          // The actual prompt dialog
          Positioned(
            bottom: MediaQuery.of(context).size.height - offset.dy + 20,
            left: 16,
            right: 100,
            child: GestureDetector(
              onTap: () {},
              child: Material(
                elevation: 0,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      _isLoadingDialogPrompts
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                shrinkWrap: true,
                                itemCount: _dialogPrompts.length +
                                    (hasMoreData ? 1 : 0),
                                itemBuilder: (context, index) {
                                  // Show loading indicator at the end
                                  if (index == _dialogPrompts.length) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.0),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      ),
                                    );
                                  }

                                  final prompt = _dialogPrompts[index];
                                  return ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 4,
                                    ),
                                    title: Text(
                                      prompt.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    onTap: () {
                                      // Close the prompts dialog first
                                      closeDialog();

                                      // Show the prompt bottom sheet
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom,
                                          ),
                                          child: PromptBottomSheet(
                                            prompt: prompt.content,
                                            title: prompt.title,
                                            description:
                                                prompt.description ?? '',
                                            selectedModelIndex:
                                                _selectedModelIndex,
                                            remainingTokens: _remainingTokens,
                                            isInChatScreen: true,
                                            isCustomBot: _isCustomBot,
                                            customBotId: _isCustomBot
                                                ? _selectedCustomBotId
                                                : null,
                                            customBotName: _isCustomBot
                                                ? _selectedCustomBotName
                                                : null,
                                            modelId: _isCustomBot
                                                ? _selectedCustomBotId
                                                : _selectedModelId,
                                          ),
                                        ),
                                      ).then((result) {
                                        if (result != null) {
                                          // Add the prompt result to chat messages
                                          setState(() {
                                            _chatMessages.add({
                                              'sender': 'user',
                                              'message': result,
                                            });
                                            _isWaitingForResponse = true;
                                          });

                                          // Send the message to the appropriate API
                                          if (_isCustomBot) {
                                            AiChatService.chatWithBot(
                                              messages: [
                                                {
                                                  'role': 'user',
                                                  'content': result,
                                                  'files': [],
                                                  'assistant': {
                                                    'id': _selectedCustomBotId,
                                                    'model': 'dify',
                                                    'name':
                                                        _selectedCustomBotName ??
                                                            'Custom Bot',
                                                  },
                                                }
                                              ],
                                              modelId:
                                                  _selectedCustomBotId ?? '',
                                              modelName:
                                                  _selectedCustomBotName ??
                                                      'Custom Bot',
                                            ).then((response) {
                                              setState(() {
                                                _chatMessages.add({
                                                  'sender': 'ai',
                                                  'message': response.message,
                                                });
                                                _remainingTokens =
                                                    response.remainingUsage;
                                                _isWaitingForResponse = false;
                                              });
                                            }).catchError((error) {
                                              setState(() {
                                                _isWaitingForResponse = false;
                                              });
                                              print(
                                                  'Error chatting with bot: $error');
                                            });
                                          } else {
                                            AiChatService.sendMessage(
                                              content: result,
                                              modelId: _selectedModelId,
                                              modelName: _selectedModelLabel,
                                            ).then((response) {
                                              setState(() {
                                                _chatMessages.add({
                                                  'sender': 'ai',
                                                  'message': response.message,
                                                });
                                                _remainingTokens =
                                                    response.remainingUsage;
                                                _isWaitingForResponse = false;
                                              });
                                            }).catchError((error) {
                                              setState(() {
                                                _isWaitingForResponse = false;
                                              });
                                              print(
                                                  'Error sending message: $error');
                                            });
                                          }
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Store a reference to the current overlay entry
    _currentOverlayEntry = overlayEntry;

    overlay.insert(overlayEntry);
    _messageFocusNode.addListener(textListener);
    _messageController.addListener(slashListener);
  }

  // Add this method to fetch custom bots
  Future<void> _fetchCustomBots() async {
    setState(() {
      _isLoadingBots = true;
    });

    try {
      final bots = await BotService.getBots();
      setState(() {
        _customBots = bots;
        _isLoadingBots = false;
      });
    } catch (e) {
      print('Error fetching custom bots: $e');
      setState(() {
        _isLoadingBots = false;
      });
    }
  }

  @override
  void dispose() {
    // If there's an active overlay when disposing, remove it
    if (_isOverlayShowing && _currentOverlayEntry != null) {
      _currentOverlayEntry!.remove();
      _isOverlayShowing = false;
    }

    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: _isCustomBot
                  ? const Icon(
                      Icons.smart_toy,
                      color: Color(0xFF8A70FF),
                      size: 24,
                    )
                  : Image.asset(
                      _selectedModelImage,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(width: 8),
            Text(
              _selectedModelLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _isCustomBot
                          ? const Icon(
                              Icons.smart_toy,
                              color: Color(0xFF8A70FF),
                              size: 30,
                            )
                          : Image.asset(
                              _selectedModelImage,
                              width: 30,
                              height: 30,
                              fit: BoxFit.contain,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedModelLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            children: [
                              const TextSpan(text: 'By '),
                              TextSpan(
                                text: '@${_selectedModelCompany.toString()}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedModelDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _chatMessages.length + (_isWaitingForResponse ? 1 : 0),
              itemBuilder: (context, index) {
                // Show typing indicator at the end if waiting for response
                if (_isWaitingForResponse && index == _chatMessages.length) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildTypingDot(0),
                            _buildTypingDot(1),
                            _buildTypingDot(2),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                final chat = _chatMessages[index];
                final isUser = chat['sender'] == 'user';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: _isCustomBot
                              ? const Icon(
                                  Icons.smart_toy,
                                  color: Color(0xFF8A70FF),
                                  size: 20,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    _selectedModelImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ],
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFF8A70FF)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isUser ? 20 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isUser) ...[
                                Text(
                                  _selectedModelLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                chat['message']!,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isUser ? Colors.white : Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Model selection row
                Row(
                  children: [
                    // Token counter
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt,
                            size: 20,
                            color: const Color.fromARGB(255, 47, 0, 255),
                          ),
                          const SizedBox(width: 1),
                          Text(
                            _remainingTokens.toString(),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Model selector
                    GestureDetector(
                      onTap: () => _showAllModelsDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey[100],
                              child: _isCustomBot
                                  ? const Icon(
                                      Icons.smart_toy,
                                      color: Color(0xFF8A70FF),
                                      size: 16,
                                    )
                                  : ClipOval(
                                      child: Image.asset(
                                        aiModes[_selectedModelIndex]['image'],
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isCustomBot
                                  ? _selectedCustomBotName ?? 'Custom Bot'
                                  : aiModes[_selectedModelIndex]['label'],
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey[800],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // History icon button
                    Row(
                      children: [
                        // Nút History
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.history,
                              size: 24,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),

                        // Nút Làm mới
                        GestureDetector(
                          onTap: () async {
                            // Clear chat history
                            setState(() {
                              _chatMessages.clear();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.refresh,
                              size: 24,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                // Message input row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: _showMediaIcons ? 96 : 48,
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  // Add button that toggles visibility
                                  AnimatedOpacity(
                                    opacity: _showMediaIcons ? 0.0 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: IconButton(
                                      icon: Icon(Icons.add_circle_outline,
                                          color: Colors.grey[600]),
                                      onPressed: () {
                                        setState(() {
                                          _showMediaIcons = true;
                                        });
                                      },
                                    ),
                                  ),
                                  // Sliding media icons
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: _showMediaIcons ? 96 : 0,
                                    curve: Curves.easeInOut,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_showMediaIcons) ...[
                                            IconButton(
                                              icon: Icon(Icons.camera_alt,
                                                  color: Colors.grey[600]),
                                              onPressed: () {
                                                // Handle camera
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.photo_library,
                                                  color: Colors.grey[600]),
                                              onPressed: () {
                                                // Handle gallery
                                              },
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                focusNode: _messageFocusNode,
                                decoration: InputDecoration(
                                  hintText: 'Message',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                onTap: () {
                                  if (_showMediaIcons) {
                                    setState(() {
                                      _showMediaIcons = false;
                                    });
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send, color: Colors.grey[600]),
                              onPressed: _sendMessage,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Add this method for typing animation
  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      curve:
          Interval(index * 0.2, (index * 0.2) + 0.5, curve: Curves.easeInOut),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -4 * value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
