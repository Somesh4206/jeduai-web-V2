import 'package:flutter/material.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/glass_navbar.dart';
import 'sections/hero_section.dart';
import 'sections/about_section.dart';
import 'sections/problems_section.dart';
import 'sections/platform_overview_section.dart';
import 'sections/modules_section.dart';
import 'sections/footer_section.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {
    'home': GlobalKey(),
    'about': GlobalKey(),
    'modules': GlobalKey(),
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String section) {
    final key = _sectionKeys[section];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: Stack(
          children: [
            // Main scrollable content
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  SizedBox(height: 80), // Space for navbar
                  HeroSection(key: _sectionKeys['home']),
                  AboutSection(key: _sectionKeys['about']),
                  ProblemsSection(),
                  PlatformOverviewSection(),
                  ModulesSection(key: _sectionKeys['modules']),
                  FooterSection(),
                ],
              ),
            ),
            
            // Sticky navbar
            GlassNavbar(
              onNavigate: _scrollToSection,
            ),
          ],
        ),
      ),
    );
  }
}
