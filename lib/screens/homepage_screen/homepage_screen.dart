import 'package:flutter/material.dart';
import '../profile_screen.dart';
import 'menu_drawer.dart';
import '../history_screen.dart';
import '../prompt_library_screen/prompt_library_screen.dart';
import '../upgrade_screen.dart';
import '../email_composer_screen/email_composer_screen.dart';
import '../prompt_library_screen/prompt.dart';
import 'prompt_bottom_sheet.dart';
import '../my_bot_screen.dart';
import '../chat_available_bot_screen.dart';
import '../knowledge_manager_screen.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  bool _showMediaIcons = false;
  int _selectedModelIndex = 0;
  final int _remainingTokens = 100; // Add remaining tokens count
  final bool _isPro = true; // Add pro status check
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final List<Map<String, dynamic>> aiModes = const [
    {
      'image': 'assets/images/deepseek.png',
      'label': 'DeepSeek V3',
    },
    {
      'image': 'assets/images/gpt.webp',
      'label': 'GPT-4',
    },
    {
      'image': 'assets/images/claude.png',
      'label': 'Claude 3',
    },
    {
      'image': 'assets/images/llama.png',
      'label': 'Llama 3',
    },
  ];

  void _showAllModelsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với title và close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select AI Model',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose the AI model that best suits your needs',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Model list
                ...aiModes.map((mode) {
                  final isSelected = aiModes[_selectedModelIndex] == mode;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF8A70FF)
                            : Colors.grey.shade200,
                        width: 2,
                      ),
                      color:
                          isSelected ? const Color(0xFFF5F3FF) : Colors.white,
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
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Model icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                mode['image'],
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Model info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mode['label'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getModelDescription(mode['label']),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Selected indicator
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8A70FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
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
        );
      },
    );
  }

  void _showPromptsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Material(
            color: Colors.transparent,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: samplePrompts.length,
              itemBuilder: (context, index) {
                final prompt = samplePrompts[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    prompt.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    prompt.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: PromptBottomSheet(
                          prompt: prompt.content,
                          title: prompt.title,
                          description: prompt.description,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      final text = _messageController.text;
      if (text == '/') {
        _showPromptsDialog(context);
      }
    });
  }

  @override
  void dispose() {
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
              MaterialPageRoute(builder: (context) => const KnowledgeManagerScreen()),
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
                  builder: (context) => const PromptLibraryScreen()),
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
                backgroundColor: const Color.fromARGB(255, 201, 195, 235),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(0, 36),
              ),
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: Text(
                _isPro ? 'Pro' : 'Upgrade',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                            builder: (context) => const PromptLibraryScreen()),
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
              ...samplePrompts.take(3).map((prompt) {
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
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: PromptBottomSheet(
                                prompt: prompt.content,
                                title: prompt.title,
                                description: prompt.description,
                              ),
                            ),
                          );
                        },
                      ),
                      if (prompt != samplePrompts.take(3).last)
                        const SizedBox(height: 0),
                    ],
                  ),
                );
              }).toList(),
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChatAvailableBotScreen()),
                                );
                              },
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

  Widget _buildBottomNavItem(IconData icon, bool isSelected) {
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? const Color(0xFF8A70FF) : Colors.grey[600],
        size: 28,
      ),
      onPressed: () {},
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
      case 'DeepSeek V3':
        return 'Best for code generation and technical tasks';
      case 'GPT-4':
        return 'Most capable model for general tasks';
      case 'Claude 3':
        return 'Excellent for analysis and long-form content';
      case 'Llama 3':
        return 'Best for code generation and technical tasks';
      default:
        return '';
    }
  }
}
