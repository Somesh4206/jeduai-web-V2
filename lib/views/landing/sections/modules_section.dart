import 'package:flutter/material.dart';
import '../../../widgets/animated_feature_card.dart';

class ModulesSection extends StatelessWidget {
  const ModulesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: 100,
      ),
      child: Column(
        children: [
          Text(
            'Core Modules',
            style: TextStyle(
              fontSize: isMobile ? 36 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: 24),
          
          Container(
            constraints: BoxConstraints(maxWidth: 800),
            child: Text(
              'Comprehensive AI-powered tools for modern education',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 16 : 20,
                color: Colors.white.withOpacity(0.7),
                height: 1.6,
              ),
            ),
          ),
          
          SizedBox(height: 60),
          
          // Modules grid
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              AnimatedFeatureCard(
                icon: Icons.quiz,
                title: 'Smart Assessment',
                description: 'AI-powered quiz generation, auto-grading, and semantic evaluation with instant feedback',
                width: isMobile ? size.width - 40 : 350,
              ),
              AnimatedFeatureCard(
                icon: Icons.school,
                title: 'AI Tutor',
                description: '24/7 intelligent tutoring with personalized explanations and adaptive learning paths',
                width: isMobile ? size.width - 40 : 350,
              ),
              AnimatedFeatureCard(
                icon: Icons.translate,
                title: 'Text Translation',
                description: 'Translate content into 10+ Indian languages with context-aware academic terminology',
                width: isMobile ? size.width - 40 : 350,
              ),
              AnimatedFeatureCard(
                icon: Icons.mic,
                title: 'Audio Translation',
                description: 'Real-time speech-to-text transcription and translation for multilingual learning',
                width: isMobile ? size.width - 40 : 350,
              ),
              AnimatedFeatureCard(
                icon: Icons.video_library,
                title: 'Video Translation',
                description: 'Automated video transcription, translation, and synchronized subtitle generation',
                width: isMobile ? size.width - 40 : 350,
              ),
              AnimatedFeatureCard(
                icon: Icons.hub,
                title: 'Learning Hub',
                description: 'Centralized platform for courses, resources, progress tracking, and collaborative learning',
                width: isMobile ? size.width - 40 : 350,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
