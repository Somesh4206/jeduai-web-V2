import 'package:flutter/material.dart';
import 'dart:ui';

class GlassLoginCard extends StatelessWidget {
  final Widget child;
  final double width;
  final double? height;

  const GlassLoginCard({
    Key? key,
    required this.child,
    this.width = 450,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: -10,
          ),
          BoxShadow(
            color: Color(0xFF06B6D4).withOpacity(0.2),
            blurRadius: 60,
            spreadRadius: -15,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
