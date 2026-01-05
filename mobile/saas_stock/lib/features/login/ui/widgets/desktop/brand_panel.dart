import 'package:flutter/material.dart';
import 'package:saas_stock/features/login/ui/widgets/feature_item.dart';

class BrandPanel extends StatelessWidget {
  const BrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 64, color: Colors.white),
            SizedBox(height: 32),
            Text(
              'All your school in one place',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 48),
            FeatureItem(
              text: 'Track students performance',
              icon: Icons.trending_up,
            ),
            SizedBox(height: 16),
            FeatureItem(
              text: 'Manage classes & exams',
              icon: Icons.schedule,
            ),
            SizedBox(height: 16),
            FeatureItem(
              text: 'Communicate with parents',
              icon: Icons.chat,
            ),
          ],
        ),
      ),
    );
  }
}
