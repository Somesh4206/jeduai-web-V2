import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 60),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          Text(
            'JeduAI',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '© 2026 JeduAI. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
