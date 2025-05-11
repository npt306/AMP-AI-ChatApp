import 'package:flutter/material.dart';
import '../services/bot_service.dart';

class ChatCustomBotScreen extends StatefulWidget {
  final String assistantName;
  final String description;
  final String botId;

  const ChatCustomBotScreen({
    super.key,
    required this.assistantName,
    required this.description,
    required this.botId,
  });

  @override
  State<ChatCustomBotScreen> createState() => _ChatCustomBotScreenState();
}

class ChatMessage {
  final String content;
  final bool isUser;
  ChatMessage({required this.content, required this.isUser});
}

class _ChatCustomBotScreenState extends State<ChatCustomBotScreen> {
  bool _showMediaIcons = false;
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
            Text(
              widget.assistantName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
                        Text(
                          widget.assistantName,
                          style: const TextStyle(
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
                const SizedBox(height: 8),
                Text(
                  widget.description,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Row(
                  mainAxisAlignment: msg.isUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!msg.isUser)
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
                        child: const Icon(Icons.smart_toy,
                            size: 16, color: Colors.white),
                      ),
                    if (!msg.isUser) const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              msg.isUser ? Colors.grey[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: msg.content == '__loading__' && !msg.isUser
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '...',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[600]),
                                  ),
                                ],
                              )
                            : Text(
                                msg.content,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: msg.isUser
                                      ? Colors.black87
                                      : Colors.black,
                                ),
                              ),
                      ),
                    ),
                    if (msg.isUser) const SizedBox(width: 8),
                  ],
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
                              onPressed: () async {
                                final text = _messageController.text.trim();
                                if (text.isNotEmpty && !_isLoading) {
                                  setState(() {
                                    _messages.add(ChatMessage(
                                        content: text, isUser: true));
                                    _messages.add(ChatMessage(
                                        content: '__loading__', isUser: false));
                                    _isLoading = true;
                                  });
                                  _messageController.clear();

                                  try {
                                    final answer =
                                        await BotService.askAssistant(
                                      assistantId: widget.botId,
                                      message: text,
                                    );
                                    setState(() {
                                      final loadingIndex =
                                          _messages.lastIndexWhere(
                                        (msg) =>
                                            msg.content == '__loading__' &&
                                            !msg.isUser,
                                      );
                                      if (loadingIndex != -1) {
                                        _messages[loadingIndex] = ChatMessage(
                                            content: answer, isUser: false);
                                      } else {
                                        _messages.add(ChatMessage(
                                            content: answer, isUser: false));
                                      }
                                      _isLoading = false;
                                    });
                                  } catch (e) {
                                    setState(() {
                                      _messages.add(ChatMessage(
                                          content: 'Error: $e', isUser: false));
                                      _isLoading = false;
                                    });
                                  }
                                }
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
}
