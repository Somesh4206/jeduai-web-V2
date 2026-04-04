import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

class GlassNavbar extends StatefulWidget {
  final Function(String) onNavigate;

  const GlassNavbar({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<GlassNavbar> createState() => _GlassNavbarState();
}

class _GlassNavbarState extends State<GlassNavbar> {
  String _activeSection = 'home';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  _buildLogo(),
                  
                  if (!isMobile) ...[
                    // Nav items
                    Row(
                      children: [
                        _buildNavItem('Home', 'home'),
                        _buildNavItem('About', 'about'),
                        _buildNavItem('Modules', 'modules'),
                      ],
                    ),
                    
                    // Auth buttons
                    Row(
                      children: [
                        _buildAuthButton('Login', false),
                        SizedBox(width: 12),
                        _buildAuthButton('Register', true),
                      ],
                    ),
                  ],
                  
                  if (isMobile)
                    IconButton(
                      icon: Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        // Mobile menu
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLogo() {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
          ).createShader(bounds),
          child: Text(
            'JeduAI',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(String label, String section) {
    final isActive = _activeSection == section;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() => _activeSection = section);
          widget.onNavigate(section);
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Color(0xFF7C3AED) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 15,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton(String label, bool isPrimary) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (label == 'Login') {
            Get.toNamed('/login');
          } else {
            Get.toNamed('/signup');
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                  )
                : null,
            border: isPrimary ? null : Border.all(color: Colors.white.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
