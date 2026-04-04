import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/glow_button.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({Key? key}) : super(key: key);

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Container(
      height: size.height,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: 60,
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main title
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Color(0xFF7C3AED),
                    Color(0xFF06B6D4),
                  ],
                ).createShader(bounds),
                child: Text(
                  'Welcome to JeduAI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 40 : 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Subtitle
              Text(
                'Smart Learning & Assessment Platform',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 20 : 32,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w300,
                ),
              ),
              
              SizedBox(height: 32),
              
              // Tagline
              Container(
                constraints: BoxConstraints(maxWidth: 800),
                child: Text(
                  'An AI-powered multilingual educational platform delivering personalized learning, real-time translation, and adaptive assessments for inclusive education',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.6,
                  ),
                ),
              ),
              
              SizedBox(height: 48),
              
              // CTA Buttons
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  GlowButton(
                    text: 'Get Started',
                    onPressed: () => Get.toNamed('/signup'),
                    isPrimary: true,
                  ),
                  GlowButton(
                    text: 'Explore Features',
                    onPressed: () {},
                    isPrimary: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
