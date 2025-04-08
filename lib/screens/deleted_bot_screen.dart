import 'package:flutter/material.dart';
import 'manage_bot_screen.dart';

class DeletedBotScreen extends StatefulWidget {
  const DeletedBotScreen({super.key});

  @override
  State<DeletedBotScreen> createState() => _DeletedBotScreenState();
}

class _DeletedBotScreenState extends State<DeletedBotScreen> {
  final bool _showMediaIcons = false;
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple[400]!, Colors.purple[600]!],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.smart_toy, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              'Custom Bot',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 6),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageBotScreen(),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.black, size: 24),
          ),
        ],
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
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.purple[400]!, Colors.purple[600]!],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assistant',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            children: [
                              TextSpan(text: 'By '),
                              TextSpan(
                                text: '@Anonymous',
                                style: TextStyle(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ), // Chỉnh padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size.zero, // Bỏ kích thước tối thiểu
                        tapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // Thu nhỏ button theo content
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize
                            .min, // Quan trọng: giúp Row chỉ rộng vừa đủ nội dung
                        children: [
                          Icon(Icons.info_outline, size: 22),
                          SizedBox(width: 4),
                          Text('Bot info', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[500],
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ), // Chỉnh padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size.zero, // Bỏ kích thước tối thiểu
                        tapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // Thu nhỏ button theo content
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize
                            .min, // Quan trọng: giúp Row chỉ rộng vừa đủ nội dung
                        children: [
                          Icon(Icons.share, size: 22, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Share',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'General-purpose assistant. Write, code, ask for real-time information, create images, and more.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.dangerous_rounded,
                        size: 16,
                        color: Colors.red,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Deleted',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Assistant message
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.purple[400]!, Colors.purple[600]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                child: const Text(
                                  'Assistant',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Hello! How can I help you today?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // User message
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Hi! Can you help me with coding?',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Assistant message
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.purple[400]!, Colors.purple[600]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                child: const Text(
                                  'Assistant',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Of course! I\'d be happy to help you with coding. What kind of programming help do you need? I can assist with various programming languages, frameworks, and development concepts.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // User message
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'I want to learn Flutter. Where should I start?',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Assistant message with learning Flutter
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.purple[400]!, Colors.purple[600]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                child: const Text(
                                  'Assistant',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Great choice! Here\'s a structured approach to learn Flutter:\n\n1. Start with Dart basics (variables, functions, classes)\n2. Learn Flutter fundamentals (widgets, state management)\n3. Build simple apps (counter, todo list)\n4. Study UI/UX principles\n5. Explore advanced topics (navigation, databases)\n\nWould you like me to explain any of these topics in detail?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber[800],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bot7ADM320 has been deleted by its creator. Your chat history is saved but you won\'t be able to send new messages to this bot',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.amber[900],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message input row
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
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors
                          .grey[200], // Màu xám nhạt hơn để thể hiện disabled
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: _showMediaIcons ? 96 : 48,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              // Add button that toggles visibility (disabled)
                              AnimatedOpacity(
                                opacity: _showMediaIcons ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: IconButton(
                                  icon: Icon(Icons.add_circle_outline,
                                      color:
                                          Colors.grey[400]), // Màu xám nhạt hơn
                                  onPressed: null, // Disabled
                                ),
                              ),
                              // Sliding media icons (disabled)
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
                                              color: Colors.grey[400]),
                                          onPressed: null, // Disabled
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.photo_library,
                                              color: Colors.grey[400]),
                                          onPressed: null, // Disabled
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
                            enabled: false, // Disabled
                            decoration: InputDecoration(
                              hintText: 'Bot is no longer available',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.grey[400]),
                          onPressed: null, // Disabled
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
