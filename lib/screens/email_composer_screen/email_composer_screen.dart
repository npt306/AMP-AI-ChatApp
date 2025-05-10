import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/email_service.dart';
import 'ai_action_buttons.dart';

class EmailComposeScreen extends StatefulWidget {
  const EmailComposeScreen({super.key});

  @override
  State<EmailComposeScreen> createState() => _EmailComposeScreenState();
}

class _EmailComposeScreenState extends State<EmailComposeScreen> {
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _suggestedResponseController =
      TextEditingController();

  bool _isGenerating = false;
  bool _showSuggestions = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _contentController.removeListener(_onContentChanged);
    _senderController.dispose();
    _subjectController.dispose();
    _contentController.dispose();
    _receiverController.dispose();
    _suggestedResponseController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    // Extract receiver email from content
    final content = _contentController.text;
    if (content.isNotEmpty) {
      // Look for common email patterns in the content
      final emailRegex = RegExp(r'[\w\.-]+@[\w\.-]+\.\w+');
      final matches = emailRegex.allMatches(content);

      // Find the first email that's not the sender's email
      for (var match in matches) {
        final email = match.group(0);
        if (email != null && email != _senderController.text) {
          _receiverController.text = email;
          break;
        }
      }
    }
  }

  Future<void> _handleAIAction(String actionType) async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the original email content first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _showSuggestions = false;
    });

    try {
      // Detect language from content
      final language = _detectLanguage(_contentController.text);

      final metadata = {
        'context': [],
        'subject': _subjectController.text,
        'sender': _senderController.text,
        'receiver': _receiverController.text,
        'style': {
          'length': 'medium',
          'formality': 'neutral',
          'tone': 'professional'
        },
        'language': language
      };

      // First get reply ideas
      final suggestions = await EmailService.getReplyIdeas(
        email: _contentController.text,
        action: 'Suggest 3 ideas for this email',
        metadata: metadata,
      );

      setState(() {
        _suggestions = suggestions;
        _showSuggestions = true;
      });

      // Then generate the full response
      Map<String, dynamic> response;
      switch (actionType) {
        case 'thanks':
          response = await EmailService.generateThankYouEmail(
            email: _contentController.text,
            metadata: metadata,
          );
          break;
        case 'sorry':
          response = await EmailService.generateApologyEmail(
            email: _contentController.text,
            metadata: metadata,
          );
          break;
        case 'yes':
          response = await EmailService.generateConfirmationEmail(
            email: _contentController.text,
            metadata: metadata,
          );
          break;
        case 'no':
          response = await EmailService.generateRejectionEmail(
            email: _contentController.text,
            metadata: metadata,
          );
          break;
        case 'follow up':
          response = await EmailService.generateFollowUpEmail(
            email: _contentController.text,
            metadata: metadata,
          );
          break;
        case 'more info':
          response = await EmailService.generateInfoRequestEmail(
            email: _contentController.text,
            metadata: metadata,
          );
          break;
        default:
          throw Exception('Unknown action type');
      }

      setState(() {
        _suggestedResponseController.text = response['email'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Email generated successfully. Remaining usage: ${response['remainingUsage']}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  String _detectLanguage(String text) {
    // Simple language detection based on common patterns
    if (text.contains(RegExp(
        r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]'))) {
      return 'vietnamese';
    }
    return 'english';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
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
          'AI Email Assistant',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Original Email Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE9ECEF),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Original Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF495057),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          'Sender',
                          _senderController,
                          'Enter the person who sent you this email',
                          isRequired: true,
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          'Receiver',
                          _receiverController,
                          'Enter email you want to send the response to',
                          isRequired: true,
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          'Subject',
                          _subjectController,
                          'Enter email subject',
                          isRequired: true,
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          'Content',
                          _contentController,
                          'Paste the original email content here',
                          minLines: 2,
                          maxLines: 10,
                          isRequired: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // AI Actions Section
                  _isGenerating
                      ? const Center(child: CircularProgressIndicator())
                      : AIActionButtons(onActionSelected: _handleAIAction),
                  const SizedBox(height: 16),

                  // Suggestions Section
                  if (_showSuggestions) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE9ECEF),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Suggestions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF495057),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._suggestions.map((suggestion) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE9ECEF),
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      suggestion,
                                      style: const TextStyle(
                                        color: Color(0xFF495057),
                                        fontSize: 14,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.copy_rounded,
                                        color: Color(0xFF6C757D),
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _copyToClipboard(suggestion),
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Generated Response Section
                  if (_suggestedResponseController.text.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE9ECEF),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Generated Response',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF495057),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.copy_rounded,
                                  color: Color(0xFF6C757D),
                                  size: 20,
                                ),
                                onPressed: () => _copyToClipboard(
                                    _suggestedResponseController.text),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE9ECEF),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _suggestedResponseController,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(12),
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Color(0xFFADB5BD)),
                              ),
                              maxLines: null,
                              minLines: 5,
                              style: const TextStyle(
                                color: Color(0xFF495057),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    int minLines = 1,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF495057),
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE9ECEF),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFADB5BD)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: maxLines,
            minLines: minLines,
            style: const TextStyle(
              color: Color(0xFF495057),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
