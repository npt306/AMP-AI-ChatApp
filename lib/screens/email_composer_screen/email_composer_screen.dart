import 'package:flutter/material.dart';
import 'ai_action_buttons.dart';
import 'ai_service.dart';

class EmailComposeScreen extends StatefulWidget {
  const EmailComposeScreen({super.key});

  @override
  State<EmailComposeScreen> createState() => _EmailComposeScreenState();
}

class _EmailComposeScreenState extends State<EmailComposeScreen> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  bool _showCc = false;
  final FocusNode _bodyFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fromController.text = 'myemail@example.com';
  }

  @override
  void dispose() {
    _toController.dispose();
    _ccController.dispose();
    _fromController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }

  void _handleAIAction(String actionType) async {
    final String generatedText = await AIService.generateText(actionType);

    // Insert text at current cursor position or append to end
    final int cursorPos = _bodyController.selection.baseOffset;
    final String currentText = _bodyController.text;

    if (cursorPos >= 0) {
      String newText = currentText.substring(0, cursorPos) +
          generatedText +
          currentText.substring(cursorPos);
      _bodyController.text = newText;
      // Place cursor at end of inserted text
      _bodyController.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPos + generatedText.length),
      );
    } else {
      // If no cursor position, append to end
      _bodyController.text = currentText + generatedText;
    }

    // Focus back on the body text field
    _bodyFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Email Composer',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leadingWidth: 70,
        actions: [
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email sent')),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside of text fields
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Email fields
                    _buildDivider(),
                    _buildTextField('To:', _toController, 'Recipient email'),

                    // From field
                    _buildDivider(),
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        const Text(
                          'From:',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _fromController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.blue),
                          onPressed: () {
                            setState(() {
                              _showCc = !_showCc;
                            });
                          },
                        ),
                      ],
                    ),

                    // CC field (conditional)
                    if (_showCc) ...[
                      _buildDivider(),
                      _buildTextField('CC:', _ccController, 'CC email'),
                    ],

                    // Subject field
                    _buildDivider(),
                    _buildTextField('Subject:', _subjectController, 'Subject'),
                    _buildDivider(),

                    // AI Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: AIActionButtons(onActionSelected: _handleAIAction),
                    ),
                    _buildDivider(),

                    // Email body
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _bodyController,
                        focusNode: _bodyFocusNode,
                        decoration: const InputDecoration(
                          hintText: 'Type something...',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        maxLines: null,
                        minLines: 10,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
    );
  }
}
