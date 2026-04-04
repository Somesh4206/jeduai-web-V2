import 'package:flutter/material.dart';

class PlatformOverviewSection extends StatelessWidget {
  const PlatformOverviewSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      child: Column(
        children: [
          Text(
            'Platform Overview',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'One Integrated Ecosystem',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
