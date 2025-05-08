import 'package:flutter/material.dart';
import '../profile_screen.dart';
import 'menu_drawer.dart';
import '../history_screen.dart';
import '../prompt_library_screen/prompt_library_screen.dart';
import '../upgrade_screen.dart';
import '../email_composer_screen/email_composer_screen.dart';
import 'prompt_bottom_sheet.dart';
import '../my_bot_screen.dart';
import '../chat_available_bot_screen.dart';
import '../knowledge_manager_screen.dart';
import '../../services/prompt_service.dart';
import '../../models/prompt.dart';
import '../../services/token_service.dart';
import '../../services/subscription_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  bool _showMediaIcons = false;
  int _selectedModelIndex = 0;
  int _remainingTokens = 0;
  bool _isPro = false;
  String _subscriptionType = 'Basic';
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  String _currentQuery = '';

  // Add this field to track overlay state
  bool _isOverlayShowing = false;
  // Optionally keep a reference to the current overlay entry
  OverlayEntry? _currentOverlayEntry;

  // Add this property to store fetched prompts
  List<Prompt> _prompts = [];
  List<Prompt> _dialogPrompts = []; // Add this for dialog prompts
  bool _isLoadingPrompts = true;
  bool _isLoadingDialogPrompts = false; // Add this for dialog loading state

  final List<Map<String, dynamic>> aiModes = const [
    {
      'image': 'assets/images/claude.png',
      'label': 'Claude 3 Haiku',
      'value': 'claude-3-haiku-20240307',
    },
    {
      'image': 'assets/images/claude.png',
      'label': 'Claude 3.5 Sonnet',
      'value': 'claude-3-5-sonnet-20240620',
    },
    {
      'image': 'assets/images/gemini.png',
      'label': 'Gemini 1.5 Flash',
      'value': 'gemini-1.5-flash-latest',
    },
    {
      'image': 'assets/images/gemini.png',
      'label': 'Gemini 1.5 Pro',
      'value': 'gemini-1.5-pro-latest',
    },
    {
      'image': 'assets/images/gpt.webp',
      'label': 'GPT-4o',
      'value': 'gpt-4o',
    },
    {
      'image': 'assets/images/gpt.webp',
      'label': 'GPT-4o Mini',
      'value': 'gpt-4o-mini',
    },
  ];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      final text = _messageController.text;
      if (text == '/' && _messageFocusNode.hasFocus && !_isOverlayShowing) {
        _showPromptsDialog(context);
      }
    });

    // Fetch prompts when the screen initializes
    _fetchPrompts();

    // Fetch token usage
    _fetchTokenUsage();

    // Check subscription
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    try {
      final usage = await SubscriptionService.getUsage();
      setState(() {
        _subscriptionType = usage['subscriptionType'];
        _isPro = _subscriptionType != 'basic';
      });
    } catch (e) {
      print('Error checking subscription: $e');
    }
  }

  // Add this method to fetch prompts from API
  Future<void> _fetchPrompts() async {
    setState(() {
      _isLoadingPrompts = true;
    });

    try {
      final promptResponse = await PromptService.getPrompts(
        limit: 10, // Initial page size
        offset: 0, // Starting from the beginning
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
      print('Error fetching prompts: $e');
    }
  }

  // Add this method to fetch token usage
  Future<void> _fetchTokenUsage() async {
    try {
      final usage = await TokenService.getTokenUsage();
      setState(() {
        _remainingTokens = usage.availableTokens;
      });
    } catch (e) {
      print('Error fetching token usage: $e');
      // Keep the default value if there's an error
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Choose the AI model that best suits your needs',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Model list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: aiModes.map((mode) {
                      final isSelected = aiModes[_selectedModelIndex] == mode;
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
                              _selectedModelIndex = aiModes.indexOf(mode);
                            });
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Model icon
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
                                // Model info
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
                                // Selected indicator
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
                                            isInChatScreen: false,
                                          ),
                                        ),
                                      );
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

  void _navigateToChatScreen(String message) {
    if (message.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatAvailableBotScreen(
            initialMessage: message.trim(),
            selectedModelIndex: _selectedModelIndex,
            remainingTokens: _remainingTokens,
          ),
        ),
      );
      _messageController.clear();
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
      drawer: MenuDrawer(
        onItemSelected: (index) {
          if (index == 0) {
            // My Bots item index
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyBotScreen()),
            );
          }
          if (index == 1) {
            // Knowledge Base item index
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const KnowledgeManagerScreen()),
            );
          }
          if (index == 2) {
            // History item index
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
          }
          if (index == 3) {
            // Prompt Library item index
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PromptLibraryScreen(
                        selectedModelIndex: _selectedModelIndex,
                        remainingTokens: _remainingTokens,
                      )),
            );
          }
          if (index == 4) {
            // Email Composer item index
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const EmailComposeScreen()),
            );
          }
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          // Upgrade button
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UpgradeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPro
                    ? const Color(0xFFFFB800) // Pro color
                    : const Color.fromARGB(255, 201, 195, 235), // Free color
                foregroundColor: _isPro ? Colors.black87 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(0, 36),
              ),
              icon: Icon(
                _isPro ? FontAwesomeIcons.crown : Icons.auto_awesome,
                size: 16,
                color: _isPro ? Colors.black87 : Colors.white,
              ),
              label: Text(
                _isPro ? 'Pro' : 'Upgrade',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isPro ? Colors.black87 : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Profile avatar
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade100,
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Main content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // AI Assistant Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8A70FF), Color(0xFF2E9BFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 10,
                              child: Container(
                                width: 8,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 10,
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Container(
                                  width: 8,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'How can I help you today?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  const Text(
                    "Don't known what to say? Use a prompt!",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PromptLibraryScreen(
                                  selectedModelIndex: _selectedModelIndex,
                                  remainingTokens: _remainingTokens,
                                )),
                      );
                    },
                    child: Text(
                      "View all",
                      style: TextStyle(
                        color: Color.fromARGB(255, 54, 43, 211),
                      ),
                    ),
                  ),
                ]),
              ),
              _isLoadingPrompts
                  ? const Center(
                      child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ))
                  : Column(
                      children: _prompts.take(3).map((prompt) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              _buildPromptItem(
                                prompt.title,
                                Icons.arrow_forward,
                                onTap: () {
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
                                        description: prompt.description ?? '',
                                        selectedModelIndex: _selectedModelIndex,
                                        remainingTokens: _remainingTokens,
                                        isInChatScreen: false,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (prompt != _prompts.take(3).toList().last)
                                const SizedBox(height: 0),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),

          const SizedBox(height: 16),
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
                // Model selection button
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
                          Icon(
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
                              child: ClipOval(
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
                              aiModes[_selectedModelIndex]['label'],
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
                    const Spacer(), // Add spacer to push history icon to the right
                    // History icon button
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HistoryScreen()),
                          );
                        },
                        child: Icon(
                          Icons.history,
                          size: 24,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
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
                              onPressed: () => _navigateToChatScreen(
                                  _messageController.text),
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

  Widget _buildChipButton({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[800]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptItem(String title, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            Icon(
              icon,
              size: 20,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  // Thêm helper method để lấy mô tả cho từng model
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
}
