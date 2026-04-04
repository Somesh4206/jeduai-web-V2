/// Transcript Panel Widget
/// 
/// Displays transcript and translated text
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranscriptPanel extends StatelessWidget {
  final String title;
  final String content;
  final Color color;
  
  const TranscriptPanel({
    super.key,
    required this.title,
    required this.content,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.text_fields, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Copy to clipboard',
                ),
              ],
            ),
          ),
          
          // Content
          Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: SelectableText(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
