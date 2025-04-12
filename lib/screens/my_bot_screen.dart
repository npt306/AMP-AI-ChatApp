import 'package:flutter/material.dart';
import 'create_bot_screen.dart';
import 'chat_custom_bot_screen.dart';
import 'chat_available_bot_screen.dart';

class MyBotScreen extends StatefulWidget {
  const MyBotScreen({super.key});

  @override
  State<MyBotScreen> createState() => _MyBotScreenState();
}

class _MyBotScreenState extends State<MyBotScreen> {
  String selectedButton = 'Availabled';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildFilterButtons(),
          const SizedBox(height: 20),
          _buildBotList(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'My Bots',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      actions: [_buildCreateButton()],
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateBotScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: const Icon(
                Icons.add,
                size: 12,
                color: Colors.black,
                weight: 900,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Create',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildFilterButton('Availabled'),
          _buildFilterButton('Created'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    final isSelected = selectedButton == label;
    return GestureDetector(
      onTap: () => setState(() => selectedButton = label),
      child: Container(
        margin: EdgeInsets.only(
          right: label == 'Availabled' ? 8 : 0,
          left: label == 'Created' ? 8 : 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: selectedButton == 'Availabled' ? 3 : 1,
        itemBuilder: (context, index) => _buildBotCard(index),
      ),
    );
  }

  Widget _buildBotCard(int index) {
    final bots = selectedButton == 'Availabled' ? _availableBots : _createdBots;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => selectedButton == 'Availabled'
                // ? const ChatAvailableBotScreen()
                ? const ChatCustomBotScreen()
                : const ChatCustomBotScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildBotIcon(bots[index]),
            const SizedBox(width: 16),
            Text(bots[index]['name'], style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildBotIcon(Map<String, dynamic> bot) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: bot['icon'] is IconData
            ? Border.all(color: Colors.grey[300]!)
            : null,
      ),
      child: bot['icon'] is IconData
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple[300]!, Colors.purple[400]!],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                bot['icon'] as IconData,
                color: Colors.white,
                size: 30,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                bot['icon'] as String,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  final List<Map<String, dynamic>> _availableBots = [
    {'name': 'Gemini', 'icon': 'assets/images/gemini.png'},
    {'name': 'DeepSeek', 'icon': 'assets/images/deepseek.png'},
    {'name': 'ChatGPT', 'icon': 'assets/images/gpt.webp'},
  ];

  final List<Map<String, dynamic>> _createdBots = [
    {'name': 'Custom Bot', 'icon': Icons.smart_toy},
  ];
}
