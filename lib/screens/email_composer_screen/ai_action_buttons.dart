import 'package:flutter/material.dart';

class AIActionButtons extends StatelessWidget {
  final Function(String) onActionSelected;

  const AIActionButtons({
    super.key,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Choose Response Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF495057),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildActionButton(
                  'Thanks',
                  Icons.thumb_up_rounded,
                  const Color(0xFF4CAF50),
                  'thanks',
                ),
                _buildActionButton(
                  'Sorry',
                  Icons.sentiment_dissatisfied_rounded,
                  const Color(0xFFF44336),
                  'sorry',
                ),
                _buildActionButton(
                  'Yes',
                  Icons.check_circle_rounded,
                  const Color(0xFF2196F3),
                  'yes',
                ),
                _buildActionButton(
                  'No',
                  Icons.cancel_rounded,
                  const Color(0xFF9C27B0),
                  'no',
                ),
                _buildActionButton(
                  'Follow Up',
                  Icons.update_rounded,
                  const Color(0xFFFF9800),
                  'follow up',
                ),
                _buildActionButton(
                  'More Info',
                  Icons.info_rounded,
                  const Color(0xFF607D8B),
                  'more info',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    String actionType,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onActionSelected(actionType),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
