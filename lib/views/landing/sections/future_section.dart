import 'package:flutter/material.dart';

class FutureSection extends StatelessWidget {
  const FutureSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      child: Column(
        children: [
          Text(
            'Future Vision',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
