import 'package:flutter/material.dart';

class AnimatedLoginButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;

  const AnimatedLoginButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Login',
  }) : super(key: key);

  @override
  State<AnimatedLoginButton> createState() => _AnimatedLoginButtonState();
}

class _AnimatedLoginButtonState extends State<AnimatedLoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Color(0xFF7C3AED),
                Color(0xFF06B6D4),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF7C3AED).withOpacity(0.5),
                blurRadius: _isHovered ? 30 : 20,
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
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
