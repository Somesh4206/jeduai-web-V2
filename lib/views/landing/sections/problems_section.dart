import 'package:flutter/material.dart';
import '../../../widgets/animated_feature_card.dart';

class ProblemsSection extends StatelessWidget {
  const ProblemsSection({Key? key}) : super(key: key);

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
            'Problems We Solve',
            style: TextStyle(
              fontSize: isMobile ? 36 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: 60),
          
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              AnimatedFeatureCard(
                icon: Icons.language,
                title: 'Language Barrier',
                description: 'English-centric content excludes regional learners from quality education',
              ),
              AnimatedFeatureCard(
                icon: Icons.work_outline,
                title: 'Teacher Workload',
                description: 'Manual grading and quiz creation consume valuable teaching time',
              ),
              AnimatedFeatureCard(
                icon: Icons.person_outline,
                title: 'Lack of Personalization',
                description: 'One-size-fits-all teaching fails to address diverse student needs',
              ),
              AnimatedFeatureCard(
                icon: Icons.signal_wifi_off,
                title: 'Infrastructure Gaps',
                description: 'Rural and low-bandwidth regions need better access to education',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
