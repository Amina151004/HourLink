import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('How To Use HourLink!', style: AppTextStyles.heading),
      ),
    );
  }
}
