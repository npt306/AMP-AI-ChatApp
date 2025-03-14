import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;

  const MenuDrawer({
    super.key,
    required this.onItemSelected,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75, // 75% of screen width
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // My Bots Item
            _buildMenuItem(
              context,
              index: 0,
              title: 'My Bots',
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Explore Item
            _buildMenuItem(
              context,
              index: 1,
              title: 'Explore',
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.grid_view,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // History Item
            _buildMenuItem(
              context,
              index: 2,
              title: 'History',
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.history,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Prompt Library Item
            _buildMenuItem(
              context,
              index: 3,
              title: 'Prompt Library',
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.library_books,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Email Composer Item
            _buildMenuItem(
              context,
              index: 4,
              title: 'Email Composer',
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.email_rounded,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: Colors.black12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required String title,
    required Widget leading,
  }) {
    final isSelected = index == selectedIndex;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onItemSelected(index);
          Scaffold.of(context).closeDrawer();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
