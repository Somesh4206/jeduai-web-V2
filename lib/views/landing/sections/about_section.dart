import 'package:flutter/material.dart';
import '../../../widgets/animated_feature_card.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({Key? key}) : super(key: key);

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
            'About JeduAI',
            style: TextStyle(
              fontSize: isMobile ? 36 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: 24),
          
          Container(
            constraints: BoxConstraints(maxWidth: 900),
            child: Text(
              'JeduAI is an AI-powered multilingual educational platform that unifies quizzes, tutoring, translation, transcription, summarization, online classes, and performance tracking into one cloud-native system.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 16 : 20,
                color: Colors.white.withOpacity(0.8),
                height: 1.6,
              ),
            ),
          ),
          
          SizedBox(height: 60),
          
          // Feature highlights grid
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              AnimatedFeatureCard(
                icon: Icons.quiz,
                title: 'Personalized Quizzes',
                description: 'AI-generated adaptive assessments',
              ),
              AnimatedFeatureCard(
                icon: Icons.school,
                title: '24/7 AI Tutoring',
                description: 'Instant doubt solving anytime',
              ),
              AnimatedFeatureCard(
                icon: Icons.translate,
                title: 'Multilingual Access',
                description: '10+ Indian languages supported',
              ),
              AnimatedFeatureCard(
                icon: Icons.analytics,
                title: 'Real-time Analytics',
                description: 'Track progress and performance',
              ),
              AnimatedFeatureCard(
                icon: Icons.auto_awesome,
                title: 'Adaptive Learning',
                description: 'Personalized learning paths',
              ),
              AnimatedFeatureCard(
                icon: Icons.video_library,
                title: 'Auto Transcription',
                description: 'Automated video summarization',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
