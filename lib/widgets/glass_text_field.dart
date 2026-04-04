import 'package:flutter/material.dart';

class GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;

  const GlassTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused
              ? Color(0xFF7C3AED).withOpacity(0.6)
              : Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: Color(0xFF7C3AED).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() => _isFocused = hasFocus);
        },
        child: TextField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
            prefixIcon: Icon(
              widget.icon,
              color: _isFocused ? Color(0xFF7C3AED) : Colors.white.withOpacity(0.5),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    onPressed: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ),
    );
  }
}
