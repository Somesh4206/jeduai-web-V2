import 'package:flutter/material.dart';

class ComparisonSection extends StatelessWidget {
  const ComparisonSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      child: Column(
        children: [
          Text(
            'Comparative Analysis',
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
