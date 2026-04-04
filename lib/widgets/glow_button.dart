import 'package:flutter/material.dart';

class GlowButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final double width;

  const GlowButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.width = 200,
  }) : super(key: key);

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        child: Container(
          width: widget.width,
          height: 56,
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                  )
                : null,
            border: widget.isPrimary
                ? null
                : Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isPrimary && _isHovered
                ? [
                    BoxShadow(
                      color: Color(0xFF7C3AED).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
