import 'package:flutter/material.dart';

class AIActionButtons extends StatelessWidget {
  final Function(String) onActionSelected;

  const AIActionButtons({
    super.key,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            _buildActionChip('Thanks', context),
            _buildActionChip('Sorry', context),
            _buildActionChip('Yes', context),
            _buildActionChip('No', context),
            _buildActionChip('Follow Up', context),
            _buildActionChip('Request', context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(String label, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        label: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 13,
          ),
        ),
        backgroundColor: Colors.grey.shade100,
        side: BorderSide(color: Colors.grey.shade300),
        onPressed: () => onActionSelected(label),
      ),
    );
  }
}

